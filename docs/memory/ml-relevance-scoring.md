# ML Relevance Scoring — Cara Pakai

> Quick reference untuk tim. Direct, no fluff.

## 1. Singkatnya

- **Apa:** Skor 0-1 yang mengukur seberapa relevan sebuah opini dengan topic-nya. Opini relevan = lebih dekat ke topic di canvas.
- **Bagaimana:** Cosine similarity antara embedding(opinion) vs embedding(topic), dimensi 1536, model `text-embedding-3-small` via OpenRouter.
- **Dimana:** Server Supabase (`43.157.247.43`). Database `konect`. Edge Function di Deno.

## 2. Quick Start (sekali)

```bash
# 1. Apply migrations (urutan penting!)
psql -U postgres -d konect -f database/008_topic_embeddings.sql
psql -U postgres -d konect -f database/008b_fix_opinion_dim.sql
psql -U postgres -d konect -f database/009_backfill_embeddings.sql   # output dari script Python
psql -U postgres -d konect -f database/010_fix_relevance_trigger.sql
psql -U postgres -d konect -f database/011_canvas_coordinates.sql

# 2. Set env
echo "OPENROUTER_API_KEY=sk-or-v1-..." >> .env

# 3. Tambah di docker-compose.yml functions.environment:
#    OPENROUTER_API_KEY: ${OPENROUTER_API_KEY}

# 4. Deploy edge function
mkdir -p volumes/functions/compute-embedding
cp volumes/functions/compute-embedding/index.ts  # ke server
# Tambah route di main/index.ts:
#   if (path === "/compute-embedding") {
#     const mod = await import("../compute-embedding/index.ts");
#     return await mod.default(req);
#   }

# 5. Force-recreate containers
docker compose up -d --force-recreate rest functions
docker compose restart kong
```

## 3. REST API

### Ambil graph topic (nodes + edges + x,y)

```http
POST /rest/v1/rpc/get_topic_graph
Content-Type: application/json

{ "p_topic_id": "00000000-0000-0000-0000-000000000010" }
```

**Response:**
```json
{
  "nodes": [
    { "id": "...-topic", "type": "topic", "label": "...", "relevance_score": 1.0,
      "cluster": "root", "size": 24, "x": 0, "y": 0 },
    { "id": "...-opinion", "type": "opinion", "label": "...", "relevance_score": 0.62,
      "cluster": "opinion", "size": 14, "x": 95.84, "y": -3.38 }
  ],
  "edges": [
    { "source": "...-topic", "target": "...-opinion",
      "weight": 0.62, "type": "topic-opinion" }
  ]
}
```

**Konvensi koordinat:**
- Topic selalu di (0, 0).
- Makin tinggi `relevance_score`, makin DEKAT ke topic.
- `radius = (1.0 - score) × 250px`, angle deterministik dari hash(node_id).

### Cari opini mirip

```http
POST /rest/v1/rpc/find_similar_opinions
Content-Type: application/json

{ "p_opinion_id": "...", "p_limit": 5 }
```

## 4. Edge Function

### Hitung embedding + relevance untuk opini baru

```http
POST /functions/v1/compute-embedding
Content-Type: application/json

{
  "opinion_id": "uuid",
  "content": "teks opini...",
  "room_id": "uuid-topic"
}
```

**Response (200):**
```json
{
  "success": true,
  "opinion_id": "uuid",
  "relevance_score": 0.5255,
  "embedding_dim": 1536,
  "model": "openai/text-embedding-3-small"
}
```

**Error:**
- `422`: topic belum punya embedding (jalankan backfill dulu)
- `502`: OpenRouter gagal
- `500`: server error

## 5. Flutter Integration

**Flow insert opini baru:**

```dart
// 1. INSERT opini (relevance_score=0.5 default, embedding=NULL)
final res = await supabase.from('opinions').insert({
  'room_id': roomId,
  'user_id': userId,
  'content': content,
  'latitude': lat,
  'longitude': lng,
}).select('id').single();

final opinionId = res['id'] as String;

// 2. Panggil edge function untuk hitung embedding
await supabase.functions.invoke('compute-embedding', body: {
  'opinion_id': opinionId,
  'content': content,
  'room_id': roomId,
});

// 3. Fetch graph topic
final graph = await supabase.rpc('get_topic_graph',
  params: {'p_topic_id': roomId});
```

**Render canvas (CustomPainter):**

```dart
for (final node in graph['nodes'] as List) {
  final pos = Offset(
    (node['x'] as num).toDouble(),
    (node['y'] as num).toDouble(),
  );
  final size = (node['size'] as num).toDouble();
  // Gambar lingkaran di pos dengan radius size
}

for (final edge in graph['edges'] as List) {
  // Cari source & target node, gambar garis
}
```

## 6. Tambah Kata / Update Manual

**Hitung ulang relevance untuk satu opini:**
```sql
update opinions
set relevance_score = (
  select 1.0 - (o.embedding <=> dr.embedding)
  from discussion_rooms dr
  where dr.id = o.room_id
)
from opinions o
where opinions.id = o.id;
```

**Lihat ranking per topic:**
```sql
select topic_title, opinion_preview, relevance_score, rank
from opinion_ranking
where topic_id = '...'
order by rank;
```

**Re-backfill embedding topic baru:**
```sql
-- 1. Compute embedding via edge function atau script Python
-- 2. Update manual:
update discussion_rooms
set embedding = '[0.1, 0.2, ...]'::vector
where id = '...';
```

## 7. Troubleshooting

| Error | Fix |
|---|---|
| `expected 384 dimensions, not 1536` | PostgREST schema cache stale. Run: `docker compose up -d --force-recreate rest && docker compose restart kong` |
| `OPENROUTER_API_KEY not set` | Tambah di `.env` + docker-compose, recreate functions container |
| `Topic embedding not computed` | Jalankan `009_backfill_embeddings.py` untuk topic yang missing |
| `Function not found: compute-embedding` | Route belum ditambah di `main/index.ts`, atau edge function file belum di-deploy |
| Relevance semua 0.5 | Trigger belum aktif atau embedding NULL. Check: `select proname, prosrc from pg_proc where proname='auto_compute_opinion_relevance'` |

## 8. File Reference

| File | Fungsi |
|---|---|
| `database/008_topic_embeddings.sql` | Tambah `embedding` ke `discussion_rooms` |
| `database/008b_fix_opinion_dim.sql` | Alter `opinions.embedding` ke 1536 |
| `database/009_backfill_embeddings.py` | Script hitung embedding via OpenRouter |
| `database/010_fix_relevance_trigger.sql` | Replace stub trigger dengan cosine |
| `database/011_canvas_coordinates.sql` | Tambah x,y ke `get_topic_graph` |
| `database/volumes/functions/compute-embedding/index.ts` | Edge function opini baru |
| `database/volumes/functions/main/index.ts` | Router (tambah route di sini) |

Detail implementasi lengkap + decision log: `docs/guidances/ml-relevance-implementation.md`.
