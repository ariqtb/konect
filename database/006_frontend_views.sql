-- ============================================================================
-- Konect - Frontend Contract (Views, Functions, Link Table)
-- PostgreSQL Migration v1.3 (rewritten)
--
-- Strategi: 003 (hackathon Kemenkop) adalah source of truth untuk koperasi.
--            001 (Konect app) untuk data app: users, discussion, voting, dll.
--            001.cooperatives jadi "stub" tipis — hanya kolom + legacy_ref
--            link ke 003.profil_koperasi. Tidak ada ETL, tidak ada duplikasi.
--
-- Isi file ini:
--   1. ALTER cooperatives: tambah legacy_ref (link ke 003)
--   2. CREATE room_participants: M2M discussion_rooms <-> users (Konect app)
--   3. Views/functions untuk kontrak JSON frontend (2A, 2B, 2C, 2D, 2E, 2F)
--
-- Dependencies: 001, 002, 003 harus sudah jalan, dan 003 sudah ter-load
--               (via database/import_data.sh atau LOAD DATA manual).
-- ============================================================================

-- ============================================================================
-- 1. LINK: 001.cooperatives.legacy_ref → 003.profil_koperasi.koperasi_ref
--    1 kolom saja, bukan ETL — hanya pointer supaya 001 tables bisa join ke 003.
-- ============================================================================

ALTER TABLE cooperatives
    ADD COLUMN IF NOT EXISTS legacy_ref VARCHAR(30);

CREATE UNIQUE INDEX IF NOT EXISTS idx_cooperatives_legacy_ref
    ON cooperatives(legacy_ref)
    WHERE legacy_ref IS NOT NULL;

COMMENT ON COLUMN cooperatives.legacy_ref
    IS 'Pointer ke 003.profil_koperasi.koperasi_ref. Nullable karena Konect app bisa bikin koperasi tanpa link ke Kemenkop.';

-- ============================================================================
-- 2. TABLE: room_participants (M2M discussion_rooms <-> users, Konect app)
--    Sumber: 2E rooms[].membersCount, rooms[].avatars
-- ============================================================================

CREATE TABLE IF NOT EXISTS room_participants (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_id     UUID NOT NULL REFERENCES discussion_rooms(id) ON DELETE CASCADE,
    user_id     UUID NOT NULL REFERENCES users(id)            ON DELETE CASCADE,
    role        VARCHAR(20) NOT NULL DEFAULT 'participant',
    joined_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(room_id, user_id)
);

COMMENT ON TABLE room_participants IS
    'Partisipan ruang diskusi — sumber rooms[].membersCount & avatars untuk 2E';

CREATE INDEX IF NOT EXISTS idx_room_participants_room ON room_participants(room_id);
CREATE INDEX IF NOT EXISTS idx_room_participants_user ON room_participants(user_id);

-- ============================================================================
-- 3. VIEWS & FUNCTIONS
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 2A. v_forum_topics — list topik diskusi (Konect app: 001 discussion_rooms)
-- ---------------------------------------------------------------------------

CREATE OR REPLACE VIEW v_forum_topics AS
SELECT
    dr.id,
    dr.title,
    LEFT(COALESCE(dr.description, ''), 200)             AS preview,
    (SELECT COUNT(*) FROM opinions o WHERE o.room_id = dr.id) AS opinion_count,
    (SELECT COUNT(*) FROM discussion_comments dc
        JOIN opinions o ON o.id = dc.opinion_id
        WHERE o.room_id = dr.id)                         AS comment_count,
    CASE WHEN dr.is_anonymous THEN 'Anonim' ELSE u.full_name END AS author_name,
    dr.created_at,
    dr.cooperative_id
FROM discussion_rooms dr
JOIN users u ON u.id = dr.created_by
WHERE dr.is_active = true;

-- ---------------------------------------------------------------------------
-- 2B. get_voting_items — list pendapat + vote count, per-user reaction
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION get_voting_items(p_user_id UUID)
RETURNS TABLE (
    id UUID,
    opinion TEXT,
    agree_count BIGINT,
    disagree_count BIGINT,
    like_count BIGINT,
    user_reaction reaction_type,
    topic_id UUID,
    topic_title TEXT,
    author_id UUID,
    author_name TEXT,
    created_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        o.id,
        o.content                                       AS opinion,
        (SELECT COUNT(*) FROM reactions r
            WHERE r.target_type = 'opinion' AND r.target_id = o.id
              AND r.reaction = 'agree')::BIGINT         AS agree_count,
        (SELECT COUNT(*) FROM reactions r
            WHERE r.target_type = 'opinion' AND r.target_id = o.id
              AND r.reaction = 'disagree')::BIGINT      AS disagree_count,
        (SELECT COUNT(*) FROM reactions r
            WHERE r.target_type = 'opinion' AND r.target_id = o.id
              AND r.reaction = 'like')::BIGINT          AS like_count,
        (SELECT r.reaction FROM reactions r
            WHERE r.target_type = 'opinion' AND r.target_id = o.id
              AND r.user_id = p_user_id
            LIMIT 1)                                    AS user_reaction,
        dr.id                                           AS topic_id,
        dr.title                                        AS topic_title,
        o.user_id                                       AS author_id,
        CASE WHEN o.is_anonymous THEN 'Anonim' ELSE u.full_name END AS author_name,
        o.created_at
    FROM opinions o
    JOIN discussion_rooms dr ON dr.id = o.room_id
    JOIN users u             ON u.id = o.user_id
    WHERE dr.is_active = true
    ORDER BY o.created_at DESC;
END;
$$ LANGUAGE plpgsql STABLE;

-- ---------------------------------------------------------------------------
-- 2D. get_nearby_cooperatives — READ DARI 003.profil_koperasi
--     category dari 003.kategori_usaha
--     is_open derived dari status_registrasi='Approved'
--     id = koperasi_ref (VARCHAR, karena 003 pakai text PK)
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION get_nearby_cooperatives(
    p_user_lat DECIMAL,
    p_user_lng DECIMAL,
    p_limit INTEGER DEFAULT 50
)
RETURNS TABLE (
    id VARCHAR,
    name TEXT,
    address TEXT,
    image_url TEXT,
    category VARCHAR,
    is_open BOOLEAN,
    latitude DECIMAL,
    longitude DECIMAL,
    distance_meters INTEGER,
    distance_text TEXT
) AS $$
DECLARE
    lat DECIMAL;
    lng DECIMAL;
    d_m INTEGER;
BEGIN
    RETURN QUERY
    SELECT
        pk.koperasi_ref                                       AS id,
        pk.nama_koperasi                                      AS name,
        pk.alamat_lengkap                                     AS address,
        NULL::TEXT                                           AS image_url,
        pk.kategori_usaha                                     AS category,
        (pk.status_registrasi = 'Approved')                  AS is_open,
        -- parse "lat, lng"
        CASE WHEN pk.koordinat_dibulatkan ~ '^-?[0-9]+\.[0-9]+,\s*-?[0-9]+\.[0-9]+$'
            THEN split_part(pk.koordinat_dibulatkan, ',', 1)::DECIMAL(10,7)
        END                                                  AS latitude,
        CASE WHEN pk.koordinat_dibulatkan ~ '^-?[0-9]+\.[0-9]+,\s*-?[0-9]+\.[0-9]+$'
            THEN split_part(pk.koordinat_dibulatkan, ',', 2)::DECIMAL(10,7)
        END                                                  AS longitude,
        CASE WHEN pk.koordinat_dibulatkan ~ '^-?[0-9]+\.[0-9]+,\s*-?[0-9]+\.[0-9]+$'
            THEN haversine_distance(
                p_user_lat, p_user_lng,
                split_part(pk.koordinat_dibulatkan, ',', 1)::DECIMAL(10,7),
                split_part(pk.koordinat_dibulatkan, ',', 2)::DECIMAL(10,7))
        END                                                  AS distance_meters,
        CASE
            WHEN pk.koordinat_dibulatkan !~ '^-?[0-9]+\.[0-9]+,\s*-?[0-9]+\.[0-9]+$' THEN NULL
            WHEN haversine_distance(
                p_user_lat, p_user_lng,
                split_part(pk.koordinat_dibulatkan, ',', 1)::DECIMAL(10,7),
                split_part(pk.koordinat_dibulatkan, ',', 2)::DECIMAL(10,7)) < 1000
            THEN haversine_distance(
                p_user_lat, p_user_lng,
                split_part(pk.koordinat_dibulatkan, ',', 1)::DECIMAL(10,7),
                split_part(pk.koordinat_dibulatkan, ',', 2)::DECIMAL(10,7))::TEXT || 'm dari lokasimu'
            ELSE ROUND(haversine_distance(
                p_user_lat, p_user_lng,
                split_part(pk.koordinat_dibulatkan, ',', 1)::DECIMAL(10,7),
                split_part(pk.koordinat_dibulatkan, ',', 2)::DECIMAL(10,7))::NUMERIC / 1000, 1)::TEXT || 'km dari lokasimu'
        END                                                  AS distance_text
    FROM profil_koperasi pk
    WHERE pk.status_registrasi = 'Approved'
    ORDER BY distance_meters ASC NULLS LAST
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE;

-- ---------------------------------------------------------------------------
-- 2E. get_cooperative_detail — COMPOSITE: 003 (profil/pengurus/anggota) +
--                                  001 (rooms, updates)
--     p_coop_ref: 003.profil_koperasi.koperasi_ref (text)
--     rooms[]: 001 discussion_rooms WHERE 001.cooperatives.legacy_ref = p_coop_ref
--     updates[]: 001 articles (type hardcoded 'info' — Q3, no type column in 001)
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION get_cooperative_detail(p_coop_ref VARCHAR)
RETURNS JSONB AS $$
DECLARE
    v_profil JSONB;
    v_rooms JSONB;
    v_updates JSONB;
BEGIN
    -- Profil + ketua + member_count (semua dari 003)
    SELECT jsonb_build_object(
        'coop_id',       pk.koperasi_ref,
        'name',          pk.nama_koperasi,
        'address',       pk.alamat_lengkap,
        'description',   pk.tentang_koperasi,
        'category',      pk.kategori_usaha,
        'is_open',       (pk.status_registrasi = 'Approved'),
        'legal_status',  pk.bentuk_koperasi,
        'phone', (
            SELECT p.no_hp FROM pengurus_koperasi p
            WHERE p.koperasi_ref = pk.koperasi_ref
            ORDER BY p.periode_mulai DESC NULLS LAST LIMIT 1
        ),
        'email', (
            SELECT p.email FROM pengurus_koperasi p
            WHERE p.koperasi_ref = pk.koperasi_ref
            ORDER BY p.periode_mulai DESC NULLS LAST LIMIT 1
        ),
        'image_url', NULL::TEXT,
        'chairperson', (
            SELECT p.nama FROM pengurus_koperasi p
            WHERE p.koperasi_ref = pk.koperasi_ref AND p.jabatan = 'Ketua'
            ORDER BY p.periode_mulai DESC NULLS LAST LIMIT 1
        ),
        'member_count', (
            SELECT COUNT(*) FROM anggota_koperasi ak
            WHERE ak.koperasi_ref = pk.koperasi_ref
        )
    ) INTO v_profil
    FROM profil_koperasi pk
    WHERE pk.koperasi_ref = p_coop_ref;

    IF v_profil IS NULL THEN
        RETURN NULL;
    END IF;

    -- Q2: rooms dari 001 (Konect app: discussion_rooms)
    -- Link via 001.cooperatives.legacy_ref
    SELECT COALESCE(jsonb_agg(room_data ORDER BY dr_created_at DESC), '[]'::jsonb)
        INTO v_rooms
    FROM (
        SELECT
            jsonb_build_object(
                'id', dr.id,
                'title', dr.title,
                'description', dr.description,
                'status', CASE WHEN dr.is_active THEN 'Aktif' ELSE 'Selesai' END,
                'date', to_char(dr.created_at, 'DD Mon YYYY'),
                'members_count', (SELECT COUNT(*) FROM room_participants rp WHERE rp.room_id = dr.id),
                'avatars', COALESCE((
                    SELECT jsonb_agg(u.avatar_color)
                    FROM (
                        SELECT rp2.user_id
                        FROM room_participants rp2
                        WHERE rp2.room_id = dr.id
                        ORDER BY rp2.joined_at ASC
                        LIMIT 3
                    ) p
                    JOIN users u ON u.id = p.user_id
                ), '[]'::jsonb)
            ) AS room_data,
            dr.created_at AS dr_created_at
        FROM discussion_rooms dr
        JOIN cooperatives c ON c.id = dr.cooperative_id
        WHERE c.legacy_ref = p_coop_ref
    ) rooms;

    -- Q3: updates dari 001 articles, type hardcoded 'info' (no type column di 001)
    SELECT COALESCE(jsonb_agg(update_data ORDER BY a_created_at DESC), '[]'::jsonb)
        INTO v_updates
    FROM (
        SELECT
            jsonb_build_object(
                'id', a.id,
                'title', a.title,
                'description', a.content,
                'date', to_char(a.created_at, 'DD Mon YYYY'),
                'type', 'info'
            ) AS update_data,
            a.created_at AS a_created_at
        FROM articles a
        JOIN cooperatives c ON c.id = a.cooperative_id
        WHERE c.legacy_ref = p_coop_ref
        LIMIT 10
    ) updates;

    RETURN v_profil
        || jsonb_build_object('rooms', v_rooms, 'updates', v_updates);
END;
$$ LANGUAGE plpgsql STABLE;

-- ---------------------------------------------------------------------------
-- 2F. get_room_canvas — untuk room_discussion_page.dart
--     Topic + opinions + comments (canvas Topic→Opinion→Comment, dari 001)
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION get_room_canvas(p_room_id UUID)
RETURNS JSONB AS $$
DECLARE
    v_topic JSONB;
    v_opinions JSONB;
BEGIN
    SELECT jsonb_build_object(
        'id', dr.id,
        'title', dr.title,
        'description', dr.description,
        'is_active', dr.is_active,
        'is_anonymous', dr.is_anonymous,
        'cooperative_id', dr.cooperative_id,
        'cooperative_ref', c.legacy_ref,                        -- link ke 003
        'cooperative_name', (
            SELECT nama_koperasi FROM profil_koperasi
            WHERE koperasi_ref = c.legacy_ref
        ),
        'created_by', dr.created_by,
        'created_at', dr.created_at
    ) INTO v_topic
    FROM discussion_rooms dr
    LEFT JOIN cooperatives c ON c.id = dr.cooperative_id         -- link ke 001 stub
    WHERE dr.id = p_room_id;

    IF v_topic IS NULL THEN
        RETURN NULL;
    END IF;

    SELECT COALESCE(jsonb_agg(opinion_data ORDER BY o_created_at ASC), '[]'::jsonb)
        INTO v_opinions
    FROM (
        SELECT
            jsonb_build_object(
                'id', o.id,
                'text', o.content,
                'is_anonymous', o.is_anonymous,
                'user_id', o.user_id,
                'author_name', CASE WHEN o.is_anonymous THEN 'Anonim' ELSE u.full_name END,
                'likes', (SELECT COUNT(*) FROM reactions r
                            WHERE r.target_type = 'opinion' AND r.target_id = o.id
                              AND r.reaction = 'like')::INTEGER,
                'agree_count', (SELECT COUNT(*) FROM reactions r
                            WHERE r.target_type = 'opinion' AND r.target_id = o.id
                              AND r.reaction = 'agree')::INTEGER,
                'disagree_count', (SELECT COUNT(*) FROM reactions r
                            WHERE r.target_type = 'opinion' AND r.target_id = o.id
                              AND r.reaction = 'disagree')::INTEGER,
                'comments', COALESCE((
                    SELECT jsonb_agg(dc.content ORDER BY dc.created_at ASC)
                    FROM discussion_comments dc
                    WHERE dc.opinion_id = o.id
                ), '[]'::jsonb),
                'created_at', o.created_at,
                'latitude', o.latitude,
                'longitude', o.longitude,
                'relevance_score', o.relevance_score
            ) AS opinion_data,
            o.created_at AS o_created_at
        FROM opinions o
        JOIN users u ON u.id = o.user_id
        WHERE o.room_id = p_room_id
    ) opinions_with_meta;

    RETURN v_topic || jsonb_build_object('opinions', v_opinions);
END;
$$ LANGUAGE plpgsql STABLE;

-- ---------------------------------------------------------------------------
-- 2C. get_leaderboard — Q4: TIDAK ada avatar_url, hanya avatar_color
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION get_leaderboard(p_user_id UUID, p_limit INTEGER DEFAULT 50)
RETURNS TABLE (
    id UUID,
    name TEXT,
    username TEXT,
    avatar_color VARCHAR,
    score INTEGER,
    village_id UUID,
    village_name TEXT,
    rank BIGINT,
    is_current_user BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        u.id,
        u.full_name::TEXT                                AS name,
        u.username::TEXT,
        u.avatar_color,
        u.points_balance                                 AS score,
        u.village_id,
        v.name                                           AS village_name,
        DENSE_RANK() OVER (ORDER BY u.points_balance DESC) AS rank,
        (u.id = p_user_id)                               AS is_current_user
    FROM users u
    LEFT JOIN villages v ON v.id = u.village_id
    WHERE u.is_active = true
    ORDER BY u.points_balance DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE;
