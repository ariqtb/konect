# Node Graph & ML Relevance Scoring — PRD

> **Project:** Konect — Koperasi Connect  
> **Doc Version:** 2.0  
> **Date:** 2026-07-09  
> **Status:** Final Draft

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Content Hierarchy](#2-content-hierarchy)
3. [Node Graph Visualization](#3-node-graph-visualization)
4. [ML Relevance Scoring](#4-ml-relevance-scoring)
5. [Database Schema](#5-database-schema)
6. [API Design](#6-api-design)
7. [Frontend Integration](#7-frontend-integration)
8. [Implementation Phases](#8-implementation-phases)
9. [Reference Files](#9-reference-files)

---

## 1. System Overview

Konect memiliki fitur diskusi terstruktur dengan visualisasi **node graph** (seperti Obsidian) yang menunjukkan korelasi antara Topik, Pendapat, dan Komentar. Sistem ML memberikan **relevance score** yang menentukan:

- Posisi node dalam graph (semakin relevan → semakin dekat ke pusat topic)
- Ketebalan edge (korelasi kuat → edge tebal)
- Ranking pendapat/komentar dalam list view (relevan di atas)
- Outlier detection (node tidak relevan tidak memiliki edge)

### Diagram Alur Data

```
User Posting Pendapat
        │
        ▼
    [opinions table]
    content + lat/lng + embedding
        │
        ▼
    Python ML Backend
    ┌─────────────────────┐
    │  sentence-transformers │
    │  Cross-Encoder         │
    │  relevance(topic,idea) │
    └─────────────────────┘
        │
        ▼
    UPDATE opinions SET
    relevance_score = 0.87,
    embedding = [...]
        │
        ▼
    Frontend Graph
    GET /graph/{topic_id}
    → force-graph render
    (semakin tinggi score,
     semakin dekat ke pusat)
```

---

## 2. Content Hierarchy

### 2.1 Tiga Level Hierarki

```
┌──────────────────────────────────────────────────┐
│  TOPIK (discussion_rooms)                        │
│  "Bagaimana distribusi pupuk subsidi?"           │
│                                                   │
│  ├── PENDAPAT A (opinions)                       │
│  │   "Setiap bulan selalu telat seminggu"         │
│  │   ├── KOMENTAR A1 (discussion_comments)        │
│  │   │   "Saya juga alami di desa tetangga"       │
│  │   └── KOMENTAR A2                              │
│  │       "Bahkan kadang 2 minggu"                 │
│  │                                                │
│  ├── PENDAPAT B (relevance_score: 0.92)           │
│  │   "Kios resmi sering kosong stok"              │
│  │   └── KOMENTAR B1                              │
│  │       "Harus pesan jauh-jauh hari"             │
│  │                                                │
│  └── PENDAPAT C (relevance_score: 0.12) ← OUTLIER│
│      "Harga BBM naik terus"                       │
│      (tidak ada edge ke topic → graph pinggiran)  │
└──────────────────────────────────────────────────┘
```

### 2.2 Definisi Entity

| Level | Entity                     | Database Table        | Contoh                        |
| ----- | -------------------------- | --------------------- | ----------------------------- |
| **1** | **Topic** (Topik)          | `discussion_rooms`    | "Bagaimana distribusi pupuk?" |
| **2** | **Opinion/Pendapat** (Ide) | `opinions`            | "Setiap bulan telat seminggu" |
| **3** | **Comment** (Komentar)     | `discussion_comments` | "Saya juga alami"             |

### 2.3 Aturan Hierarki

- **Topic** dibuat oleh admin, menjadi wadah diskusi
- **Opinion/Pendapat** milik warga, terkait langsung ke 1 topic
- **Comment** milik warga, terkait ke 1 opinion (bukan ke topic langsung)
- Comment bisa punya `parent_id` (reply antar komentar dalam 1 opinion)
- Admin bisa posting opinion dan comment dari mana saja (geolocation bypass)
- Warga wajib dalam radius kopdes untuk posting opinion maupun comment

---

## 3. Node Graph Visualization

### 3.1 Konsep Visual (Obsidian-style)

Node graph adalah kanvas interaktif 2D dengan:

- **Nodes** (lingkaran): Topic, Opinion, Comment
- **Edges** (garis): Hubungan antar node
- **Force-directed layout**: Posisi node ditentukan oleh relevance_score
- **Drag & Zoom**: User bisa geser, zoom-in/out

### 3.2 Visual Properties per Node

| Node Type   | Size | Warna                                    | Border    | Posisi                                               |
| ----------- | ---- | ---------------------------------------- | --------- | ---------------------------------------------------- |
| **Topic**   | 20px | Solid (sesuai tema kopdes)               | Tebal 3px | **Pusat graph** (fixed)                              |
| **Opinion** | 12px | Lebih muda dari topic                    | Tipis 1px | Radial: semakin tinggi score, semakin dekat ke topic |
| **Comment** | 7px  | Paling muda, senada dengan opinion induk | None      | Mengelilingi opinion induk                           |

### 3.3 Edge Properties

| Edge Type             | Source → Target     | Ketebalan       | Style                         |
| --------------------- | ------------------- | --------------- | ----------------------------- |
| **Topic → Opinion**   | Topic → Pendapat    | `weight * 4` px | Solid line                    |
| **Opinion → Comment** | Pendapat → Komentar | `weight * 3` px | Solid line                    |
| **Outlier**           | Tidak ada edge      | —               | Node di pinggir tanpa koneksi |

### 3.4 Scoring → Visual Mapping

```
relevance_score    Posisi Node         Edge Thickness    Keterangan
──────────────────────────────────────────────────────────────────
0.85 - 1.00   →  Radius 50px dari pusat   4px solid     Ide paling relevan
0.65 - 0.84   →  Radius 100px              2px solid     Cukup relevan
0.35 - 0.64   →  Radius 180px              1px dashed    Kurang relevan
0.00 - 0.34   →  Radius 280px+             NO EDGE       Outlier
```

### 3.5 Outlier Behavior

Outlier adalah opinion dengan `relevance_score < 0.35` terhadap topic:

- **Tidak memiliki edge** ke topic (atau ke node lain)
- Posisi di **pinggiran canvas**, jauh dari cluster utama
- Bisa di-filter out oleh user via toggle "Tampilkan Outlier"
- ML tetap menyimpan score-nya, naik/turun seiring data baru

### 3.6 Cluster & Warna

```
Topic      →  #FF7A3D (brand orange) — fixed anchor
Opinion    →  shade dari warna topic, makin relevan makin cerah
Comment    →  gradien lebih muda dari opinion induk
Edge       →  gradien dari source ke target color

Setiap topic punya warna unik (hash dari topic_id),
sehingga antar topic bisa dibedakan.
```

### 3.7 Interaksi User

| Aksi                    | Hasil                                            |
| ----------------------- | ------------------------------------------------ |
| **Klik node**           | Buka detail panel (preview konten + score)       |
| **Double klik opinion** | Navigasi ke halaman opinion detail               |
| **Hover edge**          | Tooltip "relevance: 0.87"                        |
| **Drag node**           | Sementara, force simulation akan menarik kembali |
| **Zoom scroll**         | Zoom in/out                                      |
| **Toggle outlier**      | Sembunyikan / tampilkan node outlier             |
| **Search**              | Filter node berdasarkan teks                     |

### 3.8 Data Structure (JSON dari API)

```json
{
  "nodes": [
    {
      "id": "uuid-topic",
      "type": "topic",
      "label": "Distribusi Pupuk Subsidi",
      "relevance_score": 1.0,
      "cluster": "topic-1",
      "size": 20
    },
    {
      "id": "uuid-opinion-1",
      "type": "opinion",
      "label": "Setiap bulan telat seminggu...",
      "relevance_score": 0.91,
      "cluster": "topic-1",
      "size": 12
    },
    {
      "id": "uuid-comment-1",
      "type": "comment",
      "label": "Saya juga alami di desa...",
      "relevance_score": 0.85,
      "cluster": "topic-1",
      "size": 7
    }
  ],
  "edges": [
    {
      "source": "uuid-topic",
      "target": "uuid-opinion-1",
      "weight": 0.91,
      "type": "topic-opinion"
    },
    {
      "source": "uuid-opinion-1",
      "target": "uuid-comment-1",
      "weight": 0.85,
      "type": "opinion-comment"
    }
  ]
}
```

---

## 4. ML Relevance Scoring

### 4.1 Arsitektur

```
┌──────────┐     ┌──────────────────┐     ┌──────────┐
│ Frontend │────▶│ Python FastAPI    │────▶│ PostgreSQL│
│ (React)  │     │ sentence-transform│     │ pgvector  │
│ force-   │     │ ers               │     │           │
│ graph    │◀────│ Cross-Encoder     │◀────│ JSON data │
└──────────┘     └──────────────────┘     └──────────┘
```

### 4.2 Dua Model ML

| Model                                     | Fungsi             | Input     | Output      | Kecepatan          |
| ----------------------------------------- | ------------------ | --------- | ----------- | ------------------ |
| **Bi-Encoder** (all-MiniLM-L6-v2)         | Generate embedding | Teks      | Vector(384) | ~10.000 teks/detik |
| **Cross-Encoder** (ms-marco-MiniLM-L6-v2) | Relevance score    | Pair teks | Score 0-1   | ~1.800 pairs/detik |

### 4.3 Relevance yang Dihitung

| Pair                                          | Kolom di DB                           | Makna                                       |
| --------------------------------------------- | ------------------------------------- | ------------------------------------------- |
| `(topic.title + topic.desc, opinion.content)` | `opinions.relevance_score`            | Seberapa relevan pendapat terhadap topic    |
| `(opinion.content, comment.content)`          | `discussion_comments.relevance_score` | Seberapa relevan komentar terhadap pendapat |

### 4.4 Scoring Flow (Python)

```python
from sentence_transformers import CrossEncoder

model = CrossEncoder("cross-encoder/ms-marco-MiniLM-L6-v2")

def score_opinion_relevance(topic_text: str, opinion_text: str) -> float:
    pair = [topic_text, opinion_text]
    score = model.predict([pair])[0]
    return round(float(score), 4)

def batch_score_opinions(topic_text: str, opinions: list[str]) -> list[float]:
    pairs = [[topic_text, op] for op in opinions]
    scores = model.predict(pairs)
    return [round(float(s), 4) for s in scores]
```

### 4.5 Embedding & Similarity

```python
from sentence_transformers import SentenceTransformer

encoder = SentenceTransformer("all-MiniLM-L6-v2")

def get_embedding(text: str) -> list[float]:
    return encoder.encode(text).tolist()  # 384 dimensions

# Di PostgreSQL:
# SELECT * FROM opinions
# ORDER BY embedding <=> '[0.01, 0.02, ...]'::vector
# LIMIT 10;
```

### 4.6 Schedule & Refresh

| Event                   | Trigger           | Action                                                |
| ----------------------- | ----------------- | ----------------------------------------------------- |
| **Opinion baru dibuat** | Webhook/API       | Generate embedding + score via Python                 |
| **Comment baru dibuat** | Webhook/API       | Generate embedding + score via Python                 |
| **Batch refresh**       | Cron tiap 5 menit | Re-score semua opinion/comment yang belum punya score |
| **Full re-index**       | Cron tiap 1 jam   | Re-score semua data (jika model di-fine-tune)         |

### 4.7 Outlier Threshold

Konfigurasi threshold di Python config:

```python
RELEVANCE_CONFIG = {
    "outlier_threshold": 0.35,   # < ini = outlier
    "strong_threshold": 0.85,    # >= ini = sangat relevan
    "default_score": 0.5000,     # default sebelum di-score
    "batch_size": 64,            # batch inference
}
```

---

## 5. Database Schema

### 5.1 Entity Relationship

```
villages
    │
    ├── users
    │       ├── cooperative_members
    │       ├── point_transactions
    │       └── reactions
    │
    └── cooperatives
            ├── discussion_rooms (TOPIC)
            │       └── opinions (PENDAPAT / VOTE)
            │               ├── discussion_comments (KOMENTAR)
            │               └── reactions (agree/disagree = voting)
            ├── articles (BERITA)
            ├── vouchers
            │       └── voucher_redemptions
            └── ...
```

### 5.2 Key Tables untuk Node Graph

| Table                 | Peran dalam Graph                    | Kolom Penting                                                          |
| --------------------- | ------------------------------------ | ---------------------------------------------------------------------- |
| `discussion_rooms`    | Root node (Topic)                    | id, title, cooperative_id                                              |
| `opinions`            | Level 2 node (sekaligus vote)        | id, room_id, content, **embedding**, **relevance_score**               |
| `discussion_comments` | Level 3 node                         | id, opinion_id, content, parent_id, **embedding**, **relevance_score** |
| `reactions`           | Voting (agree/disagree pada opinion) | user_id, target_type, target_id, reaction                              |

### 5.3 pgvector Index

```sql
-- cosine similarity search
CREATE INDEX idx_opinions_embedding
    ON opinions
    USING ivfflat (embedding vector_cosine_ops)
    WITH (lists = 100);
```

### 5.4 Views untuk Graph

**`get_topic_graph(p_topic_id)`** — function yang return JSON untuk frontend:

```sql
SELECT * FROM get_topic_graph('uuid-topic-id');
-- Returns:
-- { nodes: [...], edges: [...] }
```

**`opinion_ranking`** — view untuk ranking list:

```sql
SELECT * FROM opinion_ranking WHERE topic_id = 'uuid' ORDER BY rank;
```

**`find_similar_opinions(p_opinion_id, p_limit)`** — semantic search:

```sql
SELECT * FROM find_similar_opinions('uuid', 5);
```

---

## 6. API Design

### 6.1 Python FastAPI Endpoints

| Method | Endpoint                        | Fungsi                             |
| ------ | ------------------------------- | ---------------------------------- |
| `POST` | `/api/relevance/score`          | Score 1 pair                       |
| `POST` | `/api/relevance/batch`          | Score batch pairs                  |
| `POST` | `/api/relevance/graph`          | Return graph JSON                  |
| `POST` | `/api/embed`                    | Generate embedding                 |
| `POST` | `/api/embed/batch`              | Batch generate embedding           |
| `GET`  | `/api/graph/{topic_id}`         | Graph data (via `get_topic_graph`) |
| `GET`  | `/api/graph/{topic_id}/ranking` | Opinion ranking per topic          |

### 6.2 Contoh Response

**`GET /api/graph/{topic_id}`**

```json
{
  "topic": {
    "id": "uuid",
    "title": "Distribusi Pupuk Subsidi",
    "total_opinions": 12,
    "total_comments": 47
  },
  "nodes": [...],
  "edges": [...],
  "outliers": [
    { "id": "uuid", "score": 0.12, "label": "Harga BBM naik..." }
  ],
  "meta": {
    "generated_at": "2026-07-09T10:00:00Z",
    "model": "ms-marco-MiniLM-L6-v2",
    "outlier_threshold": 0.35
  }
}
```

**`GET /api/graph/{topic_id}/ranking`**

```json
{
  "opinions": [
    { "rank": 1, "content": "...", "score": 0.94, "comments": 5 },
    { "rank": 2, "content": "...", "score": 0.87, "comments": 3 },
    ...
  ],
  "outliers": [
    { "rank": 12, "content": "...", "score": 0.12, "comments": 0 }
  ]
}
```

---

## 7. Frontend Integration

### 7.1 Library: react-force-graph-2d

```bash
npm install react-force-graph-2d
```

### 7.2 Component Structure

```
components/
├── graph/
│   ├── NodeGraph.tsx          # Main graph canvas
│   ├── GraphNode.tsx          # Custom node render
│   ├── GraphEdge.tsx          # Custom edge render
│   ├── GraphControls.tsx      # Zoom, filter, toggle outlier
│   ├── NodeDetailPanel.tsx    # Side panel saat klik node
│   └── useGraphData.ts        # Hook: fetch + transform data
```

### 7.3 Force Simulation Config

```typescript
const forceConfig = {
  d3AlphaDecay: 0.02, // Stabilitas simulasi
  d3VelocityDecay: 0.3, // Perlambatan
  linkDistance: (link) => {
    // Makin relevan, makin pendek jarak
    return 300 - link.weight * 250;
  },
  linkStrength: (link) => link.weight,
  centerStrength: 0.5,
  chargeStrength: (node) => {
    if (node.type === "topic") return -500; // fixed center
    if (node.type === "opinion") return -200;
    return -100;
  },
};
```

### 7.4 Outlier Filter

```typescript
const filteredNodes = nodes.filter((n) => {
  if (showOutliers) return true;
  return n.relevance_score >= OUTLIER_THRESHOLD; // 0.35
});

const filteredEdges = edges.filter((e) => {
  return (
    filteredNodes.some((n) => n.id === e.source) &&
    filteredNodes.some((n) => n.id === e.target)
  );
});
```

---

## 8. Implementation Phases

### Phase 1: Foundation (Current)

- [x] `001_init_schema.sql` — 12 tabel inti + pgvector + geolocation
- [x] `002_relevance_ml.sql` — functions + views + graph helpers
- [x] Voting via `reactions` (agree/disagree pada opinions) — tidak perlu tabel vote terpisah
- [x] PRD ini

### Phase 2: Python ML Backend

- [ ] Setup FastAPI project (repo terpisah atau `backend/ml/`)
- [ ] POST `/api/embed` — return embedding dari all-MiniLM-L6-v2
- [ ] POST `/api/relevance/score` — return score dari Cross-Encoder
- [ ] POST `/api/relevance/graph` — return data graph dari DB + scores
- [ ] Database hook: saat opinion/comment dibuat → trigger ke Python

### Phase 3: Frontend Graph

- [ ] Install react-force-graph-2d
- [ ] `NodeGraph.tsx` — force-directed graph canvas
- [ ] Node click → detail panel
- [ ] Edge weight → thickness
- [ ] Outlier toggle filter
- [ ] Cluster warna per topic

### Phase 4: Production

- [ ] Auto-embedding via DB trigger + webhook
- [ ] Batch refresh cron job
- [ ] Fine-tuning pipeline
- [ ] Active learning (user feedback loop)

---

## 9. Reference Files

| File                                 | Deskripsi                                                                   |
| ------------------------------------ | --------------------------------------------------------------------------- |
| `database/001_init_schema.sql`       | Schema inti: semua tabel, indexes, triggers, geolocation                    |
| `database/002_relevance_ml.sql`      | ML relevance functions, node graph views, ranking view                      |
| `prd/node-graph-relevance-system.md` | Dokumen ini — PRD lengkap                                                   |
| `prd/ml-relevance-scoring.md`        | Versi 1.0 — detail teknis ML model (bi-encoder, cross-encoder, fine-tuning) |

### Cara Deploy

```bash
# 1. Buat database
createdb konect

# 2. Apply schema (urut)
psql -d konect -f database/001_init_schema.sql
psql -d konect -f database/002_relevance_ml.sql

# 3. Generate TypeScript types (jika pakai Supabase)
supabase gen types typescript --local > lib/supabase/types.ts

# 4. Test graph function
psql -d konect -c "SELECT * FROM get_topic_graph('some-uuid-here');"
```
