# Database Schema — Konect (Koperasi Connect)

> **Author:** alwan
> **Tanggal:** 2026-07-10
> **Status:** Final
> **Tags:** `#database` `#postgresql` `#pgvector` `#schema`

---

## 1. Informasi Umum

| Item | Detail |
|---|---|
| **Database** | PostgreSQL 17 + pgvector |
| **Hosting** | Shared Hackathon (34.101.155.200:5432) |
| **Prefix** | `group3b_` (wajib untuk semua tabel) |
| **Extension** | `uuid-ossp`, `pgcrypto`, `vector` |
| **Migration Files** | `database/001_init_schema.sql`, `database/002_relevance_ml.sql` |

---

## 2. Entity Relationship Diagram

```
villages
    │
    ├── users
    │       ├── cooperative_members
    │       ├── point_transactions
    │       └── reactions (polymorphic: opinion/comment)
    │
    └── cooperatives
            ├── discussion_rooms (TOPIC)
            │       └── opinions (PENDAPAT = VOTE)
            │               ├── discussion_comments (KOMENTAR)
            │               └── reactions (agree/disagree = voting)
            ├── articles (BERITA)
            ├── vouchers
            │       └── voucher_redemptions
            └── ...
```

---

## 3. Detail Tabel

### 3.1 `villages` — Desa

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | UUID PK | Default uuid_generate_v4() |
| name | VARCHAR(255) | Nama desa |
| slug | VARCHAR(255) UNIQUE | Slug unik |
| description | TEXT | Deskripsi |
| address | TEXT | Alamat |
| logo_url | TEXT | URL logo |
| is_active | BOOLEAN | Default true |
| created_at / updated_at | TIMESTAMPTZ | Auto-managed |

### 3.2 `users` — Warga

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | UUID PK | Default uuid_generate_v4() |
| village_id | UUID FK → villages | Desa asal (ON DELETE RESTRICT) |
| email | VARCHAR(255) UNIQUE | Email login |
| username | VARCHAR(100) UNIQUE | Username |
| full_name | VARCHAR(255) | Nama lengkap |
| password_hash | TEXT | Hash password |
| avatar_color | VARCHAR(7) | Hex color untuk blob avatar |
| role | user_role | 'admin' atau 'warga' |
| points_balance | INTEGER | Default 0, CHECK >= 0 |
| is_active | BOOLEAN | Default true |
| created_at / updated_at | TIMESTAMPTZ | Auto-managed |

### 3.3 `cooperatives` — Koperasi

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | UUID PK | Default uuid_generate_v4() |
| village_id | UUID FK → villages | Lokasi desa |
| name | VARCHAR(255) | Nama koperasi |
| slug | VARCHAR(255) UNIQUE | Slug unik |
| description | TEXT | Deskripsi |
| address | TEXT | Alamat |
| image_url | TEXT | URL gambar |
| contact_phone | VARCHAR(20) | Nomor telepon |
| latitude / longitude | DECIMAL(10,7) | Titik lokasi kopdes |
| proximity_radius_meters | INTEGER | Default 200 meter |
| is_active | BOOLEAN | Default true |
| created_at / updated_at | TIMESTAMPTZ | Auto-managed |

### 3.4 `cooperative_members` — Anggota Koperasi

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | UUID PK | Default uuid_generate_v4() |
| cooperative_id | UUID FK → cooperatives | ON DELETE CASCADE |
| user_id | UUID FK → users | ON DELETE CASCADE |
| role | member_role | 'ketua', 'bendahara', 'anggota' |
| joined_at | TIMESTAMPTZ | Waktu bergabung |
| UNIQUE | (cooperative_id, user_id) | Satu user per koperasi |

### 3.5 `discussion_rooms` — Topik Diskusi (ROOT NODE)

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | UUID PK | Default uuid_generate_v4() |
| cooperative_id | UUID FK → cooperatives | ON DELETE CASCADE |
| created_by | UUID FK → users | Pembuat topik |
| title | VARCHAR(255) | Judul topik |
| description | TEXT | Deskripsi |
| is_active | BOOLEAN | Default true |
| is_anonymous | BOOLEAN | Default false |
| created_at / updated_at | TIMESTAMPTZ | Auto-managed |

### 3.6 `opinions` — Pendapat/Opini (LEVEL 2 NODE = VOTE)

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | UUID PK | Default uuid_generate_v4() |
| room_id | UUID FK → discussion_rooms | ON DELETE CASCADE |
| user_id | UUID FK → users | Pembuat pendapat |
| content | TEXT | Isi pendapat |
| is_anonymous | BOOLEAN | Default false |
| latitude / longitude | DECIMAL(10,7) | Lokasi saat posting |
| embedding | VECTOR(384) | pgvector embedding (all-MiniLM-L6-v2) |
| relevance_score | DECIMAL(5,4) | ML relevance thd topic (0.0000-1.0000) |
| created_at / updated_at | TIMESTAMPTZ | Auto-managed |

**Index:** ivfflat (embedding vector_cosine_ops) with lists=100

### 3.7 `discussion_comments` — Komentar (LEVEL 3 NODE)

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | UUID PK | Default uuid_generate_v4() |
| opinion_id | UUID FK → opinions | ON DELETE CASCADE |
| user_id | UUID FK → users | Pembuat komentar |
| parent_id | UUID FK → discussion_comments | Reply ke komentar lain |
| content | TEXT | Isi komentar |
| is_anonymous | BOOLEAN | Default false |
| latitude / longitude | DECIMAL(10,7) | Lokasi saat posting |
| embedding | VECTOR(384) | pgvector embedding |
| relevance_score | DECIMAL(5,4) | ML relevance thd opinion |
| created_at / updated_at | TIMESTAMPTZ | Auto-managed |

### 3.8 `reactions` — Reaksi/Voting (Polymorphic)

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | UUID PK | Default uuid_generate_v4() |
| user_id | UUID FK → users | Pemberi reaksi |
| target_type | VARCHAR(10) | 'opinion' atau 'comment' |
| target_id | UUID | Polymorphic reference |
| reaction | reaction_type | 'agree', 'disagree', 'like' |
| UNIQUE | (user_id, target_type, target_id) | Satu reaksi per user per target |

### 3.9 `articles` — Artikel/Berita

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | UUID PK | Default uuid_generate_v4() |
| cooperative_id | UUID FK → cooperatives | ON DELETE CASCADE |
| title | VARCHAR(255) | Judul artikel |
| content | TEXT | Konten |
| image_url | TEXT | URL gambar |
| created_by | UUID FK → users | Penulis |
| created_at / updated_at | TIMESTAMPTZ | Auto-managed |

### 3.10 `vouchers` — Voucher

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | UUID PK | Default uuid_generate_v4() |
| cooperative_id | UUID FK → cooperatives | ON DELETE CASCADE |
| code | VARCHAR(100) UNIQUE | Kode voucher |
| title | VARCHAR(255) | Judul |
| description | TEXT | Deskripsi |
| points_required | INTEGER | CHECK > 0 |
| qr_code_url | TEXT | URL QR code |
| quantity | INTEGER | CHECK >= 0 |
| is_active | BOOLEAN | Default true |
| expires_at | TIMESTAMPTZ | Waktu kadaluarsa |
| created_at / updated_at | TIMESTAMPTZ | Auto-managed |

### 3.11 `voucher_redemptions` — Penukaran Voucher

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | UUID PK | Default uuid_generate_v4() |
| voucher_id | UUID FK → vouchers | ON DELETE RESTRICT |
| user_id | UUID FK → users | ON DELETE RESTRICT |
| redeemed_at | TIMESTAMPTZ | Waktu tukar |
| qr_code_used | TEXT | QR code |
| status | redemption_status | 'pending', 'completed', 'cancelled' |
| UNIQUE | (voucher_id, user_id) | Satu penukaran per user per voucher |

### 3.12 `point_transactions` — Riwayat Poin

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | UUID PK | Default uuid_generate_v4() |
| user_id | UUID FK → users | ON DELETE RESTRICT |
| amount | INTEGER | CHECK != 0 (+ = earn, - = redeem) |
| transaction_type | transaction_type | Jenis transaksi |
| reference_id | UUID | Polymorphic reference |
| description | TEXT | Deskripsi |
| created_at | TIMESTAMPTZ | Waktu transaksi |

---

## 4. Views & Functions

### 4.1 `leaderboard` — Peringkat Warga

```sql
SELECT * FROM leaderboard;
-- Returns: id, full_name, username, avatar_color, points_balance,
--          village_id, village_name, rank (DENSE_RANK)
```

### 4.2 `node_graph` — Data Graph Unified

View yang menggabungkan semua node (topic + opinion + comment) dan edge dalam satu query.

- `row_type`: 'node' atau 'edge'
- Node: node_id, node_type, label, topic_id, relevance_score, cluster
- Edge: source_id, target_id, edge_weight, edge_type

### 4.3 `opinion_ranking` — Peringkat Opini per Topik

Ranking opini berdasarkan relevance_score DESC dan comment_count DESC.

### 4.4 `get_topic_graph(p_topic_id)` — Graph JSON

Function yang return `{nodes: JSONB, edges: JSONB}` untuk frontend.

- Node size: topic=20, opinion=12, comment=7
- Edge weight berdasarkan relevance_score

### 4.5 `find_similar_opinions(p_opinion_id, p_limit)` — Semantic Search

Cari pendapat serupa menggunakan cosine similarity embedding.

### 4.6 `haversine_distance(lat1, lng1, lat2, lng2)` — Geolocation

Menghitung jarak dalam meter antara dua koordinat.

### 4.7 Trigger Proximity Check

- `check_opinion_proximity`: Validasi radius sebelum INSERT opinion
- `check_comment_proximity`: Validasi radius sebelum INSERT comment
- Admin di-bypass dari pengecekan radius

---

## 5. Notes untuk Developer

1. **Embedding** di-generate oleh Python FastAPI (sentence-transformers)
2. **Relevance score** dihitung oleh Cross-Encoder (pairwise)
3. Python akan hitung: relevance(topic, opinion) dan relevance(opinion, comment)
4. Frontend panggil `get_topic_graph(uuid)` untuk data force-graph
5. **Outlier** = opinion dengan relevance_score < threshold (misal < 0.3)
6. IVFFlat index untuk cosine similarity search
7. `relevance_score` di DB default `0.5000`, di-refresh periodik oleh ML backend
