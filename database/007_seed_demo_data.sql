-- ============================================================================
-- Konect - Demo Seed Data
-- PostgreSQL Migration v1.4 (updated)
--
-- Sample data untuk testing views/functions di 006.
-- Idempotent: UUID deterministik, ON CONFLICT DO NOTHING.
--
-- Catatan penting: 001.cooperatives adalah "stub" — di 006 dibaca legacy_ref
-- untuk join ke 003.profil_koperasi. Stub ini HANYA untuk FK reference
-- dari discussion_rooms/articles. Data koperasi SEJATI ada di 003.
-- Jadi 007 hanya insert 2 stub 001 cooperatives, TIDAK copy data 1026.
--
-- Isi seed:
--   1. 1 village
--   2. 2 stub cooperatives (001, dengan legacy_ref ke 003.profil_koperasi)
--   3. 5 users (variasi points untuk leaderboard)
--   4. 3 discussion_rooms (referencing stub cooperatives)
--   5. 5 opinions (across 3 rooms)
--   6. 10 reactions
--   7. 3 articles (timeline updates — type hardcoded 'info' di view)
--   8. 5 room_participants
--
-- Password hash semua user = bcrypt('password', cost=10)
-- Untuk production, replace dengan hash valid dari app.
-- ============================================================================

-- ============================================================================
-- 1. VILLAGE
-- ============================================================================

INSERT INTO villages (id, name, slug, description, address, is_active)
VALUES (
    '00000000-0000-0000-0000-000000000001'::UUID,
    'Desa Sukatani',
    'sukatani',
    'Desa contoh untuk demo Konect',
    'Jl. Raya Desa No. 1, Kabupaten Bogor',
    true
) ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- 2. STUB COOPERATIVES (001) — link ke 003.profil_koperasi via legacy_ref
--    Hanya untuk FK reference dari discussion_rooms & articles.
--    Real koperasi data ada di 003 — JANGAN di-copy ke sini.
-- ============================================================================

-- Stub 1: link ke KOP-02AFA0134DB2 (KOPERASI DESA MERAH PUTIH KARTINI KAMPUNG LESTARI CAHAYA)
INSERT INTO cooperatives (id, legacy_ref, village_id, name, slug, description, address, latitude, longitude, is_active)
VALUES (
    '00000000-0000-0000-0000-0000000000a1'::UUID,
    'KOP-02AFA0134DB2',
    '00000000-0000-0000-0000-000000000001'::UUID,
    'Koperasi Desa Merah Putih Kartini',
    'koperasi-desa-merah-putih-kartini',
    'Stub link ke 003.profil_koperasi. Data lengkap ada di 003.',
    'Stub address — lihat 003.profil_koperasi.alamat_lengkap',
    -6.595000, 106.816000,
    true
) ON CONFLICT (id) DO NOTHING;

-- Stub 2: link ke KOP-5640DE941587
INSERT INTO cooperatives (id, legacy_ref, village_id, name, slug, description, address, latitude, longitude, is_active)
VALUES (
    '00000000-0000-0000-0000-0000000000a2'::UUID,
    'KOP-5640DE941587',
    '00000000-0000-0000-0000-000000000001'::UUID,
    'Koperasi Kelurahan Merah Putih Nirmala',
    'koperasi-kelurahan-nirmala',
    'Stub link ke 003.profil_koperasi. Data lengkap ada di 003.',
    'Stub address — lihat 003.profil_koperasi.alamat_lengkap',
    -6.596000, 106.817000,
    true
) ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- 3. USERS — 5 user dengan variasi points
-- ============================================================================

INSERT INTO users (id, village_id, email, username, full_name, password_hash, role, points_balance, is_active, avatar_color)
VALUES
    ('00000000-0000-0000-0000-000000000002'::UUID, '00000000-0000-0000-0000-000000000001'::UUID,
     'kopdes@konect.id',     'kopdes_ahmad', 'Ahmad (Kopdes)',  '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'warga', 4250, true, '#DC2626'),
    ('00000000-0000-0000-0000-000000000003'::UUID, '00000000-0000-0000-0000-000000000001'::UUID,
     'rahayu@konect.id',     'rahayu',       'Ibu Rahayu',      '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'warga', 9850, true, '#10B981'),
    ('00000000-0000-0000-0000-000000000004'::UUID, '00000000-0000-0000-0000-000000000001'::UUID,
     'budi@konect.id',       'budi_warga',   'Budi Santoso',    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'warga', 8450, true, '#3B82F6'),
    ('00000000-0000-0000-0000-000000000005'::UUID, '00000000-0000-0000-0000-000000000001'::UUID,
     'sulastri@konect.id',   'sulastri',     'Bu Sulastri',     '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'warga', 8230, true, '#F59E0B'),
    ('00000000-0000-0000-0000-000000000006'::UUID, '00000000-0000-0000-0000-000000000001'::UUID,
     'slamet@konect.id',     'slamet',       'Bpk. Slamet',     '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'warga', 8110, true, '#8B5CF6')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- 4. DISCUSSION_ROOMS — 3 topik di 2 stub koperasi
-- ============================================================================

INSERT INTO discussion_rooms (id, cooperative_id, created_by, title, description, is_active, is_anonymous)
VALUES
    ('00000000-0000-0000-0000-000000000010'::UUID,
     '00000000-0000-0000-0000-0000000000a1'::UUID,
     '00000000-0000-0000-0000-000000000002'::UUID,
     'Musyawarah Anggaran Tahunan 2026',
     'Bagaimana alokasi SHU tahun ini? Mohon pendapat anggota terkait prioritas program.',
     true, false),
    ('00000000-0000-0000-0000-000000000011'::UUID,
     '00000000-0000-0000-0000-0000000000a1'::UUID,
     '00000000-0000-0000-0000-000000000003'::UUID,
     'Usul penambahan unit usaha simpan pinjam',
     'Banyak anggota yang membutuhkan akses pinjaman cepat dengan bunga ringan.',
     true, false),
    ('00000000-0000-0000-0000-000000000012'::UUID,
     '00000000-0000-0000-0000-0000000000a2'::UUID,
     '00000000-0000-0000-0000-000000000004'::UUID,
     'Transparansi laporan keuangan Q1',
     'Berikut ringkasan keuangan triwulan I. Mohon review dan masukan dari anggota.',
     true, false)
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- 5. OPINIONS — 5 pendapat (3 di room 1, 1 di room 2, 1 di room 3)
-- ============================================================================

INSERT INTO opinions (id, room_id, user_id, content, is_anonymous, latitude, longitude)
VALUES
    ('00000000-0000-0000-0000-000000000020'::UUID, '00000000-0000-0000-0000-000000000010'::UUID,
     '00000000-0000-0000-0000-000000000003'::UUID,
     'SHU tahun ini sebaiknya dialokasikan 60% untuk cadangan dan 40% untuk jasa modal anggota.',
     false, -6.595000, 106.816000),
    ('00000000-0000-0000-0000-000000000021'::UUID, '00000000-0000-0000-0000-000000000010'::UUID,
     '00000000-0000-0000-0000-000000000004'::UUID,
     'Koperasi perlu membuka unit usaha baru: toko sarana produksi pertanian.',
     false, -6.595100, 106.816100),
    ('00000000-0000-0000-0000-000000000022'::UUID, '00000000-0000-0000-0000-000000000010'::UUID,
     '00000000-0000-0000-0000-000000000005'::UUID,
     'Jasa pinjaman sebaiknya diturunkan dari 1.5% ke 1.2% per bulan untuk anggota.',
     false, -6.595200, 106.816200),
    ('00000000-0000-0000-0000-000000000023'::UUID, '00000000-0000-0000-0000-000000000011'::UUID,
     '00000000-0000-0000-0000-000000000002'::UUID,
     'Setuju, akses pinjaman cepat sangat dibutuhkan terutama untuk modal usaha tani.',
     true, -6.595300, 106.816300),
    ('00000000-0000-0000-0000-000000000024'::UUID, '00000000-0000-0000-0000-000000000012'::UUID,
     '00000000-0000-0000-0000-000000000006'::UUID,
     'Laporan keuangan Q1 sudah cukup transparan, perlu ditambah grafik perbandingan tahun lalu.',
     false, -6.595400, 106.816400)
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- 6. REACTIONS — 10 reaksi
-- ============================================================================

INSERT INTO reactions (user_id, target_type, target_id, reaction) VALUES
    ('00000000-0000-0000-0000-000000000002'::UUID, 'opinion', '00000000-0000-0000-0000-000000000020'::UUID, 'agree'),
    ('00000000-0000-0000-0000-000000000003'::UUID, 'opinion', '00000000-0000-0000-0000-000000000020'::UUID, 'agree'),
    ('00000000-0000-0000-0000-000000000004'::UUID, 'opinion', '00000000-0000-0000-0000-000000000020'::UUID, 'agree'),
    ('00000000-0000-0000-0000-000000000005'::UUID, 'opinion', '00000000-0000-0000-0000-000000000020'::UUID, 'agree'),
    ('00000000-0000-0000-0000-000000000002'::UUID, 'opinion', '00000000-0000-0000-0000-000000000021'::UUID, 'agree'),
    ('00000000-0000-0000-0000-000000000003'::UUID, 'opinion', '00000000-0000-0000-0000-000000000021'::UUID, 'agree'),
    ('00000000-0000-0000-0000-000000000004'::UUID, 'opinion', '00000000-0000-0000-0000-000000000021'::UUID, 'agree'),
    ('00000000-0000-0000-0000-000000000006'::UUID, 'opinion', '00000000-0000-0000-0000-000000000021'::UUID, 'disagree'),
    ('00000000-0000-0000-0000-000000000002'::UUID, 'opinion', '00000000-0000-0000-0000-000000000022'::UUID, 'disagree'),
    ('00000000-0000-0000-0000-000000000004'::UUID, 'opinion', '00000000-0000-0000-0000-000000000022'::UUID, 'disagree')
ON CONFLICT (user_id, target_type, target_id) DO NOTHING;

-- ============================================================================
-- 7. ARTICLES — 3 timeline update (type hardcoded 'info' di 006 view)
-- ============================================================================

INSERT INTO articles (id, cooperative_id, title, content, image_url, created_by)
VALUES
    ('00000000-0000-0000-0000-000000000030'::UUID,
     '00000000-0000-0000-0000-0000000000a1'::UUID,
     'Penyelesaian Fondasi Tiang Surya Tahap I',
     'Sebanyak 40 titik di Dusun Krajan telah selesai dipasang dudukan beton.',
     NULL, '00000000-0000-0000-0000-000000000002'::UUID),
    ('00000000-0000-0000-0000-000000000031'::UUID,
     '00000000-0000-0000-0000-0000000000a1'::UUID,
     'Pengadaan Perangkat IoT Pertanian',
     'Verifikasi unit sensor tanah dan kelembaban udara oleh tim teknis desa.',
     NULL, '00000000-0000-0000-0000-000000000002'::UUID),
    ('00000000-0000-0000-0000-000000000032'::UUID,
     '00000000-0000-0000-0000-0000000000a2'::UUID,
     'Pelatihan Pembukuan Digital untuk Pengurus',
     'Sesi pelatihan penggunaan aplikasi pembukuan digital untuk pengurus koperasi.',
     NULL, '00000000-0000-0000-0000-000000000002'::UUID)
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- 8. ROOM_PARTICIPANTS
-- ============================================================================

INSERT INTO room_participants (room_id, user_id, role) VALUES
    ('00000000-0000-0000-0000-000000000010'::UUID, '00000000-0000-0000-0000-000000000002'::UUID, 'host'),
    ('00000000-0000-0000-0000-000000000010'::UUID, '00000000-0000-0000-0000-000000000003'::UUID, 'participant'),
    ('00000000-0000-0000-0000-000000000010'::UUID, '00000000-0000-0000-0000-000000000004'::UUID, 'participant'),
    ('00000000-0000-0000-0000-000000000011'::UUID, '00000000-0000-0000-0000-000000000005'::UUID, 'moderator'),
    ('00000000-0000-0000-0000-000000000012'::UUID, '00000000-0000-0000-0000-000000000006'::UUID, 'participant')
ON CONFLICT (room_id, user_id) DO NOTHING;

-- ============================================================================
-- VERIFY: total counts
-- ============================================================================

-- SELECT 'villages' AS tbl, COUNT(*) FROM villages
-- UNION ALL SELECT 'cooperatives', COUNT(*) FROM cooperatives
-- UNION ALL SELECT 'users', COUNT(*) FROM users
-- UNION ALL SELECT 'discussion_rooms', COUNT(*) FROM discussion_rooms
-- UNION ALL SELECT 'opinions', COUNT(*) FROM opinions
-- UNION ALL SELECT 'reactions', COUNT(*) FROM reactions
-- UNION ALL SELECT 'articles', COUNT(*) FROM articles
-- UNION ALL SELECT 'room_participants', COUNT(*) FROM room_participants;
