-- =============================================================
-- Konect (Koperasi Connect) - Database Schema
-- PostgreSQL Migration v1.0
--
-- Platform desa untuk koperasi: diskusi/forum,
-- poin/reward, leaderboard, dan manajemen koperasi.
--
-- Hierarchy: Topic → Pendapat/Ide (vote) → Komentar
-- pgvector untuk ML relevance scoring + node graph
-- =============================================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS vector;              -- pgvector: ML embeddings similarity search

-- =============================================================
-- ENUMS
-- =============================================================

CREATE TYPE user_role AS ENUM ('admin', 'warga');
CREATE TYPE member_role AS ENUM ('ketua', 'bendahara', 'anggota');
CREATE TYPE reaction_type AS ENUM ('agree', 'disagree', 'like');
CREATE TYPE redemption_status AS ENUM ('pending', 'completed', 'cancelled');
CREATE TYPE transaction_type AS ENUM (
    'earn_discussion',
    'earn_signup_bonus',
    'earn_daily',
    'redeem_voucher',
    'admin_adjust'
);

-- =============================================================
-- VILLAGES (Desa)
-- =============================================================

CREATE TABLE villages (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        VARCHAR(255) NOT NULL,
    slug        VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    address     TEXT,
    logo_url    TEXT,
    is_active   BOOLEAN NOT NULL DEFAULT true,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_villages_slug ON villages(slug);
CREATE INDEX idx_villages_active ON villages(is_active);

-- =============================================================
-- USERS (Warga)
-- =============================================================

CREATE TABLE users (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    village_id      UUID NOT NULL REFERENCES villages(id) ON DELETE RESTRICT,
    email           VARCHAR(255) NOT NULL UNIQUE,
    username        VARCHAR(100) NOT NULL UNIQUE,
    full_name       VARCHAR(255) NOT NULL,
    password_hash   TEXT NOT NULL,
    avatar_color    VARCHAR(7),              -- hex color for blob avatar
    role            user_role NOT NULL DEFAULT 'warga',
    points_balance  INTEGER NOT NULL DEFAULT 0 CHECK (points_balance >= 0),
    is_active       BOOLEAN NOT NULL DEFAULT true,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_users_village ON users(village_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_points ON users(points_balance DESC);

-- =============================================================
-- COOPERATIVES (Koperasi Desa)
-- =============================================================

CREATE TABLE cooperatives (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    village_id    UUID NOT NULL REFERENCES villages(id) ON DELETE RESTRICT,
    name          VARCHAR(255) NOT NULL,
    slug          VARCHAR(255) NOT NULL UNIQUE,
    description   TEXT,
    address       TEXT,
    image_url     TEXT,
    contact_phone VARCHAR(20),
    latitude      DECIMAL(10,7),            -- titik lokasi kopdes
    longitude     DECIMAL(10,7),            -- titik lokasi kopdes
    proximity_radius_meters INTEGER NOT NULL DEFAULT 200 CHECK (proximity_radius_meters > 0),
    is_active     BOOLEAN NOT NULL DEFAULT true,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_cooperatives_village ON cooperatives(village_id);
CREATE INDEX idx_cooperatives_slug ON cooperatives(slug);
CREATE INDEX idx_cooperatives_active ON cooperatives(is_active);

-- =============================================================
-- COOPERATIVE MEMBERS (Anggota Koperasi)
-- =============================================================

CREATE TABLE cooperative_members (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cooperative_id  UUID NOT NULL REFERENCES cooperatives(id) ON DELETE CASCADE,
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role            member_role NOT NULL DEFAULT 'anggota',
    joined_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(cooperative_id, user_id)
);

CREATE INDEX idx_coop_members_cooperative ON cooperative_members(cooperative_id);
CREATE INDEX idx_coop_members_user ON cooperative_members(user_id);

-- =============================================================
-- TOPICS — DISCUSSION ROOMS (Ruang Diskusi / Topik)
-- Level 1 di hierarki: Topic
-- =============================================================

CREATE TABLE discussion_rooms (
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

CREATE INDEX idx_discussion_rooms_coop ON discussion_rooms(cooperative_id);
CREATE INDEX idx_discussion_rooms_active ON discussion_rooms(is_active);

-- =============================================================
-- OPINIONS (Pendapat / Ide)
-- Level 2 di hierarki: Topic → Pendapat
-- Node utama dalam graph visualization.
--
-- OPINION = VOTE. Setiap pendapat adalah "suara" warga.
-- Voting di-realisasi lewat reactions (agree/disagree).
-- =============================================================

CREATE TABLE opinions (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_id         UUID NOT NULL REFERENCES discussion_rooms(id) ON DELETE CASCADE,
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    content         TEXT NOT NULL,
    is_anonymous    BOOLEAN NOT NULL DEFAULT false,
    latitude        DECIMAL(10,7) NOT NULL,  -- lokasi user saat mengirim pendapat
    longitude       DECIMAL(10,7) NOT NULL,  -- lokasi user saat mengirim pendapat
    embedding       VECTOR(384),              -- pgvector: semantic embedding utk ML relevance (384d = all-MiniLM-L6-v2)
    relevance_score DECIMAL(5,4),             -- ML relevance thd topic (0.0000-1.0000), di-refresh periodik
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_opinions_room ON opinions(room_id);
CREATE INDEX idx_opinions_user ON opinions(user_id);
CREATE INDEX idx_opinions_relevance ON opinions(room_id, relevance_score DESC NULLS LAST);
CREATE INDEX idx_opinions_embedding ON opinions USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- =============================================================
-- DISCUSSION COMMENTS (Komentar pada Pendapat)
-- Level 3 di hierarki: Topic → Pendapat → Komentar
-- =============================================================

CREATE TABLE discussion_comments (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    opinion_id      UUID NOT NULL REFERENCES opinions(id) ON DELETE CASCADE,
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    parent_id       UUID REFERENCES discussion_comments(id) ON DELETE CASCADE,  -- reply antar komentar
    content         TEXT NOT NULL,
    is_anonymous    BOOLEAN NOT NULL DEFAULT false,
    latitude        DECIMAL(10,7) NOT NULL,  -- lokasi user saat comment
    longitude       DECIMAL(10,7) NOT NULL,  -- lokasi user saat comment
    embedding       VECTOR(384),              -- pgvector: ML relevance thd opinion induk
    relevance_score DECIMAL(5,4),             -- ML relevance thd opinion (0.0000-1.0000)
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_discussion_comments_opinion ON discussion_comments(opinion_id);
CREATE INDEX idx_discussion_comments_parent ON discussion_comments(parent_id);
CREATE INDEX idx_discussion_comments_user ON discussion_comments(user_id);
CREATE INDEX idx_discussion_comments_relevance ON discussion_comments(opinion_id, relevance_score DESC NULLS LAST);

-- =============================================================
-- REACTIONS (Reaksi pada pendapat/komentar: Setuju/Tidak/Like)
-- =============================================================
-- Voting diimplementasikan lewat sini:
--   agree  = setuju/vote positif
--   disagree = tidak setuju/vote negatif
--   like   = apresiasi
-- Polymorphic: target_type IN ('opinion', 'comment')
-- =============================================================

CREATE TABLE reactions (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    target_type   VARCHAR(10) NOT NULL CHECK (target_type IN ('opinion', 'comment')),
    target_id     UUID NOT NULL,
    reaction      reaction_type NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(user_id, target_type, target_id)
);

CREATE INDEX idx_reactions_target ON reactions(target_type, target_id);
CREATE INDEX idx_reactions_user ON reactions(user_id);

-- =============================================================
-- ARTICLES (Artikel / Berita Koperasi)
-- =============================================================

CREATE TABLE articles (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cooperative_id  UUID NOT NULL REFERENCES cooperatives(id) ON DELETE CASCADE,
    title           VARCHAR(255) NOT NULL,
    content         TEXT NOT NULL,
    image_url       TEXT,
    created_by      UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_articles_cooperative ON articles(cooperative_id);
CREATE INDEX idx_articles_created ON articles(cooperative_id, created_at DESC);

-- =============================================================
-- VOUCHERS
-- =============================================================

CREATE TABLE vouchers (
    id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cooperative_id    UUID NOT NULL REFERENCES cooperatives(id) ON DELETE CASCADE,
    code              VARCHAR(100) NOT NULL UNIQUE,
    title             VARCHAR(255) NOT NULL,
    description       TEXT,
    points_required   INTEGER NOT NULL CHECK (points_required > 0),
    qr_code_url       TEXT,
    quantity          INTEGER NOT NULL CHECK (quantity >= 0),
    is_active         BOOLEAN NOT NULL DEFAULT true,
    expires_at        TIMESTAMPTZ,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_vouchers_coop ON vouchers(cooperative_id);
CREATE INDEX idx_vouchers_code ON vouchers(code);
CREATE INDEX idx_vouchers_active ON vouchers(is_active);

-- =============================================================
-- VOUCHER REDEMPTIONS (Penukaran Voucher)
-- =============================================================

CREATE TABLE voucher_redemptions (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    voucher_id      UUID NOT NULL REFERENCES vouchers(id) ON DELETE RESTRICT,
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    redeemed_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    qr_code_used    TEXT,
    status          redemption_status NOT NULL DEFAULT 'pending',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(voucher_id, user_id)
);

CREATE INDEX idx_redemptions_voucher ON voucher_redemptions(voucher_id);
CREATE INDEX idx_redemptions_user ON voucher_redemptions(user_id);
CREATE INDEX idx_redemptions_status ON voucher_redemptions(status);

-- =============================================================
-- POINT TRANSACTIONS (Riwayat Poin)
-- =============================================================

CREATE TABLE point_transactions (
    id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id           UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    amount            INTEGER NOT NULL CHECK (amount != 0),
    transaction_type  transaction_type NOT NULL,
    reference_id      UUID,                 -- polymorphic ref ke opinion/comment/dll
    description       TEXT,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_point_tx_user ON point_transactions(user_id);
CREATE INDEX idx_point_tx_type ON point_transactions(transaction_type);
CREATE INDEX idx_point_tx_created ON point_transactions(user_id, created_at DESC);

-- =============================================================
-- TRIGGERS: auto-update updated_at
-- =============================================================

CREATE OR REPLACE FUNCTION trigger_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at_villages
    BEFORE UPDATE ON villages FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
CREATE TRIGGER set_updated_at_users
    BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
CREATE TRIGGER set_updated_at_cooperatives
    BEFORE UPDATE ON cooperatives FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
CREATE TRIGGER set_updated_at_discussion_rooms
    BEFORE UPDATE ON discussion_rooms FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
CREATE TRIGGER set_updated_at_opinions
    BEFORE UPDATE ON opinions FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
CREATE TRIGGER set_updated_at_discussion_comments
    BEFORE UPDATE ON discussion_comments FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
CREATE TRIGGER set_updated_at_articles
    BEFORE UPDATE ON articles FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
CREATE TRIGGER set_updated_at_vouchers
    BEFORE UPDATE ON vouchers FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- =============================================================
-- GEOLOCATION: Haversine Distance (meter)
-- =============================================================

CREATE OR REPLACE FUNCTION haversine_distance(
    lat1 DECIMAL(10,7), lng1 DECIMAL(10,7),
    lat2 DECIMAL(10,7), lng2 DECIMAL(10,7)
) RETURNS INTEGER AS $$
DECLARE
    dlat DECIMAL;
    dlng DECIMAL;
    a DECIMAL;
    c DECIMAL;
    r INTEGER := 6371000;  -- Earth radius in meters
BEGIN
    dlat := radians(lat2 - lat1);
    dlng := radians(lng2 - lng1);
    a := sin(dlat/2)^2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlng/2)^2;
    c := 2 * asin(sqrt(a));
    RETURN (r * c)::INTEGER;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- =============================================================
-- GEOLOCATION: Proximity Check (opinions & comments)
-- =============================================================

CREATE OR REPLACE FUNCTION check_opinion_proximity()
RETURNS TRIGGER AS $$
DECLARE
    coop_lat    DECIMAL(10,7);
    coop_lng    DECIMAL(10,7);
    coop_radius INTEGER;
    distance    INTEGER;
BEGIN
    SELECT c.latitude, c.longitude, c.proximity_radius_meters
    INTO coop_lat, coop_lng, coop_radius
    FROM discussion_rooms dr
    JOIN cooperatives c ON c.id = dr.cooperative_id
    WHERE dr.id = NEW.room_id;

    IF EXISTS (SELECT 1 FROM users WHERE id = NEW.user_id AND role = 'admin') THEN
        RETURN NEW;
    END IF;
    IF coop_lat IS NULL OR coop_lng IS NULL THEN
        RAISE EXCEPTION 'Koperasi belum memiliki lokasi. Hubungi admin.';
    END IF;

    distance := haversine_distance(NEW.latitude, NEW.longitude, coop_lat, coop_lng);
    IF distance > coop_radius THEN
        RAISE EXCEPTION 'Anda terlalu jauh dari koperasi (jarak: % m, maks: % m).', distance, coop_radius;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_opinion_proximity
    BEFORE INSERT ON opinions
    FOR EACH ROW EXECUTE FUNCTION check_opinion_proximity();

CREATE OR REPLACE FUNCTION check_comment_proximity()
RETURNS TRIGGER AS $$
DECLARE
    coop_lat    DECIMAL(10,7);
    coop_lng    DECIMAL(10,7);
    coop_radius INTEGER;
    distance    INTEGER;
BEGIN
    SELECT c.latitude, c.longitude, c.proximity_radius_meters
    INTO coop_lat, coop_lng, coop_radius
    FROM discussion_comments dc
    JOIN opinions o ON o.id = dc.opinion_id
    JOIN discussion_rooms dr ON dr.id = o.room_id
    JOIN cooperatives c ON c.id = dr.cooperative_id
    WHERE dc.id = NEW.id;

    IF EXISTS (SELECT 1 FROM users WHERE id = NEW.user_id AND role = 'admin') THEN
        RETURN NEW;
    END IF;
    IF coop_lat IS NULL OR coop_lng IS NULL THEN
        RAISE EXCEPTION 'Koperasi belum memiliki lokasi. Hubungi admin.';
    END IF;

    distance := haversine_distance(NEW.latitude, NEW.longitude, coop_lat, coop_lng);
    IF distance > coop_radius THEN
        RAISE EXCEPTION 'Anda terlalu jauh dari koperasi (jarak: % m, maks: % m).', distance, coop_radius;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_comment_proximity
    BEFORE INSERT ON discussion_comments
    FOR EACH ROW EXECUTE FUNCTION check_comment_proximity();

-- =============================================================
-- VIEW: Leaderboard (Peringkat Warga)
-- =============================================================

CREATE VIEW leaderboard AS
SELECT
    u.id,
    u.full_name,
    u.username,
    u.avatar_color,
    u.points_balance,
    u.village_id,
    v.name AS village_name,
    DENSE_RANK() OVER (ORDER BY u.points_balance DESC) AS rank
FROM users u
JOIN villages v ON v.id = u.village_id
WHERE u.is_active = true
ORDER BY u.points_balance DESC;
