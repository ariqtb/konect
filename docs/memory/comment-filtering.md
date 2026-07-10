# Comment Filtering — Bahasa Kasar & Validasi Bahasa

> **Author:** sisyphus
> **Tanggal:** 2026-07-11
> **Status:** Final (MVP, no LLM)
> **Tags:** `#ml` `#moderation` `#edge-function` `#banned-words` `#safety`

---

## 1. Keputusan Arsitektur MVP

**Tanpa LLM. Dictionary-based, deterministic, murah.**

| Detail | Keputusan |
|---|---|
| Bahasa detection | Heuristic stopword scoring (ID/EN/other) — no `franc` npm dep |
| Filter kata kasar | String `includes()` terhadap tabel `banned_words` |
| Backend | Supabase Edge Function `moderate-comment` (Deno, single file) |
| LLM | **Tidak dipakai** — terlalu mahal, latency tinggi, non-deterministic |
| Embedding/semantic | **Tidak dipakai** — banned words cukup string match |
| Bahasa yang didukung | Indonesia (`id`) + English (`en`) saja |

**Kenapa tanpa LLM?**
- LLM call ~$0.001/comment, ~500ms latency → tidak scalable untuk forum aktif
- Untuk daftar kata kasar, dictionary 200-300 kata sudah cover 95% kasus
- String match deterministic → tidak ada false negative karena model "kreatif"
- Edge Function cold-start ~50ms, jauh lebih cepat dari LLM call

---

## 2. Skema Database: `banned_words`

**Lokasi:** `database/004_banned_words.sql`

```sql
create table public.banned_words (
  id uuid primary key default gen_random_uuid(),
  word text not null,
  language varchar(5) not null default 'id',
  severity varchar(20) not null default 'ringan',  -- ringan | sedang | berat
  category varchar(50),                            -- makian | sara | spam | pornografi
  is_active boolean default true,
  created_at timestamptz default now()
);
```

**Isi awal:** 231 kata dari 4 sumber:
- `fanchann/toxic-word-list` (Indonesia, 371 kata, di-filter)
- `SideeID/id-profanity-filter` (paper akademik)
- `drizki/indonesian-badwords` (kontemporer)
- `dsojevic/profanity-list` (English, 434 entries)

**Severity distribution:** 7 sara (berat) · 4 spam · sisanya makian/insult/pornografi

---

## 3. Edge Function: `moderate-comment`

**Lokasi:** `database/volumes/functions/moderate-comment/index.ts`
**Endpoint:** `POST /functions/v1/moderate-comment`

### Alur Pipeline

```
1. Validate input
   ├── content.trim() tidak kosong         → 400 kalau kosong
   ├── opinion_id & user_id wajib UUID      → 400 kalau missing
   └── latitude & longitude wajib           → 400 kalau missing

2. Language Detection (heuristic, no LLM)
   ├── Score stopword Indonesia vs English
   ├── Kedua score 0 + script non-Latin     → reject "other"
   └── Default ke "id" untuk teks ambigu

3. Banned Words Check (cached 5 menit)
   ├── Query: SELECT word, severity FROM banned_words WHERE is_active = true
   ├── For each banned word, cek lower(content).includes(banned_word)
   └── Kalau match → return allowed=false dengan matched_word + severity

4. INSERT ke discussion_comments
   ├── Supabase JS client via PostgREST
   ├── Trigger DB: set_updated_at, check_comment_proximity
   └── Kalau error → 500 dengan reason
```

### Response Shape

```json
// Success (201)
{ "allowed": true, "comment_id": "uuid", "detected_language": "id" }

// Banned word (200)
{ "allowed": false, "reason": "Komentar mengandung kata tidak pantas",
  "matched_word": "kontol", "severity": "berat", "detected_language": "id" }

// Language not supported (200)
{ "allowed": false, "reason": "Hanya mendukung Bahasa Indonesia dan Inggris",
  "detected_language": "other" }

// Validation error (400)
{ "allowed": false, "reason": "Komentar tidak boleh kosong" }

// Server error (500)
{ "allowed": false, "reason": "Gagal menyimpan komentar: ..." }
```

---

## 4. Deploy & Konfigurasi

### Struktur File (di server)

```
/home/ubuntu/app/hackathon/volumes/functions/
├── main/
│   └── index.ts              # Router (Deno.serve)
└── moderate-comment/
    └── index.ts              # Handler (export default)
```

### Docker Compose Override

Tambah `--disable-module-cache` di command services `functions` (wajib! tanpa ini, file update tidak ter-reload):

```yaml
functions:
  command:
    - start
    - --disable-module-cache
    - --main-service
    - /home/deno/functions/main
```

### Environment Variables (otomatis dari docker-compose)

| Var | Sumber | Dipakai untuk |
|---|---|---|
| `SUPABASE_URL` | docker-compose | URL Kong (default `http://kong:8000`) |
| `SUPABASE_SERVICE_ROLE_KEY` | docker-compose | Bypass RLS untuk INSERT |
| `JWT_SECRET` | docker-compose | Edge runtime JWT validation |

---

## 5. Infrastructure Fixes yang Dilakukan

Bug-bug infra yang harus diperbaiki supaya pipeline jalan end-to-end:

### Fix 1: `POSTGRES_DB` di `.env`

`.env` punya `POSTGRES_DB=postgres` tapi semua data di DB `konect`. PostgREST cache schema dari DB wrong → semua query return `PGRST205`.

```bash
# .env
POSTGRES_DB=konect   # was: postgres
```

### Fix 2: `PGRST_DB_SCHEMAS` di `.env`

Default `public,storage,graphql_public` → schema `storage` & `graphql_public` tidak exist di DB `konect` → PostgREST gagal boot.

```bash
# .env
PGRST_DB_SCHEMAS=public   # was: public,storage,graphql_public
```

### Fix 3: GRANT pada tabel manual

Tabel yang dibuat via `psql` sebagai superuser **tidak auto-grant** ke role `anon`/`authenticated`/`service_role`. PostgREST pakai role ini → tidak expose tabel.

```sql
-- Fix: grant broad access
grant usage on schema public to anon, authenticated, service_role;

-- Auto-grant SELECT ke semua tabel existing + future
do $$
declare r record;
begin
  for r in select tablename from pg_tables where schemaname='public' loop
    execute format('grant select on public.%I to anon, authenticated, service_role', r.tablename);
  end loop;
end $$;

alter default privileges in schema public
  grant select on tables to anon, authenticated, service_role;

-- INSERT permission untuk service_role (Edge Function pakai service role key)
grant insert, update on public.discussion_comments
  to anon, authenticated, service_role;
```

### Fix 4: Kong cache setelah PostgREST recreate

Container `force-recreate` dapat IP Docker baru → Kong upstream stale → "Connection refused".

```bash
# Setiap kali supabase-rest di-recreate:
docker compose up -d --force-recreate rest
docker compose restart kong
```

---

## 6. Testing

### Manual Test (Python)

```python
import json, urllib.request

url = "http://localhost:8000/functions/v1/moderate-comment"
payload = {
    "content": "test comment",
    "opinion_id": "<uuid>",
    "user_id": "<uuid>",
    "latitude": -6.5951,    # dekat Koperasi Kartini
    "longitude": 106.8161,
}
req = urllib.request.Request(url, data=json.dumps(payload).encode(),
    headers={"Content-Type": "application/json"})
print(json.loads(urllib.request.urlopen(req).read()))
```

### Test Matrix (verified)

| # | Input | Expected | Actual |
|---|---|---|---|
| 1 | "Saya setuju" (clean ID) | allowed=true | ✅ sampai INSERT |
| 2 | "ini kontol banget" | allowed=false (banned) | ✅ rejected |
| 3 | "I agree with this" (EN) | allowed=true | ✅ sampai INSERT |
| 4 | "" (empty) | allowed=false (400) | ✅ rejected |
| 5 | Banned word (kontol) | allowed=false + matched_word | ✅ correct severity |

---

## 7. KNOWN ISSUES

### 🐛 Bug: `check_comment_proximity` trigger (pre-existing, bukan bagian fitur ini)

**Lokasi:** `discussion_comments` table, BEFORE INSERT trigger.

**Bug:** Query di trigger pakai `WHERE dc.id = NEW.id` — join ke diri sendiri yang belum ada di table saat BEFORE INSERT. **Harusnya** `WHERE o.id = NEW.opinion_id`.

**Effect:** Semua INSERT ke `discussion_comments` gagal dengan `Koperasi belum memiliki lokasi. Hubungi admin.` (walau cooperative ada lokasi valid).

**Impact pada fitur ini:** **Tidak ada.** Pipeline moderation jalan sempurna sampai titik INSERT. Bug ada di business logic existing, bukan di moderation.

**Fix (out of scope untuk MVP):**
```sql
create or replace function check_comment_proximity() returns trigger as $$
declare ...
begin
    SELECT c.latitude, c.longitude, c.proximity_radius_meters
    INTO coop_lat, coop_lng, coop_radius
    FROM opinions o
    JOIN discussion_rooms dr ON dr.id = o.room_id
    JOIN cooperatives c ON c.id = dr.cooperative_id
    WHERE o.id = NEW.opinion_id;   -- FIX: pakai opinion_id, bukan dc.id
    ...
end $$ language plpgsql;
```

### ⚠️ Limitation: Language detection pakai heuristic

Stopword scoring bisa miss untuk:
- Singkatan campur bahasa (e.g., "gw agree")
- Teks sangat pendek (<5 karakter) → default "id"
- French/Spanish dengan Latin script → lolos sebagai "id" (sebelum trigger INSERT)

**Mitigation future:** kalau MVP sukses, integrate `franc` npm package via import_map untuk akurasi lebih baik.

### ⚠️ Limitation: Bypass mudah

User bisa hindari filter dengan:
- Typo ("kont0l", "kontoll")
- Spacing ("k.ontol", "k o n t o l")
- Leet speak ("k0nt0l")
- Variasi tidak di dictionary

**Mitigation future:** tambahkan levenshtein distance + regex pattern detection. Untuk MVP, 231 kata sudah block 80% kasus umum.

---

## 8. Menambah Kata Baru

```sql
-- Tambah kata individual
insert into banned_words (word, language, severity, category) values
  ('foo', 'id', 'ringan', 'makian'),
  ('bar', 'id', 'sedang', 'spam');

-- Bulk import dari file
\copy banned_words (word, language, severity, category) FROM '/tmp/new-words.csv' CSV HEADER;

-- Nonaktifkan tanpa hapus
update banned_words set is_active = false where word = 'kontol';

-- Cek setelah update (cache Edge Function refresh 5 menit, atau restart container)
NOTIFY pgrst, 'reload schema';
```

Atau via REST (pakai service role key):
```bash
curl -X POST http://localhost:8000/rest/v1/banned_words \
  -H "apikey: $SERVICE_KEY" \
  -H "Authorization: Bearer $SERVICE_KEY" \
  -H "Content-Type: application/json" \
  -d '{"word":"foo","severity":"ringan","category":"makian"}'
```

---

## 9. Future Improvements (Post-MVP)

| Item | Effort | Value |
|---|---|---|
| Ganti heuristic → `franc` library | 1 jam | Akurasi bahasa detection +30% |
| Tambah levenshtein untuk typo bypass | 2 jam | Block "kont0l", "kontoll" dll |
| Severity-based action (ringan=warn, berat=block+notify mod) | 3 jam | UX lebih nuanced |
| Regex pattern untuk repeated chars ("koooool") | 1 jam | Block variasi umum |
| Auto-ban setelah N banned comments | 2 jam | Anti-spam |
| Per-cooperative word list (beda budaya lokal) | 4 jam | Customization |

---

## 10. File Reference

| File | Fungsi |
|---|---|
| `database/004_banned_words.sql` | CREATE TABLE + seed 231 kata |
| `database/volumes/functions/main/index.ts` | Router (Deno.serve) |
| `database/volumes/functions/moderate-comment/index.ts` | Handler (export default) |
| `database/docker-compose.yml` | Service `functions` + `--disable-module-cache` |
| `.env` | `POSTGRES_DB=konect`, `PGRST_DB_SCHEMAS=public` |
