# Mapping Frontend → Database (Updated)

> **Latar belakang**: doc ini UPDATE dari versi lama. Dulu semua field cooperative
> dibaca dari `001.cooperatives` dan banyak yang "missing". Sekarang strategi berubah:
> **003 adalah source of truth untuk data koperasi.** View/fungsi di `006_frontend_views.sql`
> yang jembatani. Doc ini trace ulang semua kebutuhan frontend ke kondisi aktual.

---

## A. Forum (List Topik)

`forum_topic.dart` → `v_forum_topics` (006) + `get_room_canvas` (006)

| Field Frontend | Sumber DB | Status |
|---|---|---|
| `id` | `001.discussion_rooms.id` | ✅ |
| `title` | `001.discussion_rooms.title` | ✅ |
| `preview` | `LEFT(description, 200)` | ✅ |
| `comment_count` | COUNT opinions + discussion_comments per room | ✅ |
| `author_name` | `001.users.full_name` (anonim → 'Anonim') | ✅ |
| `created_at` (ISO) | `001.discussion_rooms.created_at` | ✅ |

Semua dari **001**. View `v_forum_topics` siap dipakai. ✅

---

## B. Voting (List Pendapat + Hitung Suara)

`voting_item.dart` → `get_voting_items(p_user_id)` (006)

| Field Frontend | Sumber DB | Status |
|---|---|---|
| `id` | `001.opinions.id` | ✅ |
| `opinion` | `001.opinions.content` | ✅ |
| `agree_count` | COUNT reactions WHERE reaction='agree' | ✅ |
| `disagree_count` | COUNT reactions WHERE reaction='disagree' | ✅ |
| `user_reaction` | reactions.reaction WHERE user_id = auth user | ✅ |

Semua dari **001**. Fungsi `get_voting_items` juga return `like_count`, `topic_id`, `topic_title`, `author_id`, `author_name`, `created_at` — ini extra, frontend bisa pakai nanti. ✅

---

## C. Leaderboard

`leaderboard_user.dart` → `get_leaderboard(p_user_id)` (006)

| Field Frontend | Sumber DB | Status |
|---|---|---|
| `id` | `001.users.id` | ✅ |
| `name` | `001.users.full_name` | ✅ |
| `score` | `001.users.points_balance` | ✅ |
| `rank` | DENSE_RANK() OVER (points_balance DESC) | ✅ |
| `is_current_user` | Computed di fungsi (user.id = p_user_id) | ✅ |

Pas semua. ✅

---

## D. Cooperative List (Koperasi di Sekitar)

`cooperative.dart` → `get_nearby_cooperatives(lat, lng)` (006)

| Field Frontend | Sumber DB | Status |
|---|---|---|
| `id` | **003**.profil_koperasi.koperasi_ref | ✅ |
| `name` | **003**.profil_koperasi.nama_koperasi | ✅ |
| `address` | **003**.profil_koperasi.alamat_lengkap | ✅ |
| `distance` | Computed via haversine dari koordinat_dibulatkan | ✅ |
| `image_url` | **NULL** (Q1 — 003 tidak punya logo koperasi) | ✅ resolved |
| `category` | **003**.profil_koperasi.kategori_usaha | ✅ **DULU MISSING, SEKARANG ADA** |
| `is_open` | Derived: status_registrasi = 'Approved' | ✅ **DULU MISSING, SEKARANG ADA** |

> **Catatan lama db.md**: "category TIDAK ADA di DB" dan "is_open TIDAK ADA di DB".
> **Update**: Kedua field ini SEKARANG ADA di `003.profil_koperasi` (`kategori_usaha`
> dan `status_registrasi`). Masalah solved lewat 003.

---

## E. Cooperative Detail

`cooperative_detail.dart` → `get_cooperative_detail(coop_ref)` (006)

### E1. Field Utama (dari 003)

| Field Frontend | Sumber DB | Status |
|---|---|---|
| `coop_id` | **003**.profil_koperasi.koperasi_ref | ✅ |
| `name` | **003**.profil_koperasi.nama_koperasi | ✅ |
| `address` | **003**.profil_koperasi.alamat_lengkap | ✅ |
| `description` | **003**.profil_koperasi.tentang_koperasi | ✅ |
| `category` | **003**.profil_koperasi.kategori_usaha | ✅ |
| `is_open` | status_registrasi = 'Approved' | ✅ |
| `legal_status` | **003**.profil_koperasi.bentuk_koperasi | ✅ **DULU MISSING, SEKARANG ADA** |
| `phone` | **003**.pengurus_koperasi.no_hp (row pertama) | ✅ **DULU MISSING, SEKARANG ADA** |
| `email` | **003**.pengurus_koperasi.email (row pertama) | ✅ **DULU MISSING, SEKARANG ADA** |
| `chairperson` | **003**.pengurus_koperasi.nama (ketua) | ✅ |
| `member_count` | COUNT **003**.anggota_koperasi | ✅ |
| `image_url` | **NULL** (Q1) | ✅ |

> **Catatan**: `phone` dan `email` diambil dari **row pertama** `003.pengurus_koperasi`
> (diurut berdasarkan `periode_mulai DESC`), bukan dari kolom koperasi langsung.
> Tidak filter jabatan 'Ketua' — ambil anggota pengurus mana saja yang terbaru.
> Ini karena 003 tidak punya kolom kontak di tabel profil_koperasi.

### E2. Rooms[] (dari 001 — via legacy_ref)

`CoopDiscussionRoom`:

| Field Frontend | Sumber DB | Status |
|---|---|---|
| `id` | `001.discussion_rooms.id` | ✅ |
| `title` | `001.discussion_rooms.title` | ✅ |
| `description` | `001.discussion_rooms.description` | ✅ |
| `status` | Derived: is_active → 'Aktif'/'Selesai' | ✅ |
| `date` | Format: to_char(created_at, 'DD Mon YYYY') | ✅ |
| `members_count` | COUNT room_participants WHERE room_id = id | ✅ **DULU MISSING, SEKARANG ADA** (tabel room_participants di 006) |
| `avatars` | TOP 3 avatar_color dari room_participants JOIN users | ✅ **BERUBAH**: return color hex, BUKAN URL gambar |

> **Catatan avatars**: Dulu mock pake URL gambar publik. Sekarang return
> `avatar_color` (hex) dari `001.users`. Frontend harus render lingkaran warna,
> bukan gambar. Ini sesuai Q4 (avatar_url dihapus, avatar_color aja).

### E3. Updates[] (dari 001 — via legacy_ref)

`CoopTimelineUpdate`:

| Field Frontend | Sumber DB | Status |
|---|---|---|
| `id` | `001.articles.id` | ✅ |
| `title` | `001.articles.title` | ✅ |
| `description` | `001.articles.content` | ✅ |
| `date` | Format: to_char(created_at, 'DD Mon YYYY') | ✅ |
| `type` ('warning'/'info') | **HARDCODED 'info'** (Q3) | ⚠️ **MASIH MISSING** |

> **type**: Frontend bisa render 'warning' (merah) dan 'info' (biru). Tapi
> `001.articles` tidak punya kolom type. Solusi saat ini: hardcode 'info' di
> fungsi `get_cooperative_detail`. Ke depannya bisa:
> - Tambah kolom `type VARCHAR(20)` di `001.articles`
> - Atau API layer yang nentuin type based on content/keywords

---

## F. Canvas Room Diskusi

`room_discussion_page.dart` (class `RoomOpinion` lokal) → `get_room_canvas(room_id)` (006)

| Field Frontend | Sumber DB | Status |
|---|---|---|
| `id` | `001.opinions.id` | ✅ |
| `text` | `001.opinions.content` | ✅ |
| `likes` | COUNT reactions WHERE reaction='like' | ✅ |
| `comments` (List\<String\>) | `001.discussion_comments.content` (content aja) | ✅ |

> Struktur: **Topic** (discussion_rooms) → **Opinions** (opinions) → **Comments** (discussion_comments).
> Persis seperti hierarki schema 001. Fungsi `get_room_canvas` return topic + opinions
> dengan nested comments + vote counts. ✅

---

## G. Auth (Login/Register)

`user.dart` → `001.users`

| Field Frontend | Sumber DB | Status |
|---|---|---|
| `id` | `001.users.id` | ✅ |
| `name` | `001.users.full_name` | ✅ |
| `email` | `001.users.email` | ✅ |
| `avatar_url` | **TIDAK ADA** (DB cuma avatar_color) | ⚠️ **DESIGN DECISION**: null terus. Frontend generate avatar dari inisial/color. |
| `role` ('admin'/'kopdes'/'member'/'guest') | `001.users.role` cuma 'admin'/'warga' | ⚠️ **MISMATCH**: handle di API layer |
| `created_at` | `001.users.created_at` | ✅ |

> **Role mapping (API layer):**
> - DB 'admin' → frontend 'admin'
> - DB 'warga' + cooperative_members.role='ketua'/'bendahara' → frontend 'kopdes'
> - DB 'warga' (anggota koperasi) → frontend 'member'
> - Tidak login → frontend 'guest'

---

## Rangkuman: Yang DULU Missing, Sekarang Beres

Dari doc `db.md` versi lama, ini status per item di **Section 4**:

| Item (dari db.md lama) | Status Sekarang | Penjelasan |
|---|---|---|
| `cooperative.category` | ✅ **BERES** | Ada di 003.profil_koperasi.kategori_usaha |
| `cooperative.is_open` | ✅ **BERES** | Derived dari 003.profil_koperasi.status_registrasi |
| `cooperative.legal_status` | ✅ **BERES** | Ada di 003.profil_koperasi.bentuk_koperasi |
| `cooperative.email` | ✅ **BERES** | Ada di 003.pengurus_koperasi.email (row pertama) |
| `articles.type` | ⚠️ **MASIH** | Hardcode 'info'. Butuh kolom baru atau logic di API |
| `room.members/avatars` | ✅ **BERES** | Tabel room_participants ditambah di 006 |
| Role kopdes/member/guest | ⚠️ **MISMATCH** | DB cuma admin/warga, handle di API layer |
| `users.avatar_url` | ⚠️ **NULL** | Design decision: pakai avatar_color aja (Q4) |

---

## Catatan 002_relevance_ml.sql

Tidak berubah dari versi lama:
- View `node_graph`, `opinion_ranking` — TIDAK dipakai frontend saat ini
- Fungsi `get_topic_graph`, `find_similar_opinions` — TIDAK dipanggil
- Trigger `auto_compute_opinion_relevance` — di-comment (disabled)
- Canvas room_discussion_page pakai layout manual (alternating kiri/kanan), BUKAN force-directed graph
- **Kesimpulan tetap sama**: 002 adalah fondasi ML backend yang belum ada integrasi frontend

---

## Endpoints (yang perlu dibangun saat API/backend ada)

Tidak berubah dari versi lama — semua view/fungsi di 006 siap dipanggil via REST:

| Method | Path | Fungsi/View di DB |
|---|---|---|
| GET | `/api/forums` | v_forum_topics |
| POST | `/api/forums` | INSERT discussion_rooms |
| GET | `/api/forums/:id/canvas` | get_room_canvas(room_id) |
| POST | `/api/forums/:id/opinions` | INSERT opinions |
| POST | `/api/opinions/:id/comments` | INSERT discussion_comments |
| POST | `/api/reactions` | UPSERT reactions |
| GET | `/api/voting?user_id=:uid` | get_voting_items(user_id) |
| GET | `/api/cooperatives/nearby?lat=&lng=` | get_nearby_cooperatives(lat, lng) |
| GET | `/api/cooperatives/:ref` | get_cooperative_detail(ref) |
| GET | `/api/leaderboard?user_id=:uid` | get_leaderboard(user_id) |
| POST | `/api/auth/login` | users lookup + bcrypt |
| POST | `/api/auth/register` | INSERT users |
| GET | `/api/vouchers?coop_id=:id` | vouchers |
| POST | `/api/vouchers/:id/redeem` | INSERT voucher_redemptions |
| GET | `/api/points/history?user_id=:uid` | point_transactions |

---

## Yang Masih Perlu Dilakukan

| # | Item | Prioritas |
|---|---|---|
| 1 | **articles.type**: tambah kolom di 001.articles atau logic di API buat bedain 'warning'/'info' | Rendah (sekarang hardcode 'info') |
| 2 | **Role mapping**: API layer mapping admin/warga → admin/kopdes/member/guest | Rendah (saat backend dibangun) |
| 3 | **Avatar frontend**: pastikan frontend render avatar_color (lingkaran warna), bukan image_url | Rendah (sudah pakai avatar_color) |
| 4 | **002 relevance ML**: integrasi graph view kalo frontend butuh visualisasi force-directed | Nanti (belum ada permintaan) |
