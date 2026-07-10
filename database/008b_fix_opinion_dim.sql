-- Migration 008b: Fix opinions.embedding dimension
-- 384 -> 1536 to match text-embedding-3-small + new discussion_rooms.embedding
-- Safe karena semua rows masih NULL

alter table public.opinions
  alter column embedding type vector(1536) using embedding::vector(1536);

-- Verify both columns match dim
select
  table_name,
  column_name,
  format_type(udt_name, udt_type) as type
from information_schema.columns
where table_schema='public'
  and ((table_name='opinions' and column_name='embedding')
    or (table_name='discussion_rooms' and column_name='embedding'));
