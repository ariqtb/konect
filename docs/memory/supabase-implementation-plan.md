# Memory — Implementasi Hackathon 2026 di Supabase

> **Author:** sisyphus
> **Tanggal:** 2026-07-10
> **Status:** Draft
> **Tags:** `#memory` `#supabase` `#implementation` `#hackathon-2026` `#migration` `#schema`

---

## 1. Pendahuluan

Memory ini merangkum **rencana migrasi & implementasi** database `hackathon_2026` (PostgreSQL Kemenkop) ke **Supabase** untuk proyek Konect — Koperasi Connect. Mencakup transformasi schema, RLS, indexing, integrasi Auth, dan strategi seeding.

**Tujuan akhir:** Supabase menjadi single source of truth untuk development & demo. Data CSV lokal (`database/sample/`) jadi seed file.

---

## 2. Prinsip Migrasi

| Prinsip | Penjelasan |
|---|---|
| **Schema > CSV** | Migrasi via SQL migration file, BUKAN import CSV langsung. CSV hanya untuk seed data setelah schema siap. |
| **UUID primary key** | Ganti `text` ref (KOP-xxx, AGT-xxx) → `uuid` + tambahkan `legacy_ref text UNIQUE` untuk kompatibilitas dengan data Kemenkop. |
| **Strict types** | `text` untuk nominal → `numeric(15,2)`; `text` untuk status → `text` + CHECK constraint; `text` tanggal → `date` / `timestamptz`. |
| **Foreign keys eksplisit** | DB sumber tidak punya FK. Supabase WAJIB punya FK constraint untuk integritas data. |
| **RLS by default** | Semua table di Supabase harus punya RLS policy. Default: read untuk `authenticated`, write sesuai role. |
| **Soft delete** | Tambah kolom `deleted_at timestamptz` di tabel master (profil, anggota, produk). |
| **Audit trail** | Tambah `created_at`, `updated_at`, `created_by`, `updated_by` (FK ke `auth.users`). |

---

## 3. Pemetaan Tabel (27 → 27)

### 3.1 Tabel Master

| Sumber | Tabel Supabase | Perubahan |
|---|---|---|
| `profil_koperasi` | `profil_koperasi` | + UUID, + FK ke `auth.users` (manager), + soft delete, + indexes |
| `anggota_koperasi` | `anggota_koperasi` | + UUID, + FK ke `profil_koperasi`, + FK ke `auth.users` (user account), + soft delete |
| `pengurus_koperasi` | `pengurus_koperasi` | + UUID, + FK ke `profil_koperasi`, + FK ke `auth.users` (opsional) |
| `karyawan_koperasi` | `karyawan_koperasi` | + UUID, + FK ke `profil_koperasi` |
| `produk_koperasi` | `produk_koperasi` | + UUID, + FK ke `profil_koperasi`, + FK ke `kategori_produk` (lookup) |
| `gerai_koperasi` | `gerai_koperasi` | + UUID, + FK ke `profil_koperasi` |
| `aset_koperasi` | `aset_koperasi` | + UUID, + FK ke `profil_koperasi` |
| `akun_bank_koperasi` | `akun_bank_koperasi` | + UUID, + FK ke `profil_koperasi` |
| `modal_koperasi` | `modal_koperasi` | + UUID, + FK ke `profil_koperasi` |

### 3.2 Tabel Transaksi

| Sumber | Tabel Supabase | Perubahan |
|---|---|---|
| `simpanan_anggota` | `simpanan_anggota` | + UUID, + FK ke `anggota_koperasi`, + FK ke `profil_koperasi` (denormalized), + index `(koperasi_ref, anggota_ref, periode_pembayaran)` |
| `transaksi_penjualan` | `transaksi_penjualan` | + UUID, + FK ke `produk_koperasi` (sample) atau `anggota_koperasi` (real) |
| `barang_masuk_produk` | `barang_masuk_produk` | + UUID, + FK ke `produk_koperasi`, + FK ke `profil_koperasi` |
| `barang_keluar_produk` | `barang_keluar_produk` | + UUID, + FK ke `produk_koperasi`, + FK ke `profil_koperasi` |
| `inventaris_produk` | `inventaris_produk` | + UUID, + FK ke `produk_koperasi`. Bisa digabung ke `produk_koperasi.stok` (denormalized) |

### 3.3 Tabel Pengajuan (Approval Workflow)

| Sumber | Tabel Supabase | Perubahan |
|---|---|---|
| `pengajuan_pembiayaan` | `pengajuan_pembiayaan` | + UUID, + FK ke `profil_koperasi`, + enum `status_permohonan` |
| `pengajuan_kemitraan` | `pengajuan_kemitraan` | + UUID, + FK ke `profil_koperasi` |
| `pengajuan_domain` | `pengajuan_domain` | + UUID, + FK ke `profil_koperasi` |
| `pengajuan_rekening_bank` | `pengajuan_rekening_bank` | + UUID, + FK ke `profil_koperasi`, + FK ke `akun_bank_koperasi` |

### 3.4 Tabel Dokumen

| Sumber | Tabel Supabase | Perubahan |
|---|---|---|
| `dokumen_koperasi` | `dokumen_koperasi` | + UUID, + FK ke `profil_koperasi`, + `file_url text` (link ke Supabase Storage) |
| `rat_koperasi` | `rat_koperasi` | + UUID, + FK ke `profil_koperasi`, + `file_url text` |

### 3.5 Tabel Referensi (Lookup)

| Sumber | Tabel Supabase | Perubahan |
|---|---|---|
| `referensi_wilayah` | `referensi_wilayah` | + UUID, + self-FK untuk hierarki (parent_wilayah_id) |
| `referensi_profil_desa` | `referensi_profil_desa` | + UUID, + FK ke `referensi_wilayah` |
| `referensi_komoditas_desa` | `referensi_komoditas_desa` | + UUID, + FK ke `referensi_wilayah` |
| `referensi_koperasi_wilayah` | `referensi_koperasi_wilayah` | + UUID, + composite FK ke `profil_koperasi` + `referensi_wilayah` (junction table) |
| `referensi_dokumen_koperasi` | `referensi_jenis_dokumen` | rename (lebih deskriptif), + UUID |
| `referensi_gerai_koperasi` | `referensi_jenis_gerai` | rename, + UUID |
| `kbli_koperasi` | `kbli_koperasi` | + UUID, tetap sebagai lookup nasional |

---

## 4. Skema Target — Contoh untuk 3 Tabel Kritis

### 4.1 `profil_koperasi`
```sql
CREATE TABLE public.profil_koperasi (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  legacy_ref text UNIQUE NOT NULL,  -- "KOP-02AFA0134DB2"
  nama_koperasi text NOT NULL,
  status_registrasi text NOT NULL 
    CHECK (status_registrasi IN ('Approved', 'Pending', 'Rejected')),
  bentuk_koperasi text 
    CHECK (bentuk_koperasi IN ('Primer', 'Sekunder')),
  kategori_usaha text,
  nik_koperasi text,
  alamat_lengkap text,
  kode_pos text,
  koordinat_dibulatkan text,
  modal_awal numeric(15,2),  -- cast dari text
  sumber_persetujuan text,
  tentang_koperasi text,
  pola_pengelolaan text,
  metode_pengisian text,
  manager_id uuid REFERENCES auth.users(id),  -- akun pengurus
  deleted_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  created_by uuid REFERENCES auth.users(id),
  updated_by uuid REFERENCES auth.users(id)
);

CREATE INDEX idx_profil_koperasi_status ON profil_koperasi(status_registrasi) 
  WHERE deleted_at IS NULL;
CREATE INDEX idx_profil_koperasi_manager ON profil_koperasi(manager_id);
```

### 4.2 `anggota_koperasi`
```sql
CREATE TABLE public.anggota_koperasi (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  legacy_ref text UNIQUE NOT NULL,
  koperasi_id uuid NOT NULL REFERENCES public.profil_koperasi(id) ON DELETE CASCADE,
  user_id uuid REFERENCES auth.users(id),  -- nullable: "Tidak Punya Akun"
  nama text NOT NULL,
  nik text,
  kode_wilayah text,
  jenis_kelamin text CHECK (jenis_kelamin IN ('LAKI-LAKI', 'PEREMPUAN')),
  status_keanggotaan text NOT NULL 
    CHECK (status_keanggotaan IN ('Approved', 'Requested', 'Rejected')),
  tanggal_terdaftar date,
  file_ktp text,  -- path ke Supabase Storage
  status_akun text CHECK (status_akun IN ('Punya Akun', 'Tidak Punya Akun')),
  pekerjaan text,
  deleted_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_anggota_koperasi_id ON anggota_koperasi(koperasi_id);
CREATE INDEX idx_anggota_koperasi_user ON anggota_koperasi(user_id);
CREATE INDEX idx_anggota_koperasi_status ON anggota_koperasi(status_keanggotaan);
```

### 4.3 `simpanan_anggota`
```sql
CREATE TABLE public.simpanan_anggota (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  legacy_ref text UNIQUE NOT NULL,
  koperasi_id uuid NOT NULL REFERENCES public.profil_koperasi(id),
  anggota_id uuid NOT NULL REFERENCES public.anggota_koperasi(id),
  periode_pembayaran text NOT NULL,  -- "Simpanan Pokok" / "Simpanan Wajib - 2025-08"
  jumlah_simpanan numeric(15,2) NOT NULL DEFAULT 0,
  status text NOT NULL CHECK (status IN ('PAID', 'UNPAID', 'OVERDUE')),
  dibuat_pada timestamptz,
  dibayar_pada timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Index untuk query agregat per koperasi
CREATE INDEX idx_simpanan_koperasi ON simpanan_anggota(koperasi_id);
CREATE INDEX idx_simpanan_anggota ON simpanan_anggota(anggota_id);
CREATE INDEX idx_simpanan_status_periode ON simpanan_anggota(koperasi_id, status, periode_pembayaran);
```

---

## 5. Row Level Security (RLS)

### 5.1 Role Model
- **`admin_kemenkop`** — full access semua koperasi (untuk supervisor Kemenkop)
- **`admin_koperasi`** — full access ke koperasi sendiri
- **`pengurus_koperasi`** — read semua, write ke modul tertentu (anggota, produk, simpanan, RAT)
- **`karyawan_koperasi`** — read + write terbatas (transaksi, barang masuk/keluar)
- **`anggota`** — read data sendiri (profil, simpanan, transaksi)
- **`anon`** — read-only untuk data publik (profil koperasi approved, testimoni)

### 5.2 Contoh Policy — `profil_koperasi`
```sql
ALTER TABLE profil_koperasi ENABLE ROW LEVEL SECURITY;

-- Public read untuk koperasi yang approved
CREATE POLICY "Public can view approved koperasi"
  ON profil_koperasi FOR SELECT
  TO anon, authenticated
  USING (status_registrasi = 'Approved' AND deleted_at IS NULL);

-- Admin koperasi bisa update miliknya
CREATE POLICY "Admin can update own koperasi"
  ON profil_koperasi FOR UPDATE
  TO authenticated
  USING (
    id IN (
      SELECT koperasi_id FROM anggota_koperasi 
      WHERE user_id = auth.uid() 
      AND status_keanggotaan = 'Approved'
    )
    AND EXISTS (
      SELECT 1 FROM auth.users 
      WHERE id = auth.uid() 
      AND raw_user_meta_data->>'role' = 'admin_koperasi'
    )
  );

-- Admin Kemenkop full access
CREATE POLICY "Kemenkop admin full access"
  ON profil_koperasi FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM auth.users 
      WHERE id = auth.uid() 
      AND raw_user_meta_data->>'role' = 'admin_kemenkop'
    )
  );
```

### 5.3 Contoh Policy — `simpanan_anggota`
```sql
ALTER TABLE simpanan_anggota ENABLE ROW LEVEL SECURITY;

-- Anggota bisa lihat simpanan sendiri
CREATE POLICY "Anggota can view own simpanan"
  ON simpanan_anggota FOR SELECT
  TO authenticated
  USING (
    anggota_id IN (
      SELECT id FROM anggota_koperasi WHERE user_id = auth.uid()
    )
  );

-- Pengurus bisa lihat semua simpanan di koperasi sendiri
CREATE POLICY "Pengurus can view koperasi simpanan"
  ON simpanan_anggota FOR ALL
  TO authenticated
  USING (
    koperasi_id IN (
      SELECT koperasi_id FROM anggota_koperasi 
      WHERE user_id = auth.uid()
    )
  );
```

---

## 6. Strategi Seeding

### 6.1 Approach: 2-Tahap
1. **Tahap 1 — Schema first**: Tulis migration SQL lengkap (semua 27 tabel + indexes + RLS) di `supabase/migrations/`.
2. **Tahap 2 — Seed via Edge Function**: Buat Edge Function `seed-hackathon-2026` yang baca CSV dari `database/sample/`, parse, insert ke Supabase. Tangani transformasi `text` → `numeric`/`date`.

### 6.2 Transformasi Wajib Saat Seed
| Sumber | Target | Transformasi |
|---|---|---|
| `modal_awal text` | `numeric(15,2)` | `CAST(modal_awal AS numeric)` — handle "0" / "100000" / "1.500.000" |
| `tanggal_terdaftar text` | `date` | `CAST(tanggal_terdaftar AS date)` — handle `""` (kosong) → NULL |
| `dibuat_pada text` (timestamp) | `timestamptz` | `CAST(dibuat_pada AS timestamptz)` |
| `status_registrasi text` (mixed case) | `text` CHECK | normalize ke title-case "Approved" |
| `KOP-xxx` (text) | `uuid` + `legacy_ref` | generate uuid baru, simpan text di `legacy_ref` |

### 6.3 Script Edge Function (sketsa)
```typescript
// supabase/functions/seed-hackathon-2026/index.ts
import { createClient } from '@supabase/supabase-js'
import { parse } from 'https://deno.land/std/csv/mod.ts'

const supabase = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!)

const TABLES = [
  { file: 'profil_koperasi.csv', order: 1, transform: transformProfil },
  { file: 'anggota_koperasi.csv', order: 2, transform: transformAnggota },
  { file: 'simpanan_anggota.csv', order: 3, transform: transformSimpanan, batch: 1000 },
  // ... 24 tabel lainnya
]

for (const t of TABLES.sort((a,b) => a.order - b.order)) {
  const csv = await Deno.readTextFile(`./csv/${t.file}`)
  const rows = parse(csv, { skipFirstRow: true })
  // batch insert dengan transform
}
```

> **Performance note:** `simpanan_anggota` (372k rows) perlu batching per 1.000 baris untuk avoid timeout.

---

## 7. Supabase Storage

### 7.1 Bucket Plan
| Bucket | Isi | Akses |
|---|---|---|
| `koperasi-files` | `file_ktp`, dokumen AD/ART, NPWP, formulir pengajuan | Private (RLS per koperasi) |
| `produk-images` | Gambar produk | Public read, write per koperasi |
| `avatars` | Foto pengurus, karyawan, anggota | Public read, write per user |

### 7.2 Path Convention
```
koperasi-files/{koperasi_legacy_ref}/anggota/{anggota_legacy_ref}/ktp.jpg
koperasi-files/{koperasi_legacy_ref}/dokumen/{doc_id}/{filename}
produk-images/{koperasi_legacy_ref}/{produk_legacy_ref}/{image_id}.jpg
avatars/{user_id}/avatar.jpg
```

---

## 8. Real-time Subscriptions

Untuk fitur notifikasi & dashboard live, aktifkan realtime di tabel berikut:
```sql
ALTER PUBLICATION supabase_realtime ADD TABLE simpanan_anggota;
ALTER PUBLICATION supabase_realtime ADD TABLE transaksi_penjualan;
ALTER PUBLICATION supabase_realtime ADD TABLE barang_masuk_produk;
ALTER PUBLICATION supabase_realtime ADD TABLE barang_keluar_produk;
ALTER PUBLICATION supabase_realtime ADD TABLE inventaris_produk;
```

---

## 9. Integrasi dengan Stack Konect

> **Stack Konect:** Flutter app + Supabase (PostgreSQL+pgvector+Storage+Realtime+Edge Functions) + Python FastAPI untuk ML. Lihat `docs/memory/architecture.md` untuk diagram lengkap.

### 9.1 Frontend (Flutter)
```dart
// Contoh query anggota + simpanan dari Flutter via Supabase client
final response = await supabase
  .from('anggota_koperasi')
  .select('id, nama, nik, status_keanggotaan, simpanan_anggota(jumlah_simpanan, status)')
  .eq('koperasi_id', currentKoperasiId)
  .eq('status_keanggotaan', 'Approved');
```

### 9.2 Python FastAPI (ML Backend)
```python
# Baca dari Supabase untuk fine-tuning
from supabase import create_client
supabase = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)
data = supabase.table("anggota_koperasi").select("*").limit(1000).execute()
# → DataFrame untuk training
```

### 9.3 Edge Functions (Business Logic)
Letakkan logic berikut di Edge Functions (bukan client):
- Validasi pengajuan (cek kelengkapan dokumen, nominal wajar, dll)
- Generate nomor referensi baru (KOP-xxx, AGT-xxx)
- Hitung ulang stok inventaris saat ada barang masuk/keluar
- Kirim notifikasi ke pengurus saat ada pengajuan baru

---

## 10. Action Items / Roadmap

| # | Task | Owner | Status |
|---|---|---|---|
| 1 | Audit & finalize schema untuk 27 tabel (SQL migration) | — | TODO |
| 2 | Tulis migration `001_init_schema.sql` (semua CREATE TABLE) | — | TODO |
| 3 | Tulis migration `002_rls_policies.sql` | — | TODO |
| 4 | Tulis migration `003_indexes.sql` | — | TODO |
| 5 | Tulis migration `004_triggers.sql` (updated_at auto-update) | — | TODO |
| 6 | Setup Supabase Storage buckets (3 buckets) | — | TODO |
| 7 | Buat Edge Function `seed-hackathon-2026` | — | TODO |
| 8 | Test seeding end-to-end di Supabase dev project | — | TODO |
| 9 | Setup Supabase Auth (email + OTP, role assignment) | — | TODO |
| 10 | Integrasi dengan frontend & ML backend | — | TODO |
| 11 | Tulis seed test minimal (~5 koperasi) untuk CI | — | TODO |
| 12 | Backup strategy (pg_dump harian ke S3) | — | TODO |

---

## 11. Risiko & Mitigasi

| Risiko | Mitigasi |
|---|---|
| **Seeding timeout** untuk `simpanan_anggota` (372k rows) | Batch insert per 1.000, jalankan via Edge Function dengan timeout extension |
| **CSV parsing error** (encoding, delimiter, quote) | Validasi schema CSV dulu, gunakan library `papaparse` (TS) atau `pandas` (Python) yang handle edge cases |
| **FK constraint violation** saat seeding | Seed dengan urutan: `profil_koperasi` → `anggota_koperasi` → `simpanan_anggota` (parent dulu) |
| **RLS blocking seed** | Pakai `service_role` key saat seeding, JANGAN pakai anon/authenticated |
| **Data Kemenkop berubah** (refresh) | Bikin seed idempotent (pakai `legacy_ref` untuk upsert) |
| **Storage quota** (estimasi: 1.026 koperasi × 50 MB foto = 50 GB) | Pakai tier Supabase Pro ($25/mo) atau self-host MinIO |
| **RLS performance** di tabel besar (`simpanan_anggota`) | Tambah index pada kolom yang dipakai di policy (`koperasi_id`, `anggota_id`) |

---

## 12. Referensi

### Memory Tim Konect
- `docs/memory/project-overview.md` — overview Konect, target user, latar belakang KDMP
- `docs/memory/architecture.md` — Flutter + Supabase + Python FastAPI diagram
- `docs/memory/database-schema.md` — **schema app Konect** (villages, cooperatives, discussion_rooms, opinions, dll). **Mapping penting:** data hackathon_2026 adalah **seed** yang dipetakan ke tabel-tabel Konect ini.
- `docs/memory/domain-context.md` — konteks bisnis Koperasi Desa Merah Putih & trust economy

### Memory & Guidance Terkait
- `docs/memory/hackathon-2026-data-source.md` — sumber data, kredensial, cara akses
- `docs/guidances/hackathon-2026-data-overview.md` — dokumentasi 27 tabel hackathon

### CSV & PRD
- `database/sample/*.csv` — 27 file seed
- `docs/prd/ml-relevance-scoring.md` — PRD ML relevance
- `docs/simkopdes/metadata_database_hackathon_final.xlsx` — metadata resmi Kemenkop

### External
- Supabase RLS: https://supabase.com/docs/guides/auth/row-level-security
- Supabase Storage: https://supabase.com/docs/guides/storage
