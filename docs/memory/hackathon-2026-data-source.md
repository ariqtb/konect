# Memory — Data Source Hackathon 2026

> **Author:** sisyphus
> **Tanggal:** 2026-07-10
> **Status:** Final
> **Tags:** `#memory` `#data-source` `#hackathon-2026` `#postgresql` `#kemenkop`

---

## 1. Pendahuluan

Memory ini mencatat **asal-usul data koperasi** yang digunakan di proyek Konect: di mana database berada, bagaimana cara mengaksesnya, dan di mana salinan lokalnya. Agent lain yang butuh data asli atau perlu refresh data harus baca file ini dulu.

---

## 2. Sumber Data

| Aspek | Nilai |
|---|---|
| **Database** | `hackathon_2026` |
| **Engine** | PostgreSQL 17.10 (via Docker image `postgres:17.10-alpine`) |
| **Host** | `34.101.155.200` (Google Cloud SQL — bukan local) |
| **Port** | `5432` |
| **User** | `hackathon_participant_2026` |
| **Password** | `*H4ck4thonK3men0P2026@` (perlu di-quote pakai single quote karena ada `*` dan `@`) |
| **Owner DB** | `cloudsqlsuperuser` (managed instance) |
| **Encoding** | UTF-8, locale `en_US.UTF8` |
| **Timezone** | `timestamp without time zone` (data waktu tanpa TZ — perlu normalisasi) |
| **Jumlah tabel** | 27 |
| **Total baris** | ~524.000 |
| **Status data** | **Sample/anonymized** (nama "SAMPLE-ANGGOTA", NIK masked) |

### Konteks Sumber
Database ini disediakan oleh **Kementerian Koperasi UKM (Kemenkop)** untuk peserta **Hackathon Digital Cooperatives Expo 2026**. Setiap tim mendapat akses read-only ke shared database untuk development aplikasi. Referensi: `docs/simkopdes/TOR HACKATHON KEMENKOP 2026 [Final].pdf`.

---

## 3. Salinan Lokal (CSV)

Semua data sudah diekstrak ke **`database/sample/`** sebagai 27 file CSV (satu file per tabel, total ~70 MB, format UTF-8 dengan header):

```
database/sample/
├── akun_bank_koperasi.csv        (   90 KB,   903 baris)
├── anggota_koperasi.csv          (   13 MB, 74.269 baris)
├── aset_koperasi.csv             (  191 KB,   924 baris)
├── barang_keluar_produk.csv      (  159 KB,   884 baris)
├── barang_masuk_produk.csv       (  129 KB,   665 baris)
├── dokumen_koperasi.csv          (  578 KB, 4.171 baris)
├── gerai_koperasi.csv            (  332 KB, 1.942 baris)
├── inventaris_produk.csv         ( 1.8 MB, 13.974 baris)
├── karyawan_koperasi.csv         (  129 KB,   942 baris)
├── kbli_koperasi.csv             ( 4.3 MB, 30.000 baris)
├── modal_koperasi.csv            (  4.4 KB,    26 baris)
├── pengajuan_domain.csv          (  126 KB, 1.039 baris)
├── pengajuan_kemitraan.csv       (  717 KB, 3.254 baris)
├── pengajuan_pembiayaan.csv      (   17 KB,   118 baris)
├── pengajuan_rekening_bank.csv   (   89 KB,   652 baris)
├── pengurus_koperasi.csv         ( 1.8 MB, 8.482 baris)
├── produk_koperasi.csv           ( 1.6 MB, 13.974 baris)
├── profil_koperasi.csv           (  369 KB, 1.026 baris)
├── rat_koperasi.csv              ( 1.6 MB,   341 baris)
├── referensi_dokumen_koperasi.csv(   757 B,     8 baris)
├── referensi_gerai_koperasi.csv  (   774 B,     8 baris)
├── referensi_komoditas_desa.csv  (  887 KB, 8.191 baris)
├── referensi_koperasi_wilayah.csv(   73 KB, 1.026 baris)
├── referensi_profil_desa.csv     (   88 KB, 1.026 baris)
├── referensi_wilayah.csv         (  108 KB, 1.026 baris)
├── simpanan_anggota.csv          (   45 MB, 372.407 baris) ← terbesar
└── transaksi_penjualan.csv       (  132 KB, 1.000 baris)
```

> **Penting:** CSV ini adalah salinan read-only. Untuk konsistensi, treat sebagai source of truth lokal; refresh dari DB hanya jika ada update dari Kemenkop.

---

## 4. Cara Akses Ulang ke Database Sumber

### Prasyarat
- Akses internet ke `34.101.155.200:5432` (cek `pg_hba.conf` — saat ini menerima koneksi dari IP manapun dengan password).
- `psql` client (bisa pakai Docker postgres image).

### Opsi A: Lewat Docker postgres lokal
```bash
PGPASSWORD='*H4ck4thonK3men0P2026@' \
docker run --rm -it postgres:17.10-alpine psql \
  -h 34.101.155.200 \
  -p 5432 \
  -U hackathon_participant_2026 \
  -d hackathon_2026
```

### Opsi B: Lewat server Ubuntu `43.157.247.43` (Docker postgres yang sudah running)
```bash
ssh ubuntu@43.157.247.43
sudo docker exec -i -e PGPASSWORD='*H4ck4thonK3men0P2026@' \
  postgres psql -h 34.101.155.200 -U hackathon_participant_2026 -d hackathon_2026
```

### Opsi C: pg_dump seluruh database
```bash
PGPASSWORD='*H4ck4thonK3men0P2026@' \
pg_dump -h 34.101.155.200 -U hackathon_participant_2026 -d hackathon_2026 \
  --no-owner --no-acl > hackathon_2026.sql
```

### Opsi D: Export ulang per tabel ke CSV
```bash
# 1. Tulis SQL \copy commands ke file
cat > /tmp/dump.sql <<'EOF'
\COPY profil_koperasi TO '/tmp/profil_koperasi.csv' WITH (FORMAT csv, HEADER true)
\COPY anggota_koperasi TO '/tmp/anggota_koperasi.csv' WITH (FORMAT csv, HEADER true)
... (27 tabel)
EOF

# 2. Copy ke container & run
sudo docker cp /tmp/dump.sql postgres:/tmp/
sudo docker exec -i -e PGPASSWORD='*H4ck4thonK3men0P2026@' \
  postgres psql -h 34.101.155.200 -U hackathon_participant_2026 -d hackathon_2026 -f /tmp/dump.sql

# 3. Copy out & pull
sudo docker cp postgres:/tmp/hackathon_dump /tmp/
scp ubuntu@43.157.247.43:/tmp/hackathon_dump/*.csv ./database/sample/
```

---

## 5. Caveat & Limitasi

| Caveat | Detail |
|---|---|
| **Karakter khusus password** | Password `*H4ck4thonK3men0P2026@` mengandung `*` (glob karakter di bash) dan `@`. **Selalu** bungkus dengan single quote: `PGPASSWORD='*H4ck4thonK3men0P2026@'`. |
| **Password prompt issue di docker exec** | `docker exec -i postgres psql ...` TIDAK mewarisi `PGPASSWORD` dari shell host. Harus pakai `-e PGPASSWORD=...` pada `docker exec`. |
| **SQL file path** | `psql -f /tmp/file.sql` di dalam container = path di dalam container, bukan di host. Jika file dibuat di host, copy dulu: `docker cp /host/file.sql container:/tmp/`. |
| **SSL** | Database sumber belum pakai SSL (`pg_hba.conf: no encryption`). Untuk production WAJIB aktifkan SSL. |
| **TLS / firewall** | Database bisa ditutup sewaktu-waktu oleh Kemenkop setelah hackathon selesai. |
| **Read-only** | User `hackathon_participant_2026` adalah user biasa; bisa saja tidak punya akses tulis. Konfirmasi dengan tim Kemenkop jika butuh write. |
| **Sampling** | Data adalah sample/dummy — **JANGAN** pakai untuk validasi production-grade atau compliance check. |

---

## 6. Sumber Metadata

| File | Lokasi | Fungsi |
|---|---|---|
| Metadata resmi DB | `docs/simkopdes/metadata_database_hackathon_final.xlsx` | Definisi kolom & relasi dari Kemenkop |
| TOR Hackathon | `docs/simkopdes/TOR HACKATHON KEMENKOP 2026 [Final].pdf` | Aturan & scope hackathon |
| House Rules | `docs/simkopdes/HACK HOUSE RULES- ...pdf` | Aturan peserta |
| Email invitation | `docs/simkopdes/email.txt` | Undangan & info akun |
| CSV lokal | `database/sample/*.csv` | Salinan data 27 tabel |
| Dokumentasi lengkap | `docs/guidances/hackathon-2026-data-overview.md` | Schema, ERD, sample data |

---

## 7. Tindakan yang Sudah Dilakukan

| Tanggal | Aksi | Oleh |
|---|---|---|
| 2026-07-10 | Konek DB & verifikasi koneksi | sisyphus |
| 2026-07-10 | List 27 tabel + row count via `pg_stat_user_tables` | sisyphus |
| 2026-07-10 | Ekstrak 27 tabel ke CSV (70 MB) di `database/sample/` | sisyphus |
| 2026-07-10 | Buat dokumentasi `hackathon-2026-data-overview.md` | sisyphus |

---

## 8. Referensi

- Dokumentasi data: `docs/guidances/hackathon-2026-data-overview.md`
- Implementasi Supabase: `docs/memory/supabase-implementation-plan.md`
- PRD Konect: `docs/prd/ml-relevance-scoring.md`
- Arsitektur Konect: `docs/architecture/` (jika ada)
