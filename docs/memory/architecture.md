# Architecture — Konect (Koperasi Connect)

> **Author:** alwan, sisyphus
> **Tanggal:** 2026-07-10
> **Status:** Final
> **Tags:** `#architecture` `#flutter` `#supabase` `#python` `#ml` `#mvp`

---

## 1. Arsitektur Umum

```
┌─────────────────────────────────────────────────────┐
│                   FLUTTER APP                        │
│  ┌──────────┐  ┌──────────┐  ┌───────────────────┐  │
│  │ Auth Page│  │Forum Page│  │  Voting Page      │  │
│  │ (login)  │  │(diskusi) │  │  (polling)        │  │
│  └────┬─────┘  └────┬─────┘  └────────┬──────────┘  │
│       │              │                 │              │
│  ┌────▼──────────────▼─────────────────▼──────────┐  │
│  │              BLoC Layer                         │  │
│  │  AuthBloc │ ForumBloc │ VotingBloc              │  │
│  └────────────────────┬───────────────────────────┘  │
│                       │                               │
│  ┌────────────────────▼───────────────────────────┐  │
│  │           Repository Layer                      │  │
│  │       auth_repository.dart  (placeholder)       │  │
│  └────────────────────┬───────────────────────────┘  │
└───────────────────────┼─────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────┐
│               SUPABASE (PostgreSQL)                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐   │
│  │  Auth    │  │ PostgREST│  │   pgvector        │   │
│  │ (GoTrue) │  │ (REST)   │  │   (embeddings)    │   │
│  └──────────┘  └──────────┘  └──────────────────┘   │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐   │
│  │ Storage  │  │ Realtime │  │   Functions       │   │
│  │ (MinIO)  │  │(WebSocket)│  │   (Edge/Deno)     │   │
│  └──────────┘  └──────────┘  └──────────────────┘   │
└──────────────────────┬──────────────────────────────┘
                       │
                        ▼
┌─────────────────────────────────────────────────────┐
│              MVP: SUPABASE EDGE FUNCTION (Deno)       │
│  ┌──────────────────────────────────────────────┐   │
│  │  compute-score/index.ts                       │   │
│  │  fetch → openrouter.ai/api/v1/...             │   │
│  │  → relevance_score 0.0-1.0                   │   │
│  └──────────────────────────────────────────────┘   │
│                                                     │
│              FINAL: PYTHON FASTAPI (nanti)           │
│  ┌──────────────────────────────────────────────┐   │
│  │  FastAPI + sentence-transformers              │   │
│  │  • /api/embed        → Bi-Encoder embedding   │   │
│  │  • /api/relevance    → Cross-Encoder score    │   │
│  │  • /api/graph/{id}   → Graph data JSON        │   │
│  └──────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

---

## 2. Flutter App Architecture

### 2.1 Pattern: BLoC (Business Logic Component)

Flutter app menggunakan **BLoC pattern** dengan `flutter_bloc` 9.x:

```
User Event → BLoC (Business Logic) → State → UI Rebuild
```

### 2.2 Layer Structure

```
lib/
├── core/
│   ├── constants.dart      # Konstanta app, routes, storage keys, API URL
│   └── theme.dart          # Material3 theme (seed: hijau #2E7D32)
├── data/
│   ├── models/
│   │   └── user.dart       # User model (id, name, email, role)
│   └── repositories/
│       └── auth_repository.dart  # Singleton auth repository (placeholder)
├── presentation/
│   ├── blocs/
│   │   └── auth/
│   │       └── auth_bloc.dart    # AuthBloc: login, logout, check
│   └── pages/
│       └── auth/
│           └── login_page.dart   # Login form UI
├── app.dart                # KonectApp (MultiBlocProvider + MaterialApp)
├── main.dart               # Entry point
└── routes.dart             # AppRouter + AppNavigator
```

### 2.3 State Management Flow

```dart
// Event → BLoC → State
AuthCheckRequested  → AuthBloc  → AuthLoading → AuthAuthenticated(user)
AuthLoginRequested   → AuthBloc  → AuthLoading → AuthAuthenticated(user)
AuthLogoutRequested  → AuthBloc  → AuthLoading → AuthUnauthenticated
```

### 2.4 Theme (Material3)

- **Seed Color:** `#2E7D32` (hijau koperasi)
- **Light & Dark mode** support via `ThemeMode.system`
- **Card:** elevation 2, borderRadius 12
- **Button:** borderRadius 8, padding 24x12
- **Input:** filled, borderRadius 8

---

## 3. Database Architecture

### 3.1 Hierarchy Data

```
Village (desa)
  └── Users (warga)
        ├── Cooperative Members (anggota koperasi)
        ├── Point Transactions (riwayat poin)
        └── Reactions (voting: agree/disagree/like)
  
Cooperative (kopdes)
  ├── Discussion Rooms / Topics (topik diskusi)
  │     └── Opinions (pendapat = vote)
  │           ├── Discussion Comments (komentar)
  │           └── Reactions (agree/disagree = voting)
  ├── Articles (berita)
  └── Vouchers
        └── Voucher Redemptions (penukaran)
```

### 3.2 Geolocation Trust System

Setiap posting (opinion & comment) menyertakan `latitude` dan `longitude`:

1. Warga harus berada dalam `proximity_radius_meters` dari koperasi
2. Radius default: 200 meter
3. Admin dapat bypass pengecekan lokasi
4. Fungsi `haversine_distance()` menghitung jarak sebenarnya

### 3.3 Enums

```sql
user_role         → 'admin', 'warga'
member_role       → 'ketua', 'bendahara', 'anggota'
reaction_type     → 'agree', 'disagree', 'like'
redemption_status → 'pending', 'completed', 'cancelled'
transaction_type  → 'earn_discussion', 'earn_signup_bonus', 'earn_daily',
                    'redeem_voucher', 'admin_adjust'
```

---

## 4. ML Architecture

### 4.1 MVP (Hackathon) — OpenRouter API via Edge Function

> **Keputusan:** Untuk MVP, skip Python backend. Gunakan OpenRouter API via Supabase Edge Function (Deno).

Kenapa:
- Setup < 1 jam (vs 2-3 hari untuk Python FastAPI + VPS)
- Model gratis (Mistral 7B) via OpenRouter
- Tidak perlu manage server sendiri
- Embedding / pgvector tidak diperlukan untuk demo scoring

**Alur MVP:**

```
Flutter → POST opinion → panggil Edge Function → OpenRouter → LLM → score 0.0-1.0
                                 ↓
                           UPDATE opinions SET relevance_score
                                 ↓
                           GET /graph/{topic_id} → get_topic_graph()
                                 ↓
                           return nodes + edges + x,y position
```

Detail implementasi di `docs/guidances/ml-relevance-ranking.md` dan `docs/memory/ml-relevance-ranking.md`.

### 4.2 Final (Post-Hackathon) — Python FastAPI + Model Lokal

| Model | Fungsi | Output | Kecepatan |
|---|---|---|---|
| Bi-Encoder (multilingual-e5-small) | Generate embedding | Vector(384) | ~12.000 teks/detik |
| Cross-Encoder (ms-marco-MiniLM-L6-v2) | Relevance score | 0.0 - 1.0 | ~1.800 pairs/detik |

### 4.3 Relevance yang Dihitung

| Pair | Makna |
|---|---|
| (topic, opinion) | Seberapa relevan pendapat terhadap topik |
| (opinion, comment) | Seberapa relevan komentar terhadap pendapat |

---

## 5. Infrastruktur

### 5.1 Self-hosted Supabase (Docker Compose)

Layanan yang di-deploy:
- **Studio** — admin panel (port 3000)
- **Kong** — API Gateway (port 8000)
- **Auth (GoTrue)** — authentication service
- **PostgREST** — REST API untuk database
- **Realtime** — WebSocket untuk realtime updates
- **Storage (MinIO)** — file storage
- **imgproxy** — image transformation
- **Meta** — PostgreSQL metadata API
- **Edge Functions** — Deno runtime
- **Analytics (Logflare)** — logging
- **Vector** — log shipping
- **Supavisor** — connection pooler (port 6543)

### 5.2 Catatan Penting

- **Shared DB Hackathon:** Layanan yang butuh role khusus (supabase_admin, authenticator, dll) **tidak jalan** di shared DB
- **Yang jalan:** Studio (read-only metadata), koneksi psql langsung
- **Prefix:** Semua tabel harus pakai prefix `group3b_`
- **Flutter app** konek langsung ke PostgreSQL (bukan via PostgREST)
