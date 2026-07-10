-- =============================================================
-- Konect - MVP: X,Y Position + OpenRouter Scoring Support
-- PostgreSQL Migration v3.0 (MVP)
--
-- 1. Update get_topic_graph() — return x,y dari relevance_score
-- 2. Add topic embedding column (persiapan future)
-- 3. Fix cosine_similarity function
-- 4. Add trigger untuk auto-default score (fallback jika ML gagal)
-- =============================================================

-- =============================================================
-- 1. GET_TOPIC_GRAPH — dengan X,Y position
-- =============================================================
-- Compute x,y dari relevance_score + hash node_id (deterministik)
-- radius = (1.0 - score) x MAX_RADIUS
-- angle  = hash(node_id) mod 360
-- x = center_x + radius x cos(angle)
-- y = center_y + radius x sin(angle)

CREATE OR REPLACE FUNCTION get_topic_graph(p_topic_id UUID)
RETURNS TABLE (nodes JSONB, edges JSONB) AS $$
DECLARE
    v_nodes JSONB;
    v_edges JSONB;
    v_cx CONSTANT INTEGER := 600;
    v_cy CONSTANT INTEGER := 400;
    v_r  CONSTANT INTEGER := 320;
BEGIN
    -- Build nodes array with x,y
    SELECT jsonb_agg(jsonb_build_object(
        'id', n.node_id,
        'type', n.node_type,
        'label', n.label,
        'relevance_score', n.relevance_score,
        'cluster', n.cluster,
        'size', CASE n.node_type
            WHEN 'topic' THEN 20 WHEN 'opinion' THEN 12 WHEN 'comment' THEN 7
        END,
        'x', n.x_pos,
        'y', n.y_pos
    ))
    INTO v_nodes
    FROM (
        -- Topic: fixed di pusat canvas
        SELECT id||'-topic' AS node_id, 'topic' AS node_type, title AS label,
               1.0000::DECIMAL(5,4) AS relevance_score, 'root' AS cluster,
               v_cx::FLOAT AS x_pos, v_cy::FLOAT AS y_pos
        FROM discussion_rooms WHERE id = p_topic_id

        UNION ALL

        -- Opinion: polar position dari relevance_score + hash md5
        SELECT o.id||'-opinion', 'opinion', LEFT(o.content, 100),
               COALESCE(o.relevance_score, 0.5000::DECIMAL(5,4)), 'opinion',
               v_cx + ((1.0 - COALESCE(o.relevance_score, 0.5)) * v_r)
                 * cos(radians((('x'||substr(md5(o.id||'-opinion'),1,8))::bit(32)::int % 360)::numeric)),
               v_cy + ((1.0 - COALESCE(o.relevance_score, 0.5)) * v_r)
                 * sin(radians((('x'||substr(md5(o.id||'-opinion'),1,8))::bit(32)::int % 360)::numeric))
        FROM opinions o WHERE o.room_id = p_topic_id

        UNION ALL

        -- Comment: offset 30px dari radius opinion induk
        SELECT dc.id||'-comment', 'comment', LEFT(dc.content, 100),
               COALESCE(dc.relevance_score, 0.5000::DECIMAL(5,4)), 'comment',
               v_cx + (((1.0 - COALESCE(o.relevance_score, 0.5)) * v_r) + 30)
                 * cos(radians((('x'||substr(md5(dc.id||'-comment'),1,8))::bit(32)::int % 360)::numeric)),
               v_cy + (((1.0 - COALESCE(o.relevance_score, 0.5)) * v_r) + 30)
                 * sin(radians((('x'||substr(md5(dc.id||'-comment'),1,8))::bit(32)::int % 360)::numeric))
        FROM discussion_comments dc
        JOIN opinions o ON o.id = dc.opinion_id
        WHERE o.room_id = p_topic_id
    ) n;

    -- Build edges array (tidak berubah dari versi sebelumnya)
    SELECT jsonb_agg(jsonb_build_object(
        'source', e.source_id, 'target', e.target_id,
        'weight', e.weight, 'type', e.edge_type
    ))
    INTO v_edges
    FROM (
        SELECT o.room_id||'-topic' AS source_id,
               o.id||'-opinion' AS target_id,
               COALESCE(o.relevance_score, 0.5)::DECIMAL(5,4) AS weight,
               'topic-opinion' AS edge_type
        FROM opinions o WHERE o.room_id = p_topic_id

        UNION ALL

        SELECT dc.opinion_id||'-opinion',
               dc.id||'-comment',
               COALESCE(dc.relevance_score, 0.5)::DECIMAL(5,4),
               'opinion-comment'
        FROM discussion_comments dc
        JOIN opinions o ON o.id = dc.opinion_id
        WHERE o.room_id = p_topic_id
    ) e;

    RETURN QUERY SELECT v_nodes, v_edges;
END;
$$ LANGUAGE plpgsql;


-- =============================================================
-- 2. UPDATE NODE_GRAPH VIEW — dengan x,y position
-- =============================================================

CREATE OR REPLACE VIEW node_graph AS
WITH topic_nodes AS (
    SELECT dr.id::TEXT || '-topic' AS node_id, 'topic'::VARCHAR(20) AS node_type,
           dr.title AS label, dr.id AS topic_id, NULL::UUID AS parent_id,
           1.0000::DECIMAL(5,4) AS relevance_score, 'root'::VARCHAR(20) AS cluster,
           600.0::FLOAT AS x, 400.0::FLOAT AS y
    FROM discussion_rooms dr WHERE dr.is_active = true
),
opinion_nodes AS (
    SELECT o.id::TEXT || '-opinion', 'opinion'::VARCHAR(20), LEFT(o.content, 80),
           o.room_id, o.id, COALESCE(o.relevance_score, 0.5000)::DECIMAL(5,4),
           'opinion'::VARCHAR(20),
           600.0 + ((1.0 - COALESCE(o.relevance_score, 0.5)) * 320)
             * cos(radians((('x'||substr(md5(o.id||'-opinion'),1,8))::bit(32)::int % 360)::numeric)),
           400.0 + ((1.0 - COALESCE(o.relevance_score, 0.5)) * 320)
             * sin(radians((('x'||substr(md5(o.id||'-opinion'),1,8))::bit(32)::int % 360)::numeric))
    FROM opinions o JOIN discussion_rooms dr ON dr.id = o.room_id AND dr.is_active = true
),
comment_nodes AS (
    SELECT dc.id::TEXT || '-comment', 'comment'::VARCHAR(20), LEFT(dc.content, 80),
           o.room_id, dc.opinion_id, COALESCE(dc.relevance_score, 0.5000)::DECIMAL(5,4),
           'comment'::VARCHAR(20),
           600.0 + (((1.0 - COALESCE(o.relevance_score, 0.5)) * 320) + 30)
             * cos(radians((('x'||substr(md5(dc.id||'-comment'),1,8))::bit(32)::int % 360)::numeric)),
           400.0 + (((1.0 - COALESCE(o.relevance_score, 0.5)) * 320) + 30)
             * sin(radians((('x'||substr(md5(dc.id||'-comment'),1,8))::bit(32)::int % 360)::numeric))
    FROM discussion_comments dc
    JOIN opinions o ON o.id = dc.opinion_id
    JOIN discussion_rooms dr ON dr.id = o.room_id AND dr.is_active = true
),
all_nodes AS (SELECT * FROM topic_nodes UNION ALL SELECT * FROM opinion_nodes UNION ALL SELECT * FROM comment_nodes),
edges AS (
    SELECT o.room_id::TEXT || '-topic' AS source_id, o.id::TEXT || '-opinion' AS target_id,
           COALESCE(o.relevance_score, 0.5000)::DECIMAL(5,4) AS weight,
           'topic-opinion'::VARCHAR(20) AS edge_type
    FROM opinions o
    UNION ALL
    SELECT dc.opinion_id::TEXT || '-opinion', dc.id::TEXT || '-comment',
           COALESCE(dc.relevance_score, 0.5000)::DECIMAL(5,4), 'opinion-comment'::VARCHAR(20)
    FROM discussion_comments dc
)
SELECT 'node'::VARCHAR(10) AS row_type,
       n.node_id, n.node_type, n.label, n.topic_id, n.parent_id,
       n.relevance_score, n.cluster, n.x, n.y,
       NULL::TEXT AS source_id, NULL::TEXT AS target_id,
       NULL::DECIMAL(5,4) AS edge_weight, NULL::VARCHAR(20) AS edge_type
FROM all_nodes n
UNION ALL
SELECT 'edge'::VARCHAR(10), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
       e.source_id, e.target_id, e.weight, e.edge_type
FROM edges e
WHERE EXISTS (SELECT 1 FROM all_nodes n1 WHERE n1.node_id = e.source_id)
  AND EXISTS (SELECT 1 FROM all_nodes n2 WHERE n2.node_id = e.target_id);


-- =============================================================
-- 3. FIX COSINE_SIMILARITY — return 1-distance
-- =============================================================
-- Sebelumnya: return (a <=> b) = cosine DISTANCE (0=identical)
-- Sesudah:    return 1 - (a <=> b) = cosine SIMILARITY (1=identical)

CREATE OR REPLACE FUNCTION cosine_similarity(a VECTOR(384), b VECTOR(384))
RETURNS DECIMAL(5,4) AS $$
BEGIN
    RETURN (1 - (a <=> b))::DECIMAL(5,4);
END;
$$ LANGUAGE plpgsql IMMUTABLE;


-- =============================================================
-- 4. ADD EMBEDDING COLUMN TO DISCUSSION_ROOMS (persiapan)
-- =============================================================

ALTER TABLE discussion_rooms ADD COLUMN IF NOT EXISTS embedding VECTOR(384);


-- =============================================================
-- 5. ADD IVFFLAT INDEX TO DISCUSSION_COMMENTS
-- =============================================================

CREATE INDEX IF NOT EXISTS idx_discussion_comments_embedding
    ON discussion_comments
    USING ivfflat (embedding vector_cosine_ops)
    WITH (lists = 100);


-- =============================================================
-- 6. TRIGGER: fallback default score jika ML gagal
-- =============================================================
-- Saat opinion dibuat, default relevance_score = 0.5
-- Nanti Edge Function update dengan score real

CREATE OR REPLACE FUNCTION set_default_relevance()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.relevance_score IS NULL THEN
        NEW.relevance_score = 0.5000;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_opinions_default_relevance ON opinions;
CREATE TRIGGER trg_opinions_default_relevance
    BEFORE INSERT ON opinions
    FOR EACH ROW EXECUTE FUNCTION set_default_relevance();

DROP TRIGGER IF EXISTS trg_comments_default_relevance ON discussion_comments;
CREATE TRIGGER trg_comments_default_relevance
    BEFORE INSERT ON discussion_comments
    FOR EACH ROW EXECUTE FUNCTION set_default_relevance();
