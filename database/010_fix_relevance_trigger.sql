-- =============================================================
-- Migration 010: Fix auto_compute_opinion_relevance trigger
-- Date: 2026-07-11
--
-- Replace stub (selalu set 0.5) dengan real cosine similarity:
--   relevance_score = 1.0 - cosine_distance(opinion, topic)
-- dimana cosine_distance = embedding <=> topic_embedding
--
-- Distance 0 = identik (score 1.0)
-- Distance 1 = ortogonal (score 0.0)
-- Distance 2 = opposite (score -1.0) — di-cap ke 0 minimum
-- =============================================================

create or replace function public.auto_compute_opinion_relevance()
returns trigger
language plpgsql
as $function$
declare
    topic_emb vector(1536);
    sim numeric(5,4);
begin
    -- Ambil topic embedding via room_id
    select embedding into topic_emb
    from public.discussion_rooms
    where id = NEW.room_id;

    -- Hitung cosine similarity kalau dua-duanya ada
    if NEW.embedding is not null and topic_emb is not null then
        sim := 1.0 - (NEW.embedding <=> topic_emb);
        -- Cap ke range [0, 1] untuk safety
        if sim < 0 then sim := 0; end if;
        if sim > 1 then sim := 1; end if;
        NEW.relevance_score := sim;
    else
        -- Fallback kalau salah satu embedding belum ready
        NEW.relevance_score := 0.5;
    end if;

    return NEW;
end;
$function$;

-- Re-attach trigger (idempotent)
drop trigger if exists trg_auto_compute_opinion_relevance on public.opinions;
create trigger trg_auto_compute_opinion_relevance
    before insert or update on public.opinions
    for each row
    execute function public.auto_compute_opinion_relevance();

-- Backfill 5 opini existing (trigger fires on UPDATE, recompute relevance_score)
-- Pakai dummy update untuk trigger fire
update public.opinions
set relevance_score = relevance_score  -- no-op value, tapi trigger recompute
where embedding is not null;

-- Verify
select
    count(*) as total,
    count(relevance_score) as with_score,
    round(avg(relevance_score)::numeric, 4) as avg_score,
    round(min(relevance_score)::numeric, 4) as min_score,
    round(max(relevance_score)::numeric, 4) as max_score
from public.opinions;
