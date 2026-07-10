# ML Relevance Scoring — Project Requirements Document

> **Project**: Konect — Koperasi Connect  
> **Version:** 1.0  
> **Date:** 2026-07-09  
> **Status:** Draft

---

## 1. Problem Statement

Konect adalah platform diskusi/forum untuk koperasi desa. Setiap **topik** bisa berisi banyak **ide/pendapat**, dan setiap ide bisa dikomentari. Masalahnya: semakin banyak konten, semakin sulit peserta menemukan ide dan komentar yang relevan dengan topik yang dibahas.

**Akibat:**
- Ide bagus tenggelam di antara noise
- Peserta tidak bisa melihat korelasi antar ide
- Diskusi tidak terstruktur dan sulit diikuti
- Keputusan koperasi jadi lambat karena informasi tercecer

## 2. Solution Overview

**ML-driven relevance scoring** yang memberikan skor numerik (0.0–1.0) untuk menjawab pertanyaan:

> Seberapa relevan teks X terhadap konteks Y?

Skor ini digunakan untuk:
1. **Node graph canvas** — posisi node menentukan seberapa relevan ide/komentar terhadap topik
2. **Edge strength** — ketebalan garis antar node menunjukkan korelasi
3. **Clustering** — ide/komentar dengan topik serupa dikelompokkan dalam warna sama
4. **Feed sorting** — urutkan konten berdasarkan relevansi

## 3. Tech Stack Decision

### Keputusan: Hybrid (Supabase + Python FastAPI)

| Layer | Teknologi | Alasan |
|---|---|---|
| Database | Supabase (PostgreSQL + pgvector) | Existing, auth + storage terintegrasi |
| Auth | Supabase Auth | Existing |
| **ML Backend** | **Python FastAPI** | **Fine-tuning, latency <50ms, jalan di VPS $5-7** |
| ML Library | `sentence-transformers` | Cross-Encoder siap pakai, dukung fine-tuning |
| Graph Viz | `react-force-graph-2d` | Force-directed graph, canvas, drag/zoom/pan |
| Frontend | React / Next.js | Existing preference |

**Alasan tidak pure Supabase:**
- Supabase Edge Functions tidak bisa jalanin model ML lokal
- API eksternal (Hugging Face / OpenAI) = latency + biaya per request
- Fine-tuning tidak mungkin tanpa server sendiri

## 4. Data Model

### Supabase Tables

```sql
-- Extended dengan vector embeddings
create table topics (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  content text,
  embedding vector(384),  -- dari all-MiniLM-L6-v2
  created_at timestamptz default now()
);

create table ideas (
  id uuid primary key default gen_random_uuid(),
  topic_id uuid references topics(id) on delete cascade,
  content text not null,
  embedding vector(384),
  created_at timestamptz default now()
);

create table comments (
  id uuid primary key default gen_random_uuid(),
  idea_id uuid references ideas(id) on delete cascade,
  content text not null,
  embedding vector(384),
  created_at timestamptz default now()
);
```

### Relevance Scores (Cached / On-Demand)

Tidak disimpan permanen — dihitung on-demand oleh Python API dan dikirim ke frontend bareng data graph:

```json
{
  "nodes": [
    { "id": "topic-1", "type": "topic", "label": "Pupuk Subsidi", "size": 12 },
    { "id": "idea-1", "type": "idea", "label": "Distribusi terlambat", "size": 8, "relevance_score": 0.91 },
    { "id": "comment-1", "type": "comment", "label": "Saya juga alami", "size": 5, "relevance_score": 0.74 }
  ],
  "edges": [
    { "source": "topic-1", "target": "idea-1", "weight": 0.91 },
    { "source": "idea-1", "target": "comment-1", "weight": 0.88 },
    { "source": "idea-1", "target": "idea-2", "weight": 0.63 }
  ]
}
```

## 5. ML Architecture

### Stage 1: Bi-Encoder (all-MiniLM-L6-v2)

- Fungsi: Generate embedding untuk setiap teks
- Dimensi: 384
- Kecepatan: ~10.000 teks/detik
- Output: vector embedding → simpan ke pgvector

### Stage 2: Cross-Encoder (Best Practice)

| Model | Params | Kecepatan | Akurasi |
|---|---|---|---|
| `ms-marco-MiniLM-L6-v2` | 22.7M | 1.800 pair/s | High (default) |
| `ms-marco-TinyBERT-L2-v2` | 4.39M | 9.000 pair/s | Medium |
| **`ettin-reranker-68m-v1`** | 68M | ~500 pair/s | **Highest (2025)** |

**Pilihan:** Mulai dari `ms-marco-MiniLM-L6-v2`, upgrade ke `ettin-reranker` kalo budget GPU mencukupi.

### Relevance Scoring Flow

```
topic text ──┐
              ├── Cross-Encoder ──→ relevance_score: 0.0 - 1.0
idea text  ──┘

topic embedding ──┐
                   ├── Cosine Similarity ──→ similarity: 0.0 - 1.0
idea embedding  ──┘
                   └── Simpan embedding ke pgvector ──→ query tetangga terdekat
```

## 6. API Design

### REST Endpoints — Python FastAPI

```
POST /api/relevance/score
  Body: { "topic": "...", "text": "..." }
  Response: { "score": 0.87 }

POST /api/relevance/batch
  Body: { "topic": "...", "texts": ["...", "...", ...] }
  Response: { "scores": [0.87, 0.32, 0.91] }

POST /api/relevance/graph
  Body: { "topic_id": "uuid" }
  Response: { "nodes": [...], "edges": [...] }

POST /api/embed
  Body: { "texts": ["...", ...] }
  Response: { "embeddings": [[...], ...] }
```

## 7. Dataset & Training

### Data yang Dibutuhkan untuk Fine-tuning

| Tipe Data | Format | Jumlah | Sumber |
|---|---|---|---|
| Topik-Ide pairs | `(topic, idea, relevance_label)` | 500+ | Label manual dari konten forum |
| Ide-Komentar pairs | `(idea, comment, relevance_label)` | 500+ | Label manual |
| Negative mining | Pasang acak yang tidak relevan | 200+ | Auto-generate |

**Label:** 0 = tidak relevan, 1 = relevan

### Labeling Tools

- **Opsi 1:** Label manual via Google Sheets / Airtable — ekspor CSV
- **Opsi 2:** Bootstrapping — pake zero-shot model dulu, lalu humans verify
- **Opsi 3:** Active learning — model predict low-confidence → humans label

### Fine-tuning Script

```python
from sentence_transformers import CrossEncoder
from sentence_transformers.cross_encoder import CrossEncoderModel
from sentence_transformers.losses import BinaryCrossEntropyLoss

model = CrossEncoder("cross-encoder/ms-marco-MiniLM-L6-v2")

# Format data: [(topic, text), label]
train_data = [
    (("Pupuk subsidi telat", "Distribusi di desa saya lambat"), 1),
    (("Pupuk subsidi telat", "Harga sembako naik"), 0),
    ...
]

model.fit(
    train_data=train_data,
    loss=BinaryCrossEntropyLoss(model=model),
    epochs=3,
    batch_size=16,
    warmup_steps=100
)
model.save_pretrained("./model-konect-v1")
```

## 8. Graph Visualization Mapping

### Bagaimana Relevance Score → Graph

| Score | Link Distance | Node Position | Edge Thickness |
|---|---|---|---|
| 0.8–1.0 | Sangat dekat (50px) | Radius dalam | Tebal (4px) |
| 0.6–0.8 | Dekat (100px) | Radius menengah | Sedang (2px) |
| 0.4–0.6 | Sedang (150px) | Radius luar | Tipis (1px) |
| 0.0–0.4 | Jauh (200px+) | Pinggiran | Putus-putus |

### Warna Cluster

Setiap topik punya warna unik. Ide dan comment dengan embedding mirip akan di-cluster dalam shade warna yang sama.

```
Topic      → solid color (e.g., #2E86C1)
Idea       → lighter shade, border sesuai cluster
Comment    → paling light, border sesuai cluster parent
Edge       → gradient dari source color ke target color
```

## 9. Performance Requirements

| Metrik | Target | Metode |
|---|---|---|
| Latency per pair | <100ms | Cross-Encoder lokal (no API call) |
| Batch 50 items | <2s | Parallel inference |
| Graph load topic | <500ms | Query pgvector + hitung pairwise |
| Concurrent users | 50 | Python async + uvicorn workers |
| Model load time | <3s | Load di startup server |

## 10. Implementation Phases

### Phase 1: MVP (1–2 minggu)

- [ ] Setup Python FastAPI + sentence-transformers
- [ ] POST /score endpoint dengan zero-shot model
- [ ] Supabase table tambah kolom embedding
- [ ] React force-graph-2d component
- [ ] Demo: 1 topik, 5 ide, secara manual di-graph

### Phase 2: Production Ready (Minggu 3–4)

- [ ] pgvector queries untuk nearest neighbor
- [ ] Batch scoring endpoint
- [ ] Fine-tuning pipeline
- [ ] Embedding auto-generate saat insert (trigger)
- [ ] Auto-clustering berdasarkan warna

### Phase 3: Optimasi (Minggu 5+)

- [ ] Eksperimen fine-tuning dengan data riil
- [ ] A/B testing: zero-shot vs fine-tuned
- [ ] Cache layer untuk repeated queries
- [ ] Active learning loop

## 11. Risks & Mitigation

| Risk | Dampak | Mitigasi |
|---|---|---|
| Cross-Encoder lambat untuk banyak nodes | Graph loading lambat | Bi-Encoder dulu untuk initial scoring, Cross-Encoder refresh periodik |
| Tidak ada data labeled | Tidak bisa fine-tune | Zero-shot dulu, kumpulin data dari interaksi user |
| Bahasa Indonesia + campuran | Akurasi turun | Cari multilingual model, atau fine-tune dengan data Indo |
| Embedding ukuran besar | Storage meningkat | Cuma simpan embedding untuk 384d model, bukan 768d atau 1024d |
| Server Python mati | ML service down | Health check + auto-restart di deployment |