-- =============================================================
-- Konect - ML Relevance Scoring & Node Graph
-- PostgreSQL Migration v2.0
--
-- Functions, views, dan helper untuk:
-- - Relevance score computation (pairs)
-- - Cosine similarity queries (pgvector)
-- - Node graph data generation
-- - Auto-embedding hooks untuk Python ML backend
--
-- Node graph hierarchy:
--   Topic (discussion_rooms) → Opinion/Pendapat (opinions)
--   → Comment (discussion_comments)
-- Voting = reactions (agree/disagree) pada opinions.
-- =============================================================

-- =============================================================
-- FUNCTION: Cosine Similarity (fallback tanpa pgvector op)
-- =============================================================

CREATE OR REPLACE FUNCTION cosine_similarity(a VECTOR(384), b VECTOR(384))
RETURNS DECIMAL(5,4) AS $$
BEGIN
    RETURN (a <=> b)::DECIMAL(5,4);  -- <=> = cosine distance, kita convert ke similarity
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- =============================================================
-- VIEW: Node Graph — Data siap pakai untuk frontend visualisasi
-- Menggabungkan semua node + edge dalam satu topic
-- =============================================================

CREATE OR REPLACE VIEW node_graph AS
WITH topic_nodes AS (
    -- ROOT: topic = discussion_rooms
    SELECT
        dr.id::TEXT || '-topic'           AS node_id,
        'topic'::VARCHAR(20)              AS node_type,
        dr.title                           AS label,
        dr.id                              AS topic_id,
        NULL::UUID                         AS parent_id,
        1.0000::DECIMAL(5,4)              AS relevance_score,
        'root'::VARCHAR(20)               AS cluster
    FROM discussion_rooms dr
    WHERE dr.is_active = true
),
opinion_nodes AS (
    -- Level 2: opinions/pendapat
    SELECT
        o.id::TEXT || '-opinion'          AS node_id,
        'opinion'::VARCHAR(20)            AS node_type,
        left(o.content, 80)                AS label,
        o.room_id                          AS topic_id,
        o.id                               AS parent_id,
        COALESCE(o.relevance_score, 0.5000) AS relevance_score,
        'opinion'::VARCHAR(20)            AS cluster
    FROM opinions o
    JOIN discussion_rooms dr ON dr.id = o.room_id AND dr.is_active = true
),
comment_nodes AS (
    -- Level 3: comments on opinions
    SELECT
        dc.id::TEXT || '-comment'         AS node_id,
        'comment'::VARCHAR(20)            AS node_type,
        left(dc.content, 80)               AS label,
        o.room_id                          AS topic_id,
        dc.opinion_id                      AS parent_id,
        COALESCE(dc.relevance_score, 0.5000) AS relevance_score,
        'comment'::VARCHAR(20)            AS cluster
    FROM discussion_comments dc
    JOIN opinions o ON o.id = dc.opinion_id
    JOIN discussion_rooms dr ON dr.id = o.room_id AND dr.is_active = true
),
all_nodes AS (
    SELECT * FROM topic_nodes
    UNION ALL
    SELECT * FROM opinion_nodes
    UNION ALL
    SELECT * FROM comment_nodes
),
edges AS (
    -- Edge: topic → opinion (weight = relevance opinion ke topic)
    SELECT
        o.room_id::TEXT || '-topic'       AS source_id,
        o.id::TEXT || '-opinion'          AS target_id,
        COALESCE(o.relevance_score, 0.5000) AS weight,
        'topic-opinion'::VARCHAR(20)      AS edge_type
    FROM opinions o
    UNION ALL
    -- Edge: opinion → comment (weight = relevance comment ke opinion)
    SELECT
        dc.opinion_id::TEXT || '-opinion' AS source_id,
        dc.id::TEXT || '-comment'         AS target_id,
        COALESCE(dc.relevance_score, 0.5000) AS weight,
        'opinion-comment'::VARCHAR(20)    AS edge_type
    FROM discussion_comments dc
)
SELECT
    'node'::VARCHAR(10) AS row_type,
    n.node_id,
    n.node_type,
    n.label,
    n.topic_id,
    n.parent_id,
    n.relevance_score,
    n.cluster,
    NULL::TEXT AS source_id,
    NULL::TEXT AS target_id,
    NULL::DECIMAL(5,4) AS edge_weight,
    NULL::VARCHAR(20) AS edge_type
FROM all_nodes n
UNION ALL
SELECT
    'edge'::VARCHAR(10) AS row_type,
    NULL::TEXT AS node_id,
    NULL::VARCHAR(20) AS node_type,
    NULL::VARCHAR AS label,
    NULL::UUID AS topic_id,
    NULL::UUID AS parent_id,
    NULL::DECIMAL(5,4) AS relevance_score,
    NULL::VARCHAR(20) AS cluster,
    e.source_id,
    e.target_id,
    e.weight AS edge_weight,
    e.edge_type
FROM edges e
WHERE EXISTS (
    SELECT 1 FROM all_nodes n1 WHERE n1.node_id = e.source_id
)
AND EXISTS (
    SELECT 1 FROM all_nodes n2 WHERE n2.node_id = e.target_id
);

-- =============================================================
-- VIEW: Relevance Ranking — opini ranking per topic
-- =============================================================

CREATE OR REPLACE VIEW opinion_ranking AS
SELECT
    dr.id                                AS topic_id,
    dr.title                             AS topic_title,
    o.id                                 AS opinion_id,
    LEFT(o.content, 120)                 AS opinion_preview,
    u.full_name                          AS author_name,
    COALESCE(o.relevance_score, 0.5000)  AS relevance_score,
    COUNT(DISTINCT dc.id)                AS comment_count,
    COUNT(DISTINCT r.id)                 AS reaction_count,
    DENSE_RANK() OVER (
        PARTITION BY dr.id
        ORDER BY COALESCE(o.relevance_score, 0.5000) DESC,
                 COUNT(DISTINCT dc.id) DESC
    )                                    AS rank
FROM opinions o
JOIN discussion_rooms dr ON dr.id = o.room_id
JOIN users u ON u.id = o.user_id
LEFT JOIN discussion_comments dc ON dc.opinion_id = o.id
LEFT JOIN reactions r ON r.target_type = 'opinion' AND r.target_id = o.id
WHERE dr.is_active = true
GROUP BY dr.id, dr.title, o.id, o.content, u.full_name, o.relevance_score
ORDER BY dr.title, rank;

-- =============================================================
-- FUNCTION: Get Graph Data for a Topic (JSON-ready)
-- Return SET of RECORD untuk frontend force-graph
-- =============================================================

CREATE OR REPLACE FUNCTION get_topic_graph(p_topic_id UUID)
RETURNS TABLE (
    nodes      JSONB,
    edges      JSONB
) AS $$
DECLARE
    v_nodes JSONB;
    v_edges JSONB;
BEGIN
    -- Build nodes array
    SELECT jsonb_agg(jsonb_build_object(
        'id', n.node_id,
        'type', n.node_type,
        'label', n.label,
        'relevance_score', n.relevance_score,
        'cluster', n.cluster,
        'size', CASE n.node_type
            WHEN 'topic' THEN 20
            WHEN 'opinion' THEN 12
            WHEN 'comment' THEN 7
        END
    ))
    INTO v_nodes
    FROM (
        -- Topic node
        SELECT
            id::TEXT || '-topic' AS node_id,
            'topic' AS node_type,
            title AS label,
            1.0000::DECIMAL(5,4) AS relevance_score,
            'root' AS cluster
        FROM discussion_rooms WHERE id = p_topic_id
        UNION ALL
        -- Opinion nodes
        SELECT
            o.id::TEXT || '-opinion',
            'opinion',
            LEFT(o.content, 100),
            COALESCE(o.relevance_score, 0.5000),
            'opinion'
        FROM opinions o WHERE o.room_id = p_topic_id
        UNION ALL
        -- Comment nodes (via opinions in this topic)
        SELECT
            dc.id::TEXT || '-comment',
            'comment',
            LEFT(dc.content, 100),
            COALESCE(dc.relevance_score, 0.5000),
            'comment'
        FROM discussion_comments dc
        JOIN opinions o ON o.id = dc.opinion_id
        WHERE o.room_id = p_topic_id
    ) n;

    -- Build edges array
    SELECT jsonb_agg(jsonb_build_object(
        'source', e.source_id,
        'target', e.target_id,
        'weight', e.weight,
        'type', e.edge_type
    ))
    INTO v_edges
    FROM (
        -- Topic → Opinion edges
        SELECT
            o.room_id::TEXT || '-topic' AS source_id,
            o.id::TEXT || '-opinion' AS target_id,
            COALESCE(o.relevance_score, 0.5000) AS weight,
            'topic-opinion' AS edge_type
        FROM opinions o WHERE o.room_id = p_topic_id
        UNION ALL
        -- Opinion → Comment edges
        SELECT
            dc.opinion_id::TEXT || '-opinion',
            dc.id::TEXT || '-comment',
            COALESCE(dc.relevance_score, 0.5000),
            'opinion-comment'
        FROM discussion_comments dc
        JOIN opinions o ON o.id = dc.opinion_id
        WHERE o.room_id = p_topic_id
    ) e
    WHERE EXISTS (SELECT 1 FROM jsonb_array_elements(v_nodes) n WHERE n->>'id' = e.source_id)
      AND EXISTS (SELECT 1 FROM jsonb_array_elements(v_nodes) n WHERE n->>'id' = e.target_id);

    RETURN QUERY SELECT v_nodes, v_edges;
END;
$$ LANGUAGE plpgsql;

-- =============================================================
-- FUNCTION: Cari tetangga terdekat (semantic search)
-- Buat fitur "ide serupa" di node graph
-- =============================================================

CREATE OR REPLACE FUNCTION find_similar_opinions(
    p_opinion_id UUID,
    p_limit INTEGER DEFAULT 5
)
RETURNS TABLE (
    similar_id      UUID,
    content         TEXT,
    cosine_distance DECIMAL(5,4),
    topic_title     VARCHAR(255)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        o2.id,
        LEFT(o2.content, 150),
        (o.embedding <=> o2.embedding)::DECIMAL(5,4) AS cosine_distance,
        dr.title
    FROM opinions o
    JOIN opinions o2 ON o2.id != o.id AND o2.room_id = o.room_id
    JOIN discussion_rooms dr ON dr.id = o2.room_id
    WHERE o.id = p_opinion_id
      AND o.embedding IS NOT NULL
      AND o2.embedding IS NOT NULL
    ORDER BY o.embedding <=> o2.embedding
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- =============================================================
-- FUNCTION: Auto-update relevance_score saat embedding diisi
-- Hook untuk Python backend: cukup update embedding, score otomatis
-- =============================================================

CREATE OR REPLACE FUNCTION auto_compute_opinion_relevance()
RETURNS TRIGGER AS $$
DECLARE
    topic_embedding VECTOR(384);
BEGIN
    -- Hitung cosine similarity antara opinion embedding & (nanti) topic embedding
    -- Sementara default 0.5, nanti di-refresh oleh Python ML backend
    IF NEW.embedding IS NOT NULL THEN
        NEW.relevance_score = 0.5000;  -- placeholder, ML backend overwrite
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: auto-set relevance saat embedding diisi
-- NOTE: di-production, relevance_score di-refresh batch oleh Python FastAPI,
-- bukan per-row trigger (biar tidak slow)
-- CREATE TRIGGER compute_opinion_relevance
--     BEFORE INSERT OR UPDATE OF embedding ON opinions
--     FOR EACH ROW EXECUTE FUNCTION auto_compute_opinion_relevance();

-- =============================================================
-- NOTE untuk Developer:
--
-- 1. Embedding di-generate oleh Python FastAPI (sentence-transformers)
-- 2. Relevance score dihitung oleh Cross-Encoder (pairwise)
-- 3. Python hitung: relevance(topic, opinion) dan relevance(opinion, comment)
-- 4. Simpan hasil ke kolom relevance_score
-- 5. Frontend panggil get_topic_graph(uuid) untuk data force-graph
-- 6. Outlier = opinion dgn relevance_score < threshold (misal < 0.3)
--    -> frontend skip edge-nya, node di pinggir
-- 7. IVFFlat index untuk cosine similarity search
--
-- Contoh query Python:
--   UPDATE opinions SET relevance_score = $1 WHERE id = $2;
--   UPDATE discussion_comments SET relevance_score = $1 WHERE id = $2;
-- =============================================================
