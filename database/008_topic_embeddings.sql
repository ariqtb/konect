-- =============================================================
-- Migration 008: Topic embeddings
-- Date: 2026-07-11
-- Purpose: Tambah kolom embedding ke discussion_rooms untuk cosine
--          similarity dengan opinion embeddings
--
-- Dimension: 1536 (text-embedding-3-small via OpenRouter)
-- Decision: 1536 lebih reliable di OpenRouter, $0.02/1M tokens,
--           tidak perlu install Python di server.
-- =============================================================

-- Drop column kalau ada (untuk idempotent re-run)
alter table public.discussion_rooms
  drop column if exists embedding;

-- Tambah kolom embedding vector(1536)
alter table public.discussion_rooms
  add column embedding vector(1536);

-- HNSW index untuk similarity search (optional, enable kalau ada 100+ topic)
-- create index idx_discussion_rooms_embedding on public.discussion_rooms
--   using hnsw (embedding vector_cosine_ops);

-- Verify
comment on column public.discussion_rooms.embedding is
  'Topic embedding 1536-dim, computed via OpenRouter text-embedding-3-small. NULL = not yet computed.';
