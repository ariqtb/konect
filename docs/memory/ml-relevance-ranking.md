# ML Relevance Ranking — Pedoman Implementasi MVP

> **Author:** sisyphus
> **Tanggal:** 2026-07-10
> **Status:** Final
> **Tags:** `#ml` `#relevance` `#ranking` `#node-graph` `#mvp` `#openrouter`

---

## 1. Keputusan Arsitektur MVP

**Untuk hackathon, skip Python backend.** Gunakan OpenRouter API via Supabase Edge Function (Deno).

| Detail | Keputusan |
|---|---|
| Scoring API | OpenRouter (`mistralai/mistral-7b-instruct:free`) |
| Backend | Supabase Edge Function (Deno) — 1 file, deploy via `supabase functions deploy` |
| Embedding + pgvector | Skip dulu — tidak diperlukan untuk demo |
| X,Y position | Compute on-the-fly di `get_topic_graph()` — tidak perlu migrasi DDL |

## 2. Alur Data

```
Flutter → INSERT opinion → panggil Edge Function → OpenRouter → score
                                 ↓
                           UPDATE opinions SET relevance_score
                                 ↓
                           GET /graph/{id} → get_topic_graph()
                                 ↓
                           return nodes + edges + x,y position
```

## 3. Relevance → X,Y (Obsidian-like Canvas)

DDL saat ini hanya punya `relevance_score`. Posisi canvas dihitung dari:

```
radius = (1.0 - relevance_score) × MAX_RADIUS
angle  = hash(node_id) mod 360°   (deterministik)
x = center_x + radius × cos(angle)
y = center_y + radius × sin(angle)
```

Function `get_topic_graph()` sudah di-update di `docs/guidances/ml-relevance-ranking.md` untuk return x,y.

## 4. File Penting

| File | Fungsi |
|---|---|
| `docs/guidances/ml-relevance-ranking.md` | Pedoman lengkap implementasi MVP |
| `supabase/functions/compute-score/index.ts` | Edge function scoring (belum dibuat) |
| `database/002_relevance_ml.sql` | Perlu update `get_topic_graph()` dengan x,y |

## 5. Yang Di-skip untuk MVP

| Skip | Alasan |
|---|---|
| Python FastAPI | OpenRouter handle scoring |
| pgvector + embedding | Tidak perlu similarity search di demo |
| Hybrid scoring (engagement+dll) | Cukup semantic score |
| Fine-tuning | Zero-shot via OpenRouter |
| Migration DDL baru | x,y di-compute di function |
| react-force-graph-2d | CustomPainter Flutter cukup |

## 6. Timeline Sisa

| Waktu | Target |
|---|---|
| 3:50-5 PM | Edge Function + OpenRouter |
| 5-6 PM | Update `get_topic_graph()` |
| 6-8 PM | Flutter graph page (CustomPainter) |
| 8-9 PM | Integrasi scoring pas post |
| Besok | Testing + polish |

---

## 7. Referensi

- `docs/guidances/ml-relevance-ranking.md` — Pedoman implementasi lengkap
- `database/001_init_schema.sql` — Schema inti
- `database/002_relevance_ml.sql` — ML functions (perlu update)
- `docs/prd/ml-relevance-scoring.md` — PRD versi awal (Python-based, outdated untuk MVP)
