-- =============================================================
-- Konect (Koperasi Connect) - Rooms Migration
-- PostgreSQL Migration v1.0
--
-- Migration dedicated untuk `discussion_rooms` (Topic/Room).
-- Table ini adalah ROOT NODE dalam hierarki diskusi:
--   Topic/Room → Pendapat/Opini → Komentar
--
-- Prerequisites: 001_init_schema.sql (cooperatives, users)
-- =============================================================

-- =============================================================
-- DISCUSSION ROOMS (Ruang Diskusi / Topik)
-- Level 1 di hierarki: Topic (akar dari diskusi)
--
-- Setiap room adalah "topik diskusi" yang dibuat oleh admin
-- atau pengurus koperasi. Warga bisa memberikan pendapat/opini
-- di dalam room ini.
-- =============================================================

-- NOTE: Jika migrate dari 001_init_schema.sql yang sudah include
-- tabel ini, gunakan:
--   CREATE TABLE IF NOT EXISTS group3b_discussion_rooms (...)
-- atau skip jika sudah ada.
--
-- Hackathon shared-DB pakai prefix `group3b_`.
-- Di local development cukup `discussion_rooms`.

CREATE TABLE IF NOT EXISTS discussion_rooms (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cooperative_id  UUID NOT NULL REFERENCES cooperatives(id) ON DELETE CASCADE,
    created_by      UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    title           VARCHAR(255) NOT NULL,
    description     TEXT,
    is_active       BOOLEAN NOT NULL DEFAULT true,
    is_anonymous    BOOLEAN NOT NULL DEFAULT false,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =============================================================
-- INDEXES
-- =============================================================

CREATE INDEX IF NOT EXISTS idx_discussion_rooms_coop
    ON discussion_rooms(cooperative_id);

CREATE INDEX IF NOT EXISTS idx_discussion_rooms_active
    ON discussion_rooms(is_active);

CREATE INDEX IF NOT EXISTS idx_discussion_rooms_created_by
    ON discussion_rooms(created_by);

CREATE INDEX IF NOT EXISTS idx_discussion_rooms_created_at
    ON discussion_rooms(cooperative_id, created_at DESC);

-- =============================================================
-- TRIGGER: auto-update updated_at
-- =============================================================

CREATE OR REPLACE FUNCTION trigger_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_updated_at_discussion_rooms ON discussion_rooms;

CREATE TRIGGER set_updated_at_discussion_rooms
    BEFORE UPDATE ON discussion_rooms
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_updated_at();

-- =============================================================
-- HELPER: Create a new discussion room
-- =============================================================

CREATE OR REPLACE FUNCTION create_discussion_room(
    p_cooperative_id UUID,
    p_created_by UUID,
    p_title VARCHAR(255),
    p_description TEXT DEFAULT NULL,
    p_is_anonymous BOOLEAN DEFAULT false
)
RETURNS SETOF discussion_rooms AS $$
BEGIN
    RETURN QUERY
    INSERT INTO discussion_rooms (
        cooperative_id,
        created_by,
        title,
        description,
        is_anonymous
    ) VALUES (
        p_cooperative_id,
        p_created_by,
        p_title,
        p_description,
        p_is_anonymous
    )
    RETURNING *;
END;
$$ LANGUAGE plpgsql;

-- =============================================================
-- HELPER: Get active rooms for a cooperative (dengan metadata)
-- =============================================================

CREATE OR REPLACE FUNCTION get_cooperative_rooms(p_cooperative_id UUID)
RETURNS TABLE (
    id              UUID,
    title           VARCHAR(255),
    description     TEXT,
    created_by_name VARCHAR(255),
    is_anonymous    BOOLEAN,
    opinion_count   BIGINT,
    created_at      TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        dr.id,
        dr.title,
        dr.description,
        u.full_name AS created_by_name,
        dr.is_anonymous,
        COUNT(o.id)::BIGINT AS opinion_count,
        dr.created_at
    FROM discussion_rooms dr
    JOIN users u ON u.id = dr.created_by
    LEFT JOIN opinions o ON o.room_id = dr.id
    WHERE dr.cooperative_id = p_cooperative_id
      AND dr.is_active = true
    GROUP BY dr.id, dr.title, dr.description, u.full_name, dr.is_anonymous, dr.created_at
    ORDER BY dr.created_at DESC;
END;
$$ LANGUAGE plpgsql;
