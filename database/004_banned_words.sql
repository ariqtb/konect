-- =============================================================
-- Konect - Banned Words Table + Seed Data
-- PostgreSQL Migration v4.0
--
-- Untuk comment filtering:
--   1. Language detection (via Edge Function + franc)
--   2. Banned words matching (via tabel ini)
--   3. Tolak komentar jika match
--
-- Sumber data:
--   - ID: github.com/fanchann/toxic-word-list (371 kata)
--   - EN: github.com/dsojevic/profanity-list (434 entries)
--   - Paper: Lexicon-Based Indonesian Abusive Words Dictionary (250 kata)
--   - github.com/SideeID/id-profanity-filter
--   - github.com/okkyibrohim/id-abusive-language-detection
-- =============================================================

-- =============================================================
-- 1. BANNED WORDS TABLE
-- =============================================================

CREATE TABLE IF NOT EXISTS banned_words (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    word        VARCHAR(255) NOT NULL,
    language    VARCHAR(5) NOT NULL CHECK (language IN ('id', 'en', 'both')),
    severity    VARCHAR(10) NOT NULL CHECK (severity IN ('ringan', 'sedang', 'berat')),
    category    VARCHAR(50) NOT NULL CHECK (category IN ('makian', 'insult', 'sara', 'pornografi', 'spam')),
    is_active   BOOLEAN NOT NULL DEFAULT true,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(word)
);

CREATE INDEX IF NOT EXISTS idx_banned_words_lang ON banned_words(language);
CREATE INDEX IF NOT EXISTS idx_banned_words_severity ON banned_words(severity);
CREATE INDEX IF NOT EXISTS idx_banned_words_category ON banned_words(category);
CREATE INDEX IF NOT EXISTS idx_banned_words_active ON banned_words(is_active);

COMMENT ON TABLE banned_words IS 'Daftar kata kasar/tidak pantas untuk filtering komentar';
COMMENT ON COLUMN banned_words.language IS 'id=Indonesia, en=Inggris, both=keduanya';
COMMENT ON COLUMN banned_words.severity IS 'ringan=teguran, sedang=flagged, berat=auto-reject';
COMMENT ON COLUMN banned_words.category IS 'makian, insult, sara, pornografi, spam';

-- =============================================================
-- 2. SEED DATA — BAHASA INDONESIA (~140 kata)
-- =============================================================

-- CATEGORY: makian (umpatan umum)
INSERT INTO banned_words (word, language, severity, category) VALUES
    ('anjing', 'id', 'sedang', 'makian'),
    ('anjink', 'id', 'sedang', 'makian'),
    ('anjir', 'id', 'ringan', 'makian'),
    ('anjrit', 'id', 'ringan', 'makian'),
    ('asu', 'id', 'sedang', 'makian'),
    ('babi', 'id', 'sedang', 'makian'),
    ('bacot', 'id', 'ringan', 'makian'),
    ('bajingan', 'id', 'sedang', 'makian'),
    ('bangke', 'id', 'sedang', 'makian'),
    ('bangsat', 'id', 'sedang', 'makian'),
    ('bedebah', 'id', 'sedang', 'makian'),
    ('bego', 'id', 'ringan', 'insult'),
    ('begok', 'id', 'ringan', 'insult'),
    ('bencong', 'id', 'sedang', 'insult'),
    ('berengsek', 'id', 'sedang', 'makian'),
    ('biadab', 'id', 'sedang', 'makian'),
    ('bodo', 'id', 'ringan', 'insult'),
    ('bodoh', 'id', 'ringan', 'insult'),
    ('brengsek', 'id', 'sedang', 'makian'),
    ('brengsex', 'id', 'berat', 'makian'),
    ('budeg', 'id', 'ringan', 'insult'),
    ('cacat', 'id', 'sedang', 'insult'),
    ('cebong', 'id', 'ringan', 'insult'),
    ('celaka', 'id', 'ringan', 'makian'),
    ('celeng', 'id', 'sedang', 'makian'),
    ('conge', 'id', 'sedang', 'makian'),
    ('congek', 'id', 'sedang', 'makian'),
    ('dajal', 'id', 'sedang', 'makian'),
    ('dodol', 'id', 'ringan', 'insult'),
    ('dongok', 'id', 'ringan', 'insult'),
    ('dungu', 'id', 'ringan', 'insult'),
    ('edan', 'id', 'sedang', 'makian'),
    ('gblg', 'id', 'sedang', 'insult'),
    ('geblek', 'id', 'ringan', 'insult'),
    ('gelo', 'id', 'sedang', 'insult'),
    ('gila', 'id', 'sedang', 'insult'),
    ('goblog', 'id', 'sedang', 'insult'),
    ('goblok', 'id', 'sedang', 'insult'),
    ('haram jadah', 'id', 'sedang', 'makian'),
    ('iblis', 'id', 'sedang', 'makian'),
    ('idiot', 'id', 'sedang', 'insult'),
    ('jahanam', 'id', 'sedang', 'makian'),
    ('jalang', 'id', 'sedang', 'makian'),
    ('jamban', 'id', 'sedang', 'makian'),
    ('jancok', 'id', 'berat', 'makian'),
    ('jancuk', 'id', 'berat', 'makian'),
    ('jangkrik', 'id', 'sedang', 'makian'),
    ('jaran', 'id', 'ringan', 'insult'),
    ('jembel', 'id', 'ringan', 'insult'),
    ('jembut', 'id', 'sedang', 'pornografi'),
    ('kadal', 'id', 'ringan', 'insult'),
    ('kafir', 'id', 'berat', 'sara'),
    ('kampret', 'id', 'sedang', 'makian'),
    ('kampungan', 'id', 'ringan', 'insult'),
    ('kank', 'id', 'sedang', 'makian'),
    ('keparat', 'id', 'berat', 'makian'),
    ('kere', 'id', 'ringan', 'insult'),
    ('kontol', 'id', 'berat', 'pornografi'),
    ('kunyuk', 'id', 'sedang', 'makian'),
    ('laknat', 'id', 'sedang', 'makian'),
    ('lonte', 'id', 'berat', 'pornografi'),
    ('maho', 'id', 'sedang', 'sara'),
    ('mampus', 'id', 'sedang', 'makian'),
    ('mandul', 'id', 'ringan', 'insult'),
    ('mati', 'id', 'ringan', 'makian'),
    ('meki', 'id', 'sedang', 'pornografi'),
    ('memek', 'id', 'berat', 'pornografi'),
    ('memex', 'id', 'berat', 'pornografi'),
    ('mesum', 'id', 'sedang', 'pornografi'),
    ('modar', 'id', 'sedang', 'makian'),
    ('moddar', 'id', 'sedang', 'makian'),
    ('monyet', 'id', 'sedang', 'insult'),
    ('monyong', 'id', 'ringan', 'insult'),
    ('munyuk', 'id', 'sedang', 'insult'),
    ('najong', 'id', 'sedang', 'makian'),
    ('najis', 'id', 'sedang', 'makian'),
    ('ngawur', 'id', 'ringan', 'insult'),
    ('ngentot', 'id', 'berat', 'pornografi'),
    ('ngepet', 'id', 'sedang', 'makian'),
    ('ngewe', 'id', 'berat', 'pornografi'),
    ('ngocok', 'id', 'berat', 'pornografi'),
    ('njeng', 'id', 'sedang', 'makian'),
    ('njing', 'id', 'sedang', 'makian'),
    ('norak', 'id', 'ringan', 'insult'),
    ('nyolot', 'id', 'ringan', 'insult'),
    ('onta', 'id', 'ringan', 'insult'),
    ('otak udang', 'id', 'ringan', 'insult'),
    ('pantat', 'id', 'sedang', 'pornografi'),
    ('pantek', 'id', 'berat', 'pornografi'),
    ('pelacur', 'id', 'berat', 'insult'),
    ('peler', 'id', 'sedang', 'pornografi'),
    ('pemerkosa', 'id', 'berat', 'makian'),
    ('perawan', 'id', 'ringan', 'pornografi'),
    ('perek', 'id', 'sedang', 'insult'),
    ('perkosa', 'id', 'berat', 'makian'),
    ('pukimak', 'id', 'berat', 'makian'),
    ('puki', 'id', 'sedang', 'makian'),
    ('sampah', 'id', 'ringan', 'insult'),
    ('sarap', 'id', 'ringan', 'insult'),
    ('setan', 'id', 'sedang', 'makian'),
    ('sial', 'id', 'ringan', 'makian'),
    ('sialan', 'id', 'ringan', 'makian'),
    ('silit', 'id', 'sedang', 'pornografi'),
    ('sinting', 'id', 'ringan', 'insult'),
    ('sundal', 'id', 'berat', 'insult'),
    ('sundel', 'id', 'berat', 'insult'),
    ('taek', 'id', 'sedang', 'makian'),
    ('tahi', 'id', 'ringan', 'makian'),
    ('tai', 'id', 'ringan', 'makian'),
    ('taik', 'id', 'sedang', 'makian'),
    ('tampol', 'id', 'ringan', 'insult'),
    ('tetek', 'id', 'sedang', 'pornografi'),
    ('titit', 'id', 'ringan', 'pornografi'),
    ('toket', 'id', 'sedang', 'pornografi'),
    ('tolo', 'id', 'ringan', 'insult'),
    ('tolol', 'id', 'sedang', 'insult'),
    ('ublag', 'id', 'sedang', 'insult'),
    ('udik', 'id', 'ringan', 'insult');

-- CATEGORY: sara (suku, agama, ras, antargolongan)
INSERT INTO banned_words (word, language, severity, category) VALUES
    ('cina', 'id', 'berat', 'sara'),
    ('pribumi', 'id', 'ringan', 'sara'),
    ('bufalo', 'id', 'sedang', 'sara'),
    ('tiong', 'id', 'sedang', 'sara'),
    ('non pribumi', 'id', 'sedang', 'sara');

-- CATEGORY: spam / promosi
INSERT INTO banned_words (word, language, severity, category) VALUES
    ('judi', 'id', 'berat', 'spam'),
    ('slot', 'id', 'berat', 'spam'),
    ('narkoba', 'id', 'berat', 'spam'),
    ('bokep', 'id', 'berat', 'spam');

-- Variasi penulisan umum
INSERT INTO banned_words (word, language, severity, category) VALUES
    ('anjim', 'id', 'sedang', 'makian'),
    ('anjrot', 'id', 'ringan', 'makian'),
    ('anying', 'id', 'sedang', 'makian'),
    ('anyir', 'id', 'ringan', 'makian'),
    ('bajigur', 'id', 'ringan', 'makian'),
    ('bangor', 'id', 'ringan', 'makian'),
    ('bajing', 'id', 'sedang', 'makian'),
    ('bajeng', 'id', 'sedang', 'makian'),
    ('bebon', 'id', 'ringan', 'insult'),
    ('bedebah', 'id', 'sedang', 'makian'),
    ('bejad', 'id', 'sedang', 'makian'),
    ('bispak', 'id', 'sedang', 'insult'),
    ('blo on', 'id', 'sedang', 'insult'),
    ('bloon', 'id', 'ringan', 'insult'),
    ('boker', 'id', 'ringan', 'makian'),
    ('cabo', 'id', 'sedang', 'insult'),
    ('cangcut', 'id', 'sedang', 'pornografi'),
    ('dengkulmu', 'id', 'ringan', 'insult'),
    ('encek', 'id', 'sedang', 'makian'),
    ('eneg', 'id', 'ringan', 'makian'),
    ('ewe', 'id', 'sedang', 'pornografi'),
    ('gembel', 'id', 'ringan', 'insult'),
    ('gendeng', 'id', 'ringan', 'insult'),
    ('germo', 'id', 'sedang', 'makian'),
    ('itil', 'id', 'sedang', 'pornografi'),
    ('jablay', 'id', 'sedang', 'insult'),
    ('kacung', 'id', 'sedang', 'insult'),
    ('kancut', 'id', 'sedang', 'pornografi'),
    ('kanjut', 'id', 'sedang', 'pornografi'),
    ('katrok', 'id', 'ringan', 'insult'),
    ('kentut', 'id', 'ringan', 'makian'),
    ('kehed', 'id', 'sedang', 'makian'),
    ('koplok', 'id', 'sedang', 'insult'),
    ('lebay', 'id', 'ringan', 'insult'),
    ('lemot', 'id', 'ringan', 'insult'),
    ('matamu', 'id', 'ringan', 'insult'),
    ('murahan', 'id', 'sedang', 'insult'),
    ('ndasmu', 'id', 'sedang', 'insult'),
    ('ngaceng', 'id', 'sedang', 'pornografi'),
    ('ngeyel', 'id', 'ringan', 'insult'),
    ('njir', 'id', 'ringan', 'makian'),
    ('nonok', 'id', 'sedang', 'pornografi'),
    ('otakmu', 'id', 'ringan', 'insult'),
    ('pekok', 'id', 'ringan', 'insult'),
    ('peju', 'id', 'sedang', 'pornografi'),
    ('pepek', 'id', 'sedang', 'pornografi'),
    ('picik', 'id', 'ringan', 'insult');

-- =============================================================
-- 3. SEED DATA — BAHASA INGGRIS (~60 kata)
-- =============================================================

INSERT INTO banned_words (word, language, severity, category) VALUES
    ('ass', 'en', 'ringan', 'makian'),
    ('asshole', 'en', 'sedang', 'makian'),
    ('bastard', 'en', 'sedang', 'makian'),
    ('bitch', 'en', 'sedang', 'makian'),
    ('bollocks', 'en', 'ringan', 'makian'),
    ('bullshit', 'en', 'sedang', 'makian'),
    ('cock', 'en', 'sedang', 'pornografi'),
    ('cocksucker', 'en', 'berat', 'makian'),
    ('crap', 'en', 'ringan', 'makian'),
    ('cunt', 'en', 'berat', 'makian'),
    ('damn', 'en', 'ringan', 'makian'),
    ('dick', 'en', 'sedang', 'pornografi'),
    ('dickhead', 'en', 'sedang', 'makian'),
    ('douchebag', 'en', 'sedang', 'insult'),
    ('dumbass', 'en', 'sedang', 'insult'),
    ('fag', 'en', 'berat', 'sara'),
    ('faggot', 'en', 'berat', 'sara'),
    ('fuck', 'en', 'berat', 'makian'),
    ('fucker', 'en', 'berat', 'makian'),
    ('fucking', 'en', 'berat', 'makian'),
    ('fucktard', 'en', 'berat', 'insult'),
    ('goddamn', 'en', 'ringan', 'makian'),
    ('handjob', 'en', 'sedang', 'pornografi'),
    ('jackass', 'en', 'sedang', 'insult'),
    ('motherfucker', 'en', 'berat', 'makian'),
    ('nazi', 'en', 'berat', 'sara'),
    ('nigger', 'en', 'berat', 'sara'),
    ('nigga', 'en', 'berat', 'sara'),
    ('prick', 'en', 'sedang', 'insult'),
    ('pussy', 'en', 'sedang', 'pornografi'),
    ('rape', 'en', 'berat', 'makian'),
    ('rapist', 'en', 'berat', 'makian'),
    ('retard', 'en', 'berat', 'insult'),
    ('retarded', 'en', 'berat', 'insult'),
    ('shit', 'en', 'sedang', 'makian'),
    ('slut', 'en', 'sedang', 'insult'),
    ('son of a bitch', 'en', 'sedang', 'makian'),
    ('twat', 'en', 'sedang', 'insult'),
    ('whore', 'en', 'sedang', 'insult'),
    ('wanker', 'en', 'sedang', 'makian'),
    ('arse', 'en', 'ringan', 'makian'),
    ('arsehole', 'en', 'sedang', 'makian'),
    ('bloody', 'en', 'ringan', 'makian'),
    ('bugger', 'en', 'ringan', 'makian'),
    ('bollock', 'en', 'ringan', 'makian'),
    ('chink', 'en', 'berat', 'sara'),
    ('clit', 'en', 'sedang', 'pornografi'),
    ('cum', 'en', 'sedang', 'pornografi'),
    ('cyberbully', 'en', 'sedang', 'makian'),
    ('cyberbullying', 'en', 'sedang', 'makian'),
    ('dildo', 'en', 'sedang', 'pornografi'),
    ('dipshit', 'en', 'sedang', 'insult'),
    ('gook', 'en', 'berat', 'sara'),
    ('kill yourself', 'en', 'berat', 'makian'),
    ('kys', 'en', 'berat', 'makian'),
    ('lesbo', 'en', 'sedang', 'sara'),
    ('paedophile', 'en', 'berat', 'makian'),
    ('pedophile', 'en', 'berat', 'makian'),
    ('spic', 'en', 'berat', 'sara'),
    ('tranny', 'en', 'sedang', 'sara'),
    ('wank', 'en', 'sedang', 'makian'),
    ('whore', 'en', 'sedang', 'insult');

-- =============================================================
-- 4. VERIFIKASI
-- =============================================================

-- Hitung total per kategori
-- SELECT category, language, COUNT(*) FROM banned_words GROUP BY category, language ORDER BY language, category;
-- Hitung total semua: SELECT COUNT(*) FROM banned_words;

-- CREATE OR REPLACE VIEW banned_words_stats AS
-- SELECT 
--   COUNT(*) as total_words,
--   COUNT(*) FILTER (WHERE language = 'id') as id_words,
--   COUNT(*) FILTER (WHERE language = 'en') as en_words,
--   COUNT(*) FILTER (WHERE severity = 'ringan') as ringan,
--   COUNT(*) FILTER (WHERE severity = 'sedang') as sedang,
--   COUNT(*) FILTER (WHERE severity = 'berat') as berat
-- FROM banned_words;
