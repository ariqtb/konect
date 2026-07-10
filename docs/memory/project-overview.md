# Project Overview — Konect (Koperasi Connect)

> **Author:** alwan
> **Tanggal:** 2026-07-10
> **Status:** Final
> **Tags:** `#overview` `#konect` `#kopdes`

---

## 1. Deskripsi Singkat

**Konect (Koperasi Connect)** adalah platform digital untuk koperasi desa yang menyediakan:

- **Diskusi/Forum online** — warga desa bisa berdiskusi dalam topik terstruktur
- **E-Voting** — voting berbasis opini (agree/disagree) dengan trust & transparansi
- **Node Graph Visualisation** — visualisasi interaktif berbentuk force-directed graph yang menunjukkan korelasi antara topik, pendapat, dan komentar
- **ML Relevance Scoring** — skor relevansi berbasis AI untuk menentukan posisi node dalam graph, ranking konten, dan outlier detection
- **Poin & Reward** — sistem poin sebagai insentif partisipasi, bisa ditukar dengan voucher

### Target Pengguna

- **Koperasi Desa (Kopdes)** sebagai entitas organisasi
- **Warga Desa** sebagai anggota koperasi yang berpartisipasi dalam diskusi dan voting
- **Admin Koperasi** sebagai pengelola forum dan konten

---

## 2. Latar Belakang

Proyek ini dikembangkan dalam konteks **Hackathon 2026 — Pendamping KOPDES (Koperasi Desa Merah Putih)** yang diselenggarakan oleh KEMENKO PMK.

Program **Koperasi Desa Merah Putih (KDMP)** adalah program unggulan Presiden Prabowo yang menargetkan pembentukan koperasi di seluruh Indonesia. Per Juli 2026, data SIMKOPDES mencatat 83.382 koperasi sudah berbadan hukum, namun 91,1% di antaranya masuk kategori **tidak sehat**.

Konect hadir sebagai solusi untuk meningkatkan **trust, transparansi, dan partisipasi** anggota koperasi melalui platform diskusi dan voting digital yang terstruktur.

---

## 3. Tech Stack

| Layer | Teknologi | Keterangan |
|---|---|---|
| **Frontend Mobile** | **Flutter 3.10+** (Dart) | Cross-platform (Android, iOS, Web, Desktop) |
| **State Management** | **flutter_bloc** + equatable | BLoC pattern untuk state management |
| **Backend/Database** | **Supabase** (PostgreSQL 17 + pgvector) | Self-hosted via Docker |
| **ML Backend** | **Python FastAPI** (planned) | sentence-transformers untuk embedding & relevance scoring |
| **Graph Visualization** | **react-force-graph-2d** (planned) | Force-directed graph untuk visualisasi diskusi |
| **Auth** | Supabase Auth (GoTrue) | JWT-based authentication |
| **Infrastructure** | Docker Compose | Self-hosted Supabase stack |

---

## 4. Struktur Repository

```
konect/
├── .agents/                    # Konfigurasi agent AI (OpenCode)
│   └── skills/                 # Skills untuk agent AI
│       ├── memory/             # Memory sharing skill
│       ├── website-to-video/   # Skill video dari website
│       ├── talking-head-recut/ # Skill video talking head
│       └── ...                 # Skill lainnya
├── database/                   # Database migrations & config
│   ├── 001_init_schema.sql     # Schema inti (12 tabel)
│   ├── 002_relevance_ml.sql    # ML functions, views, graph helpers
│   ├── supabase.yml            # Docker Compose Supabase
│   └── .env                    # Environment variables
├── docs/                       # Dokumentasi
│   ├── flows/                  # Diagram alur
│   ├── memory/                 # Memory untuk agent AI
│   ├── ppt/                    # Presentasi
│   ├── ppt-trust/              # Presentasi trust analysis
│   ├── prd/                    # PRD & dokumen teknis
│   └── references/             # Data riset & referensi
├── konect/                     # Flutter app
│   └── lib/
│       ├── core/               # Theme, constants
│       ├── data/               # Models, repositories
│       │   ├── models/         # Data models (user.dart)
│       │   └── repositories/   # Data layer (auth_repository.dart)
│       └── presentation/       # UI Layer
│           ├── blocs/          # State management (BLoC)
│           └── pages/          # Screens (login, forum, voting)
├── machine-learning/           # ML backend (empty, placeholder)
├── package.json                # Root package (beautiful-mermaid)
└── README.md                   # Deskripsi proyek
```

---

## 5. Fitur Utama

### 5.1 Forum Diskusi Terstruktur
- **Topik (discussion_rooms)** — ruang diskusi yang dibuat admin
- **Pendapat/Opini (opinions)** — ide atau suara dari warga, merupakan level "vote"
- **Komentar (discussion_comments)** — diskusi lebih lanjut pada suatu pendapat
- Voting diimplementasikan via **reactions** (agree/disagree/like)

### 5.2 Node Graph
- Visualisasi interaktif berbasis force-directed graph
- Hierarki 3 level: Topik → Pendapat → Komentar
- Posisi node ditentukan oleh **relevance_score** (semakin relevan, semakin dekat ke pusat)
- Outlier detection untuk pendapat yang tidak relevan

### 5.3 ML Relevance Scoring
- **Bi-Encoder** (all-MiniLM-L6-v2) untuk generate embedding 384 dimensi
- **Cross-Encoder** (ms-marco-MiniLM-L6-v2) untuk relevance score pairwise
- Embedding disimpan di pgvector (IVFFlat index)
- Score di-refresh periodik, disimpan di kolom `relevance_score`

### 5.4 Poin & Reward
- Poin didapat dari partisipasi diskusi, bonus signup, daily login
- Poin bisa ditukar dengan voucher koperasi
- Riwayat transaksi poin dicatat di `point_transactions`
- **Leaderboard** peringkat warga berdasarkan poin

### 5.5 Geolocation Trust
- Warga wajib berada dalam radius koperasi untuk posting
- Posisi latitude/longitude dicatat setiap posting
- Admin dikecualikan dari pengecekan radius
- Fungsi **Haversine Distance** untuk perhitungan jarak

---

## 6. Status Pengembangan

| Komponen | Status | Catatan |
|---|---|---|
| Database Schema | ✅ Selesai | 12 tabel inti + pgvector + functions |
| ML Functions | ✅ Selesai | Views, graph helpers, ranking |
| Flutter App Auth | 🟡 MVP | Login page, auth bloc, auth repo (placeholder) |
| Flutter App Forum | 🟡 In Progress | BLoC declared, page scaffolding |
| Flutter App Voting | 🟡 In Progress | BLoC declared, page scaffolding |
| Python ML Backend | ❌ Belum | machine-learning/ masih kosong |
| Node Graph Frontend | ❌ Belum | react-force-graph-2d belum diintegrasi |
| Supabase Production | 🟡 Self-host | Shared hackathon DB, beberapa service ga jalan |

---

## 7. Tim & Kontak

- **Repository:** https://github.com/ariqtb/konect
- **Hackathon:** KEMENKO PMK — Pendamping KOPDES 2026
- **Team:** group3b
- **Prefix Database:** `group3b_` (aturan hackathon)
