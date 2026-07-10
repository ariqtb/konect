# Database Hackathon 2026 — Referensi Data Koperasi Desa

> **Author:** sisyphus
> **Tanggal:** 2026-07-10
> **Status:** Final
> **Tags:** `#guidance` `#database` `#hackathon-2026` `#koperasi` `#data-overview`

---

## 1. Pendahuluan

Dokumen ini menjelaskan isi database `hackathon_2026` yang disediakan oleh **Kementerian Koperasi (Kemenkop)** untuk **Hackathon Digital Cooperatives Expo 2026**. Database ini menjadi **sumber data utama** aplikasi Konect — Koperasi Connect.

Data diekstrak dari PostgreSQL (Google Cloud SQL) di `34.101.155.200:5432`, database `hackathon_2026`, dan disimpan dalam format CSV di `database/sample/` (27 file, total ~70 MB, ~524.000 baris).

> **Catatan:** Data bersifat **sample/anonymized** — nama anggota `"SAMPLE-ANGGOTA"`, NIK ter-mask (`920305**********`), nama pelanggan `"Pelanggan-XXXXXX"`. Pola dan volume realistis, identitas bukan data riil.

---

## 2. Domain Bisnis: Koperasi Desa Merah Putih

Database ini merepresentasikan ekosistem **Koperasi Desa/Kelurahan Merah Putih** — program nasional Kemenkop untuk membentuk koperasi di setiap desa/kelurahan. Data mengikuti alur:

```
Profil Koperasi
   ├── Pengurus (pengurus_koperasi)
   ├── Karyawan (karyawan_koperasi)
   ├── Aset (aset_koperasi, modal_koperasi)
   ├── Akun Bank (akun_bank_koperasi, pengajuan_rekening_bank)
   ├── Anggota (anggota_koperasi)
   │     └── Simpanan (simpanan_anggota)
   ├── Gerai (gerai_koperasi)
   │     ├── Produk (produk_koperasi)
   │     │     └── Inventaris (inventaris_produk)
   │     ├── Barang Masuk (barang_masuk_produk)
   │     ├── Barang Keluar (barang_keluar_produk)
   │     └── Transaksi Penjualan (transaksi_penjualan)
   ├── Dokumen (dokumen_koperasi)
   ├── RAT (rat_koperasi)
   ├── Pengajuan Kemitraan (pengajuan_kemitraan)
   ├── Pengajuan Pembiayaan (pengajuan_pembiayaan)
   └── Pengajuan Domain (pengajuan_domain)
```

---

## 3. Ringkasan Tabel (27 Tabel, ~524.000 Baris)

| No | Tabel | Baris | Tipe | Deskripsi Singkat |
|---|---|---:|---|---|
| 1 | `simpanan_anggota` | 372.407 | Transaksi | Simpanan wajib/pokok/sukarela anggota per periode |
| 2 | `anggota_koperasi` | 74.269 | Master | Profil lengkap anggota koperasi |
| 3 | `kbli_koperasi` | 30.000 | Referensi | Kode KBLI (Klasifikasi Baku Lapangan Usaha Indonesia) |
| 4 | `inventaris_produk` | 13.974 | Transaksi | Stok & harga produk di koperasi |
| 5 | `produk_koperasi` | 13.974 | Master | Katalog produk yang dijual |
| 6 | `pengurus_koperasi` | 8.482 | Master | Pengurus (ketua, sekretaris, bendahara, pengawas) |
| 7 | `referensi_komoditas_desa` | 8.191 | Referensi | Komoditas unggulan tiap desa |
| 8 | `dokumen_koperasi` | 4.171 | Dokumen | Metadata dokumen (AD/ART, NPWP, dll) |
| 9 | `pengajuan_kemitraan` | 3.254 | Pengajuan | Pengajuan kerja sama dengan pihak ketiga |
| 10 | `gerai_koperasi` | 1.942 | Master | Gerai/cabang/unit usaha koperasi |
| 11 | `pengajuan_domain` | 1.039 | Pengajuan | Pengajuan domain website koperasi |
| 12 | `profil_koperasi` | 1.026 | Master | **Profil utama koperasi** (semua status Approved) |
| 13 | `referensi_koperasi_wilayah` | 1.026 | Relasi | Mapping koperasi → wilayah |
| 14 | `referensi_profil_desa` | 1.026 | Referensi | Profil desa (penduduk, luas, dll) |
| 15 | `referensi_wilayah` | 1.026 | Referensi | Hierarki wilayah (provinsi/kab/kota/kec/desa) |
| 16 | `transaksi_penjualan` | 1.000 | Transaksi | Riwayat penjualan (Rp 18.600 - Rp 468.000) |
| 17 | `karyawan_koperasi` | 942 | Master | Karyawan non-pengurus |
| 18 | `aset_koperasi` | 924 | Master | Aset tetap (tanah, bangunan, kendaraan, dll) |
| 19 | `akun_bank_koperasi` | 903 | Master | Rekening bank koperasi |
| 20 | `barang_keluar_produk` | 884 | Transaksi | Pengurangan stok (penjualan/internal) |
| 21 | `barang_masuk_produk` | 665 | Transaksi | Penambahan stok (pembelian/produksi) |
| 22 | `pengajuan_rekening_bank` | 652 | Pengajuan | Pengajuan buka rekening bank |
| 23 | `rat_koperasi` | 341 | Dokumen | Risalah Rapat Anggota Tahunan |
| 24 | `pengajuan_pembiayaan` | 118 | Pengajuan | Pengajuan kredit/pembiayaan ke lembaga keuangan |
| 25 | `modal_koperasi` | 26 | Master | Modal awal & perubahan modal |
| 26 | `referensi_dokumen_koperasi` | 8 | Referensi | Jenis dokumen koperasi |
| 27 | `referensi_gerai_koperasi` | 8 | Referensi | Jenis gerai koperasi |

---

## 4. Skema per Tabel (Kolom Penting)

### 4.1 Master Data

#### `profil_koperasi` (1.026 baris)
TABEL UTAMA — identitas koperasi.
```
koperasi_ref          text PK     — ID format KOP-XXXXXXXXXXXX
nama_koperasi         text        — Contoh: "KOPERASI DESA MERAH PUTIH KARTINI KAMPUNG LESTARI CAHAYA"
status_registrasi     text        — Semua "Approved"
bentuk_koperasi       text        — "Primer" / "Sekunder"
kategori_usaha        text        — Simpan pinjam, produksi, konsumsi, dll
nik_koperasi          text        — NIK legalitas koperasi
alamat_lengkap        text
kode_pos              text
koordinat_dibulatkan  text
modal_awal            text        — Nominal modal (perlu cast ke numeric)
sumber_persetujuan    text        — "Kemenkop" / "Inisiatif Sendiri" / dll
tentang_koperasi      text        — Deskripsi
pola_pengelolaan      text
metode_pengisian      text
dibuat_pada           timestamp
diperbarui_pada       timestamp
```

#### `anggota_koperasi` (74.269 baris)
```
anggota_ref           text PK     — AGT-XXXXXXXXXXXX
koperasi_ref          text FK     — Relasi ke profil_koperasi
nama                  text        — "SAMPLE-ANGGOTA" (data dummy)
nik                   text        — Masked: "920305**********"
kode_wilayah          text        — Kode wilayah BPS
jenis_kelamin         text        — "LAKI-LAKI" / "PEREMPUAN"
status_keanggotaan    text        — "Approved" / "Requested" / "Rejected"
tanggal_terdaftar     date
file_ktp              text        — Path/URL file KTP
status_akun           text        — "Punya Akun" / "Tidak Punya Akun"
pekerjaan             text        — "PETANI" / "NELAYAN" / "PEDAGANG" / dll
```

#### `pengurus_koperasi` (8.482 baris)
```
pengurus_ref          text PK
koperasi_ref          text FK
nama                  text
jabatan               text        — "Ketua" / "Sekretaris" / "Bendahara" / "Pengawas"
periode_mulai         date
periode_selesai       date
```

#### `karyawan_koperasi` (942 baris)
```
karyawan_ref          text PK
koperasi_ref          text FK
nama                  text
jabatan               text
tanggal_bergabung     date
status                text
```

### 4.2 Transaksi

#### `simpanan_anggota` (372.407 baris) — **PALING BESAR**
```
simpanan_ref          text PK     — SIMPAN-XXXXXXXXXXXX
koperasi_ref          text FK
anggota_ref           text FK
periode_pembayaran    text        — "Simpanan Pokok" / "Simpanan Wajib - Agustus 2025" / dll
jumlah_simpanan       numeric     — 0 - 100.000+
status                text        — "PAID" / "UNPAID"
dibuat_pada           timestamp
dibayar_pada          timestamp
```

#### `transaksi_penjualan` (1.000 baris)
```
transaksi_sample_id   text PK     — TRX-XXXXXXXXXXXX
koperasi_ref          text FK
nama_pelanggan        text        — "Pelanggan-XXXXXXXX"
tanggal_dibuat        timestamp
total_pembayaran      numeric     — Rp 18.600 - Rp 468.000
status_transaksi      text        — "Paid" / "Pending" / "Cancelled"
metode_pembayaran     text        — Tunai, QRIS, Transfer, dll
```

#### `barang_masuk_produk` (665) & `barang_keluar_produk` (884)
```
[masuk/keluar]_ref    text PK
koperasi_ref          text FK
produk_ref            text FK
jumlah                numeric
tanggal_[masuk/keluar] date
keterangan            text
```

#### `inventaris_produk` (13.974)
```
inventaris_ref        text PK
koperasi_ref          text FK
produk_ref            text FK
stok                  numeric
harga_satuan          numeric
tanggal_update        timestamp
```

### 4.3 Pengajuan

#### `pengajuan_pembiayaan` (118)
```
pengajuan_pembiayaan_ref text PK
koperasi_ref             text FK
nik                      text
penanggung_jawab         text
nomor_penanggung_jawab   text
status_permohonan        text
formulir_permohonan      text        — Path file
nominal_permohonan       real
tenor                    integer     — bulan
tujuan_permohonan        text
```

#### `pengajuan_kemitraan` (3.254), `pengajuan_domain` (1.039), `pengajuan_rekening_bank` (652)
Pola serupa: `pengajuan_ref`, `koperasi_ref`, field spesifik, `status`.

### 4.4 Master Pendukung

#### `produk_koperasi` (13.974)
```
produk_ref        text PK
koperasi_ref      text FK
nama_produk       text
kategori_produk   text
harga             numeric
satuan            text        — "kg" / "pcs" / "liter"
deskripsi         text
```

#### `gerai_koperasi` (1.942)
```
gerai_ref         text PK
koperasi_ref      text FK
nama_gerai        text
jenis_gerai       text        — dari referensi_gerai_koperasi
alamat            text
koordinat         text
```

#### `aset_koperasi` (924), `akun_bank_koperasi` (903), `modal_koperasi` (26)
Aset tetap, rekening bank, dan modal koperasi.

### 4.5 Tabel Referensi

| Tabel | Baris | Fungsi |
|---|---:|---|
| `referensi_wilayah` | 1.026 | Hierarki wilayah (prov → kab → kec → desa) |
| `referensi_profil_desa` | 1.026 | Profil demografi desa |
| `referensi_komoditas_desa` | 8.191 | Komoditas unggulan per desa |
| `kbli_koperasi` | 30.000 | Standar KBLI (Klasifikasi Lapangan Usaha) |
| `referensi_dokumen_koperasi` | 8 | Jenis-jenis dokumen (AD/ART, NPWP, dll) |
| `referensi_gerai_koperasi` | 8 | Jenis-jenis gerai |

---

## 5. Relasi (ERD Sederhana)

```
profil_koperasi (1) ───< (N) pengurus_koperasi
                  (1) ───< (N) karyawan_koperasi
                  (1) ───< (N) anggota_koperasi (1) ───< (N) simpanan_anggota
                  (1) ───< (N) aset_koperasi
                  (1) ───< (N) akun_bank_koperasi
                  (1) ───< (N) modal_koperasi
                  (1) ───< (N) gerai_koperasi (1) ───< (N) produk_koperasi
                  (1) ───< (N) dokumen_koperasi
                  (1) ───< (N) rat_koperasi
                  (1) ───< (N) pengajuan_kemitraan
                  (1) ───< (N) pengajuan_pembiayaan
                  (1) ───< (N) pengajuan_domain
                  (1) ───< (N) pengajuan_rekening_bank

produk_koperasi (1) ───< (N) inventaris_produk
                 (1) ───< (N) barang_masuk_produk
                 (1) ───< (N) barang_keluar_produk
                 (1) ───< (N) transaksi_penjualan

referensi_wilayah (1) ───< (N) referensi_profil_desa
                    (1) ───< (N) referensi_komoditas_desa
                    (1) ───< (N) referensi_koperasi_wilayah
```

**Catatan:** Foreign key **tidak dideklarasikan secara eksplisit** di database sumber — semua relasi hanya lewat konvensi penamaan `*_ref`.

---

## 6. Karakteristik Data

| Aspek | Kondisi | Implikasi |
|---|---|---|
| **Identitas** | Dummy/sample | Tidak untuk produksi, hanya untuk development & demo |
| **PII** | NIK masked, nama generik | Aman untuk development |
| **Tipe data** | Banyak kolom `text` untuk field yang seharusnya `numeric`/`date` | Perlu konversi saat migrasi |
| **FK constraint** | Tidak ada constraint DB-level | Perlu validasi di application layer |
| **Timestamps** | `timestamp without time zone` | Hilang info timezone, perlu normalisasi ke `timestamptz` |
| **Status field** | String tanpa CHECK constraint | Perlu enum atau CHECK di Supabase |
| **Konsistensi** | Semua `profil_koperasi` berstatus "Approved" | Skip filter "Pending" di UI |
| **Distribusi** | 74k anggota tersebar di 1.026 koperasi | Rata-rata ~72 anggota/koperasi |

---

## 7. Contoh Data (Sample)

**Profil Koperasi:**
```
KOP-02AFA0134DB2 | KOPERASI DESA MERAH PUTIH KARTINI KAMPUNG LESTARI CAHAYA
KOP-5640DE941587 | KOPERASI KELURAHAN MERAH PUTIH NIRMALA SAMARINDA SIDODADI SEJAHTERA ULU
KOP-04DAA6F9705B | KOPERASI KELURAHAN MERAH PUTIH RAYA LEMBAH LESTARI BERINGIN
```

**Anggota:**
```
AGT-B73C67C627F6 | SAMPLE-ANGGOTA | 920305********** | Approved     | PETANI
AGT-AC000BC12B9B | SAMPLE-ANGGOTA | 337406********** | Requested    | (kosong)
AGT-15C8E68AC871 | SAMPLE-ANGGOTA | 517103********** | Approved     | (kosong)
```

**Simpanan:**
```
SIMPAN-B935A3CA010B | AGT-072BB5D0F173 | 100.000 | PAID   | Simpanan Pokok
SIMPAN-3EDF6378C0B0 | AGT-0D7E22D97A1B |       0 | UNPAID | Simpanan Wajib - Agustus 2025
```

**Transaksi Penjualan:**
```
TRX-472D0E4DEF92 | Pelanggan-E47BACD6AD | 38.000  | Paid
TRX-71C24BFC73AF | Pelanggan-306DB6217C | 18.600  | Paid
TRX-8105183C2EF0 | Pelanggan-892176188E | 468.000 | Paid
```

---

## 8. Akses Data

### Lokasi File CSV Lokal
Semua 27 tabel tersedia sebagai CSV di `database/sample/`:
```
database/sample/
├── akun_bank_koperasi.csv       (90 KB)
├── anggota_koperasi.csv         (13 MB)
├── ... (25 file lainnya)
└── simpanan_anggota.csv         (45 MB — terbesar)
```

### Koneksi Ulang ke Sumber
```bash
# Dari server Ubuntu via Docker postgres
PGPASSWORD='*H4ck4thonK3men0P2026@' \
docker exec -i postgres psql \
  -h 34.101.155.200 \
  -p 5432 \
  -U hackathon_participant_2026 \
  -d hackathon_2026 \
  -c "SELECT * FROM profil_koperasi LIMIT 5"
```

---

## 9. Referensi

- Lihat: `docs/memory/hackathon-2026-data-source.md` — detail sumber data & kredensial
- Lihat: `docs/memory/supabase-implementation-plan.md` — rencana migrasi ke Supabase
- Lihat: `docs/simkopdes/metadata_database_hackathon_final.xlsx` — metadata resmi dari Kemenkop
- Lihat: `docs/simkopdes/TOR HACKATHON KEMENKOP 2026 [Final].pdf` — Terms of Reference hackathon
- Lihat: `docs/prd/ml-relevance-scoring.md` — PRD proyek Konect
- File CSV: `database/sample/*.csv`
