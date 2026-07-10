# Database Konect — Ringkasan

## Strategi Utama

**003 (Kemenkop) = sumber kebenaran** untuk data koperasi (profil, pengurus, anggota, dll).
**001 (Konect) = untuk data aplikasi** (user, diskusi, voting, poin, dll).

001.cooperatives cuma **stub tipis** — isinya `id` + `legacy_ref` (link ke 003).
**Tidak ada duplikasi data. Tidak ada ETL.** View/fungsi di 006 tinggal JOIN via `legacy_ref`.

---

## Apa yang Sudah Selesai

| File | Isi | Status |
|---|---|---|
| `001_init_schema.sql` | Schema asli Konect: user, diskusi, voting, artikel, poin, voucher | ✅ Tidak disentuh |
| `002_relevance_ml.sql` | ML relevance + vektor | ✅ Tidak disentuh |
| `003_hackathon_schema.sql` | 27 tabel dari Kemenkop (profil koperasi, pengurus, anggota, aset, dll) | ✅ Tidak disentuh — **sumber kebenaran** |
| `006_frontend_views.sql` | Tambah `legacy_ref`, tabel `room_participants`, 5 view/fungsi untuk frontend | ✅ **Baru** |
| `007_seed_demo_data.sql` | Data contoh: 2 koperasi, 5 user, 3 ruang diskusi, 5 pendapat, dll | ✅ **Baru** |
| ~~`004_*`~~ | ~~Tambah 6 kolom duplikasi~~ | ❌ Dihapus (over-engineering) |
| ~~`005_*`~~ | ~~ETL copy data dari 003 ke 001~~ | ❌ Dihapus (over-engineering) |

---

## Tabel & Relasi

### Schema 001 (Konect App — 13 tabel)

```
villages ──┬── users ──┬── cooperatives (stub) ──┬── discussion_rooms ──┬── opinions ──┬── discussion_comments
           │           │                         │                      │              │
           │           │                         │                      │              └── reactions (polimorfik)
           │           │                         │                      │
           │           │                         │                      └── reactions (polimorfik)
           │           │                         │
           │           │                         ├── articles
           │           │                         ├── vouchers ──┬── voucher_redemptions
           │           │                         └── cooperative_members
           │           │
           │           └── point_transactions
           │
           └── room_participants
```

### Relasi Penting

| Dari | Ke | Lewat | Catatan |
|---|---|---|---|
| `001.cooperatives` | `003.profil_koperasi` | `cooperatives.legacy_ref` → `profil_koperasi.koperasi_ref` | Link 1 arah, 001 → 003 |
| `001.discussion_rooms` | `001.cooperatives` | `room.cooperative_id` → `cooperatives.id` | FK biasa |
| `001.room_participants` | `001.discussion_rooms` + `001.users` | `room_id` + `user_id` | M2M — siapa ikut ruang apa |
| `001.opinions` | `001.discussion_rooms` | `opinion.room_id` → `room.id` | Pendapat dalam suatu topik |
| `001.reactions` | `001.opinions` / `001.comments` | `target_type` + `target_id` | Polimorfik: agree/disagree/like |
| `001.articles` | `001.cooperatives` | `article.cooperative_id` → `cooperatives.id` | Timeline update (type = 'info') |
| `001.users` | `001.villages` | `user.village_id` → `village.id` | User tinggal di desa mana |

---

## View & Fungsi (Frontend Contract)

| Nama | Baca dari | Untuk |
|---|---|---|
| `v_forum_topics` | 001 (discussion_rooms) | List topik diskusi |
| `get_voting_items(user_id)` | 001 (opinions + reactions) | Daftar pendapat + hitung suara |
| `get_leaderboard(user_id)` | 001 (users + villages) | Peringkat warga |
| `get_nearby_cooperatives(lat, lng)` | **003** (profil_koperasi) | Koperasi di sekitar user |
| `get_cooperative_detail(coop_ref)` | **003** (profil + pengurus + anggota) + **001** (rooms + articles) | Detail lengkap koperasi |
| `get_room_canvas(room_id)` | **001** (rooms + opinions + comments) + **003** (profil_koperasi via legacy_ref) | Isi ruang diskusi (topic → pendapat → komentar) |

---

## Cara Kerja: 001 + 003

```
┌─────────────────────────────────────────────────────────┐
│                    003 (Kemenkop)                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │profil_koperasi│  │pengurus_     │  │anggota_      │  │
│  │              │  │koperasi      │  │koperasi      │  │
│  └──────┬───────┘  └──────────────┘  └──────────────┘  │
│         │ koperasi_ref (PK)                             │
└─────────┼───────────────────────────────────────────────┘
          │ JOIN via legacy_ref
┌─────────┼───────────────────────────────────────────────┐
│  001    └── cooperatives.legacy_ref                      │
│  (Konect)    │                                           │
│             ├── discussion_rooms                         │
│             ├── articles                                 │
│             └── cooperative_members                      │
│                                                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐               │
│  │users     │←─│room_     │─→│discussion│               │
│  │          │  │participan│  │_rooms    │               │
│  └────┬─────┘  └──────────┘  └────┬─────┘               │
│       │                           │                      │
│  ┌────┴─────┐              ┌──────┴──────┐              │
│  │villages  │              │  opinions   │              │
│  └──────────┘              └──────┬──────┘              │
│                                  │                      │
│                            ┌─────┴──────┐              │
│                            │ discussion_│              │
│                            │ comments   │              │
│                            └────────────┘              │
└─────────────────────────────────────────────────────────┘
```

---

## 5 Keputusan Desain

| # | Pertanyaan | Keputusan |
|---|---|---|
| Q1 | `image_url` koperasi dari mana? | **NULL** — 003 tidak punya kolom logo. `aset_koperasi` beda konteks (foto aset, bukan logo). |
| Q2 | `rooms[]` di detail koperasi dari mana? | **001.discussion_rooms** — join via `cooperatives.legacy_ref` |
| Q3 | `updates[]` di detail koperasi dari mana? | **001.articles** — type hardcoded `'info'` (tidak ada kolom type di 001) |
| Q4 | Avatar pakai apa? | **avatar_color** saja. Kolom `avatar_url` dihapus (tidak dipakai). |
| Q5 | `room_participants` perlu? | **Perlu** — untuk `membersCount` dan `avatars` di frontend. |

---

## Urutan Eksekusi

```
1. database/001_init_schema.sql       → Schema Konect (app)
2. database/002_relevance_ml.sql      → ML relevance (pgvector)
3. database/003_hackathon_schema.sql  → Schema Kemenkop + import CSV
4. database/006_frontend_views.sql    → legacy_ref + room_participants + views
5. database/007_seed_demo_data.sql    → Data contoh (opsional, untuk testing)
```
