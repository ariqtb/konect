-- =============================================================
-- Migration 011: Canvas coordinates (x, y) di get_topic_graph
-- Date: 2026-07-11
-- Fix: round(double precision, integer) doesn't exist in pg.
--      Cast whole expression to numeric first.
-- =============================================================

create or replace function public.get_topic_graph(p_topic_id uuid)
returns table(nodes jsonb, edges jsonb)
language plpgsql
as $function$
declare
    v_nodes jsonb;
    v_edges jsonb;
    v_max_radius constant int := 250;
begin
    select jsonb_agg(jsonb_build_object(
        'id', n.node_id,
        'type', n.node_type,
        'label', n.label,
        'relevance_score', n.relevance_score,
        'cluster', n.cluster,
        'size', case n.node_type
            when 'topic' then 24
            when 'opinion' then 14
            when 'comment' then 8
        end,
        'x', case n.node_type
            when 'topic' then 0
            else
                round(
                    (((1.0 - n.relevance_score::float) * v_max_radius)
                     * cos(
                         (('x' || substr(md5(n.node_id), 1, 8))::bit(32)::int::float
                          / 4294967296.0) * 6.28318530718
                     ))::numeric,
                    2
                )
        end,
        'y', case n.node_type
            when 'topic' then 0
            else
                round(
                    (((1.0 - n.relevance_score::float) * v_max_radius)
                     * sin(
                         (('x' || substr(md5(n.node_id), 1, 8))::bit(32)::int::float
                          / 4294967296.0) * 6.28318530718
                     ))::numeric,
                    2
                )
        end
    ))
    into v_nodes
    from (
        select id::text || '-topic' as node_id, 'topic' as node_type,
               title as label, 1.0000::decimal(5,4) as relevance_score, 'root' as cluster
        from discussion_rooms where id = p_topic_id
        union all
        select o.id::text || '-opinion', 'opinion', left(o.content, 100),
               coalesce(o.relevance_score, 0.5), 'opinion'
        from opinions o where o.room_id = p_topic_id
        union all
        select dc.id::text || '-comment', 'comment', left(dc.content, 100),
               coalesce(dc.relevance_score, 0.5), 'comment'
        from discussion_comments dc
        join opinions o on o.id = dc.opinion_id
        where o.room_id = p_topic_id
    ) n;

    select jsonb_agg(jsonb_build_object(
        'source', e.source_id, 'target', e.target_id,
        'weight', e.weight, 'type', e.edge_type
    ))
    into v_edges
    from (
        select o.room_id::text || '-topic' as source_id,
               o.id::text || '-opinion' as target_id,
               coalesce(o.relevance_score, 0.5) as weight,
               'topic-opinion' as edge_type
        from opinions o where o.room_id = p_topic_id
        union all
        select dc.opinion_id::text || '-opinion', dc.id::text || '--comment',
               coalesce(dc.relevance_score, 0.5), 'opinion-comment'
        from discussion_comments dc
        join opinions o on o.id = dc.opinion_id
        where o.room_id = p_topic_id
    ) e
    where exists (select 1 from jsonb_array_elements(v_nodes) n where n->>'id' = e.source_id)
      and exists (select 1 from jsonb_array_elements(v_nodes) n where n->>'id' = e.target_id);

    return query select v_nodes, v_edges;
end;
$function$;
