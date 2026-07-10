# Konect — ML Scoring (MVP)

## Arsitektur

```
Flutter → Edge Function (Deno) → OpenRouter API → LLM → score
                              ↓
                        UPDATE opinions SET relevance_score
                              ↓
                        get_topic_graph() → x,y dari score
                              ↓
                        Flutter CustomPainter render graph
```

## File

| File | Fungsi |
|---|---|
| `edge-function/index.ts` | Supabase Edge Function — call OpenRouter, return score |
| `sql/003_ml_positions.sql` | Migration — update `get_topic_graph()` dengan x,y + fixes |

## Cara Deploy

### 1. Deploy Edge Function

```bash
# Set OpenRouter API key
supabase secrets set OPENROUTER_KEY=sk-or-v1-your-key-here

# Deploy function
supabase functions deploy compute-score

# Test
curl -X POST https://your-project.supabase.co/functions/v1/compute-score \
  -H "Authorization: Bearer $ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"topic":"Distribusi pupuk","opinion":"Setiap bulan telat"}'
# → {"score": 0.87}
```

### 2. Apply SQL Migration

```bash
psql -d konect -f sql/003_ml_positions.sql
```

### 3. Test Graph

```sql
SELECT * FROM get_topic_graph('your-topic-uuid');
-- → { nodes: [{id, type, label, relevance_score, x, y, ...}], edges: [...] }
```

## Model OpenRouter

| Model | Biaya | Kecepatan |
|---|---|---|
| `mistralai/mistral-7b-instruct:free` | Gratis | ~1-3 detik |
| `google/gemini-2.0-flash-lite-001` | ~$0.075/1M token | ~500ms |

## Fallback

Jika OpenRouter gagal atau timeout, Edge Function return `0.5` (default). Trigger SQL juga set default `0.5` saat INSERT.
