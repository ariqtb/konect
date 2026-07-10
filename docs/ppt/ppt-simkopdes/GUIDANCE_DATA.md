# Panduan Data — Koperasi Desa Merah Putih

> **Versi:** 1.0 | **Tanggal:** 10 Juli 2026  
> **Tujuan:** Menjelaskan definisi setiap data, bagaimana antar-data berelasi, rumus perhitungannya, serta referensi file path-nya.  
> **Lokasi Panduan:** `docs/ppt/ppt-simkopdes/GUIDANCE_DATA.md`  
> **Dokumen Terkait:** `AGREGASI.md` (alur pipeline data), `data-raw/` (data mentah), `data-charts/` (data chart siap Canva)

---

## Daftar Isi

1. [Struktur Direktori Data](#1-struktur-direktori-data)
2. [Data SIMKOPDES — Definisi & Kolom](#2-data-simkopdes--definisi--kolom)
3. [Data Keuangan — Rumus & Perhitungan](#3-data-keuangan--rumus--perhitungan)
4. [Data Sentimen & Opini Publik](#4-data-sentimen--opini-publik)
5. [Data Isu Kritis](#5-data-isu-kritis)
6. [Data Stakeholders](#6-data-stakeholders)
7. [Data Timeline](#7-data-timeline)
8. [Data Trust Analysis](#8-data-trust-analysis)
9. [Relasi Antar Data](#9-relasi-antar-data)
10. [Glosarium](#10-glosarium)

---

## 1. Struktur Direktori Data

```
docs/references/                          ← Sumber JSON asli (tidak diubah)
├── simkopdes_national.json               ← A1 — Data nasional
├── simkopdes_province.json               ← A2 — Data per provinsi
├── simkopdes_transaksi.json              ← A3 — Data transaksi/produk
├── simkopdes_kelembagaan.json            ← A4 — Data kelembagaan
├── simkopdes_ews_keuangan.json           ← A5 — Data EWS keuangan
├── sentiment.json                        ← B1 — Sentimen publik
├── issues.json                           ← B2 — Isu kritis
├── stakeholders.json                     ← B3 — Pemangku kepentingan
├── data_points.json                      ← B4 — Data-data penting
├── timeline.json                         ← B5 — Kronologi
├── trust_analysis.json                   ← B6 — Analisis kepercayaan
├── analysis_insights.json               ← B7 — Insight
└── sources_list.json                     ← C1 — Daftar sumber

docs/ppt/ppt-simkopdes/
├── data-raw/                             ← CSV mentah (dari JSON)
│   ├── raw_simkopdes_*.csv               ←   SIMKOPDES (15 file)
│   └── raw_*.csv                         ←   Sentimen, isu, dll (11 file)
├── data-charts/                          ← CSV siap chart Canva (19 file)
├── research/                             ← Riset media sosial
│   ├── tiktok_findings.csv
│   ├── youtube_findings.csv
│   └── sentimen_analysis.md
├── AGREGASI.md                           ← Pipeline data
└── GUIDANCE_DATA.md                      ← ← Kamu di sini
```

---

## 2. Data SIMKOPDES — Definisi & Kolom

### 2.1 `raw_simkopdes_national.csv`

**File:** `data-raw/raw_simkopdes_national.csv` | **Sumber:** `docs/references/simkopdes_national.json` (A1)  
**Deskripsi:** Agregat nasional dashboard SIMKOPDES per 9 Juli 2026.

| Metrik | Arti | Satuan |
|--------|------|--------|
| `Total_Koperasi` | Total seluruh koperasi desa/kelurahan yang terdaftar | unit |
| `Koperasi_Kelurahan` | Koperasi di wilayah kelurahan | unit |
| `Koperasi_Desa` | Koperasi di wilayah desa | unit |
| `Telah_Memiliki_Akun` | Koperasi yang sudah memiliki akun di sistem SIMKOPDES | unit |
| `Telah_Memiliki_NPWP` | Koperasi yang sudah memiliki NPWP | unit |
| `Telah_Memiliki_NIB` | Koperasi yang sudah memiliki Nomor Induk Berusaha | unit |
| `Simpanan_Pokok` | Total simpanan pokok anggota (setoran awal) | IDR |
| `Simpanan_Wajib` | Total simpanan wajib anggota (setoran rutin) | IDR |
| `Volume_Transaksi_2026` | Jumlah transaksi yang tercatat tahun 2026 | unit transaksi |
| `Nilai_Transaksi_2026` | Total nilai transaksi tahun 2026 | IDR |
| `Total_Pendapatan` | Pendapatan seluruh koperasi | IDR |
| `Total_Beban` | Beban/biaya seluruh koperasi | IDR |
| `Total_Aset` | Aset total seluruh koperasi | IDR |
| `Total_Liabilitas` | Utang/kewajiban seluruh koperasi | IDR |
| `Total_Ekuitas` | Modal sendiri total (Aset − Liabilitas) | IDR |
| `Koperasi_Sudah_RAT_2025` | Koperasi yang sudah mengadakan RAT tahun 2025 | unit |
| `Koperasi_Sedang_RAT_Draft` | Koperasi yang masih dalam proses RAT (draft) | unit |
| `Koperasi_Belum_RAT` | Koperasi yang belum RAT | unit |
| `Koperasi_Diverifikasi_Dinas` | Koperasi yang sudah diverifikasi oleh dinas | unit |
| `Lahan_Diajukan` | Jumlah lahan yang diajukan untuk pembangunan gerai | unit |
| `Lahan_Terverifikasi` | Jumlah lahan yang sudah diverifikasi | unit |
| `Pembangunan_100_Persen` | Jumlah gerai yang sudah 100% jadi | unit |
| `Pembangunan_100_Persen_Persen` | Persentase gerai 100% jadi | % |
| `Sedang_Pembangunan_Persen` | Persentase gerai dalam proses pembangunan | % |
| `Belum_Mulai_Persen` | Persentase gerai belum dibangun | % |
| `Koperasi_Belum_Lapor` | Koperasi yang belum lapor keuangan | unit |
| `Koperasi_Belum_Lapor_Persen` | Persentase koperasi belum lapor | % |
| `Koperasi_Tidak_Sehat` | Koperasi berstatus tidak sehat (EWS) | unit |
| `Koperasi_Tidak_Sehat_Persen` | Persentase tidak sehat (dari yg lapor) | % |
| `Koperasi_Cukup_Sehat` | Koperasi berstatus cukup sehat | unit |
| `Koperasi_Cukup_Sehat_Persen` | Persentase cukup sehat | % |
| `Koperasi_Sehat` | Koperasi berstatus sehat | unit |
| `Koperasi_Sehat_Persen` | Persentase sehat | % |

### 2.2 `raw_simkopdes_province.csv`

**File:** `data-raw/raw_simkopdes_province.csv` | **Sumber:** A2  
**Deskripsi:** Data per provinsi — 38 provinsi, merupakan *master table* untuk verifikasi lintas file.

| Kolom | Arti |
|-------|------|
| `Provinsi` | Nama provinsi |
| `Jumlah_Koperasi` | Total koperasi di provinsi tersebut |
| `Memiliki_NIB` | Jumlah koperasi yang punya NIB |
| `Memiliki_NPWP` | Jumlah koperasi yang punya NPWP |
| `Telah_RAT_2025` | Jumlah koperasi yang sudah RAT 2025 |
| `Simpanan_Pokok` | Total simpanan pokok provinsi |
| `Simpanan_Wajib` | Total simpanan wajib provinsi |
| `Volume_Transaksi_2026` | Jumlah transaksi provinsi |
| `Nilai_Transaksi_2026` | Nilai transaksi provinsi |
| `Persen_Lahan_Terverifikasi` | % lahan terverifikasi dari yang diajukan |
| `Persen_Pembangunan_Gerai` | % gerai sudah jadi dari total di provinsi |

### 2.3 `raw_simkopdes_kelembagaan.csv`

**File:** `data-raw/raw_simkopdes_kelembagaan.csv` | **Sumber:** A4  
**Deskripsi:** Detail kelembagaan per provinsi — memecah jumlah koperasi menjadi koperasi kelurahan vs desa.

| Kolom | Arti |
|-------|------|
| `Rank` | Peringkat (berdasarkan Total) |
| `Provinsi` | Nama provinsi |
| `Kelurahan` | Jumlah koperasi di wilayah kelurahan |
| `Desa` | Jumlah koperasi di wilayah desa |
| `Total` | Total koperasi (= Kelurahan + Desa) |
| `Persentase_Terhadap_Target` | % pencapaian terhadap target pembentukan Kopdes |

### 2.4 `raw_simkopdes_produk_top10.csv`

**File:** `data-raw/raw_simkopdes_produk_top10.csv` | **Sumber:** A3  
**Deskripsi:** Top 10 produk dengan nilai transaksi tertinggi di seluruh koperasi.

| Kolom | Arti |
|-------|------|
| `Rank` | Peringkat |
| `Produk` | Nama produk (Pupuk NPK, Urea, Minyak Goreng, dll) |
| `Volume` | Jumlah unit terjual |
| `Nilai` | Total nilai transaksi (IDR) |

**Catatan:** Dua produk teratas (Pupuk NPK & Urea) mendominasi — total Rp26,37 triliun atau ~46,6% dari seluruh nilai transaksi. Ini menunjukkan Kopdes lebih berfungsi sebagai distributor pupuk bersubsidi daripada koperasi serba usaha.

### 2.5 `raw_simkopdes_koperasi_aktif_top10.csv`

**File:** `data-raw/raw_simkopdes_koperasi_aktif_top10.csv` | **Sumber:** A3  
**Deskripsi:** 10 koperasi dengan nilai transaksi tertinggi.

| Kolom | Arti |
|-------|------|
| `Rank` | Peringkat |
| `Nama_Koperasi` | Nama koperasi |
| `Lokasi` | Desa, Kecamatan, Kabupaten, Provinsi |
| `Nilai` | Nilai transaksi (IDR) |

### 2.6 `raw_simkopdes_transaksi_per_provinsi.csv`

**File:** `data-raw/raw_simkopdes_transaksi_per_provinsi.csv` | **Sumber:** A3  
**Deskripsi:** Top 10 provinsi berdasarkan nilai transaksi.

| Kolom | Arti |
|-------|------|
| `Rank` | Peringkat |
| `Provinsi` | Nama provinsi |
| `Total_Transaksi` | Jumlah transaksi |
| `Nilai` | Nilai transaksi (IDR) |

### 2.7 `raw_simkopdes_ews_kesehatan.csv`

**File:** `data-raw/raw_simkopdes_ews_kesehatan.csv` | **Sumber:** A5  
**Deskripsi:** Status kesehatan koperasi dari Early Warning System (EWS) SIMKOPDES.

| Kolom | Arti |
|-------|------|
| `Kategori` | Sehat / Cukup_Sehat / Tidak_Sehat |
| `Jumlah` | Jumlah koperasi |
| `Persen` | Persentase (dari 31.265 koperasi yang sudah lapor) |

### 2.8 `raw_simkopdes_ews_laporan.csv`

**File:** `data-raw/raw_simkopdes_ews_laporan.csv` | **Sumber:** A5  
**Deskripsi:** Status kepatuhan laporan keuangan koperasi.

| Kolom | Arti |
|-------|------|
| `Status` | Sudah_Lapor / Belum_Lapor |
| `Jumlah` | Jumlah koperasi |
| `Persen` | Persentase (dari total 83.382 koperasi) |

### 2.9 `raw_simkopdes_ews_ringkasan_keuangan.csv`

**File:** `data-raw/raw_simkopdes_ews_ringkasan_keuangan.csv` | **Sumber:** A5  
**Deskripsi:** Ringkasan keuangan agregat dari koperasi yang sudah lapor.

| Kolom | Arti |
|-------|------|
| `Pendapatan_Total` | Total pendapatan |
| `Beban_Total` | Total beban |
| `Aset_Total` | Total aset |
| `Liabilitas_Total` | Total liabilitas |
| `Ekuitas_Total` | Total ekuitas |
| `Rasio_Pendapatan_Beban` | Rasio P/B (dihitung) |
| `Rasio_Aset_Liabilitas` | Rasio A/L (dihitung) |

### 2.10 `raw_simkopdes_ews_top5_*.csv`

**File:** `data-raw/raw_simkopdes_ews_top5_pendapatan.csv`, `_beban.csv`, `_aset.csv`, `_liabilitas.csv`, `_ekuitas.csv`, `_provinsi_sehat.csv` | **Sumber:** A5  
**Deskripsi:** Top 5 provinsi untuk masing-masing metrik keuangan. Sederhana: 2 kolom — `Rank`, `Provinsi`, `Nilai`.

---

## 3. Data Keuangan — Rumus & Perhitungan

### 3.1 Rasio-Rasio Utama

#### Rasio Pendapatan / Beban
```
Rumus:  Pendapatan_Total / Beban_Total
        = 85.260.000.000 / 29.190.000.000
        = 2,92
```
**Arti:** Setiap Rp1 beban menghasilkan Rp2,92 pendapatan.  
**Sumber data:** `raw_simkopdes_ews_ringkasan_keuangan.csv` baris 2 & 3  
**File hasil:** `data-charts/12_rasio_keuangan_utama.csv`

#### Rasio Aset / Liabilitas
```
Rumus:  Aset_Total / Liabilitas_Total
        = 453.890.000.000 / 61.590.000.000
        = 7,37
```
**Arti:** Aset 7,37x lebih besar dari liabilitas — secara akuntansi solvabel.  
**Sumber data:** `raw_simkopdes_ews_ringkasan_keuangan.csv` baris 4 & 5

#### Rasio Simpanan Pokok / Simpanan Wajib
```
Rumus:  Simpanan_Pokok / Simpanan_Wajib (nasional)
        = 41.514.541.015 / 10.374.248.180
        = 4,0
```
**Arti:** Simpanan pokok 4x lebih besar dari wajib — menunjukkan anggota lebih banyak membayar setoran awal daripada iuran rutin.

### 3.2 Persentase Kesehatan Koperasi
```
Rumus sehat:     683 / 31.265 × 100 = 2,2%
Rumus cukup:   2.087 / 31.265 × 100 = 6,7%
Rumus tidak:  28.495 / 31.265 × 100 = 91,1%

Total:         31.265 (yang sudah lapor keuangan)
```
**PENTING:** Denominator-nya adalah **31.265 koperasi yang sudah lapor**, bukan 83.382 total koperasi. Jika pakai total (83.382):
- Sehat: 0,8%
- Cukup: 2,5%
- Tidak: 34,2%
- **Tidak terklasifikasi (belum lapor): 62,5%**

**Sumber data:** `raw_simkopdes_ews_kesehatan.csv`  
**File chart:** `data-charts/01a_kesehatan_koperasi_dari_yang_lapor.csv`

### 3.3 Persentase Belum Lapor
```
Rumus:  52.117 / 83.382 × 100 = 62,5%
```
**Sumber data:** `raw_simkopdes_ews_laporan.csv`  
**File chart:** `data-charts/01b_status_lapor_keuangan.csv`

### 3.4 Persentase Pembangunan Gerai
```
Rumus:  15.533 (100%)  /  35.870 (lahan terverifikasi) × 100  = 43,3%
        55,3% = sedang pembangunan
         1,4% = belum mulai
```
**Catatan:** Denominator = lahan terverifikasi (35.870), bukan total lahan diajukan (38.053).  
**Sumber data:** `raw_simkopdes_national.csv` baris 21-26

### 3.5 Tingkat Partisipasi Anggota

| Indikator | Rumus | Hasil |
|-----------|-------|-------|
| Kepemilikan Akun | 79.706/83.382 | 95,6% |
| Kepemilikan NPWP | 80.978/83.382 | 97,1% |
| Kepemilikan NIB | 60.773/83.382 | 72,9% |
| Sudah RAT 2025 | 50.264/83.382 | 60,3% |
| Sedang RAT Draft | 14.346/83.382 | 17,2% |
| Belum RAT | 18.772/83.382 | 22,5% |

### 3.6 Persentase Lahan Terverifikasi per Provinsi
```
Rumus:  (Lahan_Terverifikasi_provinsi / Lahan_Diajukan_provinsi) × 100
```
**Sumber data:** `raw_simkopdes_province.csv` kolom `Persen_Lahan_Terverifikasi`

### 3.7 Persentase Pembangunan Gerai per Provinsi
```
Rumus:  (Gerai_100%_jadi_provinsi / Total_Gerai_provinsi) × 100
```
**Sumber data:** `raw_simkopdes_province.csv` kolom `Persen_Pembangunan_Gerai`

### 3.8 Target vs Realisasi
```
Target awal:   80.000 Kopdes (diumumkan Mei 2025)
Target revisi: 40.000 Kopdes (Maret 2026) — turun 50%
Realisasi:     35.870 lahan terverifikasi → 15.533 gerai 100% jadi (43,3%)

Persentase terhadap target revisi:   15.533 / 40.000 = 38,8%
Persentase terhadap target awal:     15.533 / 80.000 = 19,4%
```

### 3.9 Konsentrasi Jawa
```
Tiga provinsi Jawa:  Jawa Tengah (8.524) + Jawa Timur (8.494) + Jawa Barat (5.970)
                    = 22.988 koperasi

Persentase nasional: 22.988 / 83.382 × 100 = 27,6%
```
**Sumber data:** `raw_simkopdes_kelembagaan.csv`  
**File chart:** `data-charts/08_konsentrasi_jawa.csv`

### 3.10 Rasio Koperasi vs Jumlah Penduduk (Data Eksternal)

Perhitungan ini TIDAK ada di data SIMKOPDES, bisa ditambahkan dari data BPS:
- Jumlah desa/kelurahan di Indonesia: ~83.000
- Target Kopdes: 40.000 → berarti ~48% desa akan punya Kopdes
- Realisasi gerai 100% jadi: 15.533 → ~19% desa sudah punya gerai

---

## 4. Data Sentimen & Opini Publik

### 4.1 `raw_sentiment_platform.csv`

**File:** `data-raw/raw_sentiment_platform.csv` | **Sumber:** `docs/references/sentiment.json` (B1)  
**Deskripsi:** Sentimen publik per platform/media.

| Kolom | Arti |
|-------|------|
| `ID` | Kode unik sentimen |
| `Platform` | Platform/sumber data |
| `Positif_Persen` | % sentimen positif |
| `Netral_Persen` | % sentimen netral |
| `Negatif_Persen` | % sentimen negatif |
| `Periode` | Rentang waktu pengambilan data |
| `Sumber` | Lembaga/sumber riset |

**Data penting:**
- TikTok: 59% negatif (BeData, 28 Mar-5 Apr 2026)
- Survei CELIOS: perangkat desa 76% tidak setuju skema pinjaman

### 4.2 `raw_sentiment_keywords.csv`

**File:** `data-raw/raw_sentiment_keywords.csv` | **Sumber:** B1  
**Deskripsi:** Analisis kata kunci — kata apa yang sering muncul dan bobotnya.

| Kolom | Arti |
|-------|------|
| `Sentiment` | Positif / negatif |
| `Keyword` | Kata kunci |
| `Bobot` | Tingkat pengaruh (high/medium/low) |
| `Isu_Terkait` | Referensi ke isu di `raw_issues.csv` |

### 4.3 `raw_sentiment_survei_celios.csv`

**File:** `data-raw/raw_sentiment_survei_celios.csv` | **Sumber:** B1  
**Deskripsi:** Hasil survei CELIOS terhadap perangkat desa.

| Kolom | Arti |
|-------|------|
| `Indikator` | Pernyataan yang disurvei |
| `Persentase` | % responden yang setuju |
| `Sentimen` | Kategorisasi sentimen |
| `Sumber` | Lembaga survei |

**4 temuan kunci:**
1. 76% tidak setuju skema pinjaman Kopdes
2. 65% melihat celah korupsi besar
3. 46% khawatir konflik sosial
4. 35% mencium kepentingan politik di balik program

### 4.4 `raw_sentiment_stances_media.csv`

**File:** `data-raw/raw_sentiment_stances_media.csv` | **Sumber:** B1  
**Deskripsi:** Peta sikap (stance) dari berbagai pihak — media, LSM, akademisi, politisi.

| Kolom | Arti |
|-------|------|
| `Sumber` | Nama pihak/sumber |
| `Stance` | Sikap: Kontra / Kritis / Netral / Defensif / Pro |
| `Intensitas` | Tingkat vokal: tinggi/sedang/rendah |
| `Catatan` | Kutipan/ringkasan pernyataan |

### 4.5 `raw_sentiment_viral_content.csv`

**File:** `data-raw/raw_sentiment_viral_content.csv` | **Sumber:** B1  
**Deskripsi:** Konten viral yang memengaruhi persepsi publik.

| Kolom | Arti |
|-------|------|
| `Tipe_Konten` | Jenis konten (Parodi militer, Kopdes di hutan, dll) |
| `Pemicu` | Apa yang memicu viral |
| `Format` | Format konten (video, foto) |
| `Persebaran` | Tingkat penyebaran |

---

## 5. Data Isu Kritis

### 5.1 `raw_issues.csv`

**File:** `data-raw/raw_issues.csv` | **Sumber:** `docs/references/issues.json` (B2)  
**Deskripsi:** 20 isu kritis yang teridentifikasi — dari korupsi hingga keselamatan.

| Kolom | Arti | Contoh |
|-------|------|--------|
| `ID` | Kode unik isu | `iss-001` |
| `Judul` | Nama isu | "Pemangkasan Dana Desa 58%" |
| `Kategori` | Kelompok isu | anggaran, keuangan, tata_kelola, keselamatan, korupsi, dll |
| `Severitas` | Tingkat keparahan | **critical** (kritis), **high** (tinggi), **medium** (sedang) |
| `Dampak` | Deskripsi dampak | Infrastruktur desa terhenti... |
| `Pihak_Terdampak` | Pihak yang terkena dampak | Kepala Desa, Perangkat Desa... |
| `Sumber_Pendukung` | Referensi sumber (ke C1) | src-bbc-2026, src-pmk-7-2026... |

**Severitas Kategori:**
- **Critical (6 isu):** Pemangkasan dana desa, gagal bayar, korupsi, kematian peserta, krisis kepercayaan, detail kematian
- **High (8 isu):** Top-down, militerisasi, dampak BUMDes, sentralisasi, tanpa studi kelayakan, impor pikap, target dipangkas, kompetisi dengan lokal
- **Medium (6 isu):** Lokasi tidak strategis, denda Rp100jt, biaya pelatihan, santunan, tim investigasi, PMK 15/2026

### 5.2 `raw_data_points.csv`

**File:** `data-raw/raw_data_points.csv` | **Sumber:** `docs/references/data_points.json` (B4)  
**Deskripsi:** Kumpulan data penting lintas kategori — siap pakai untuk argumen dan narasi.

| Kolom | Arti |
|-------|------|
| `Kategori` | Kelompok data (Anggaran, Kelembagaan, Pembangunan, dll) |
| `Metrik_Utama` | Nama data |
| `Nilai` | Nilai/angka |
| `Sumber` | Referensi sumber |

**Fungsi:** File ini adalah *one-stop reference* untuk semua angka penting. Jika kamu butuh satu angka untuk argumen, cari di sini dulu.

---

## 6. Data Stakeholders

### 6.1 `raw_stakeholders.csv`

**File:** `data-raw/raw_stakeholders.csv` | **Sumber:** `docs/references/stakeholders.json` (B3)  
**Deskripsi:** Pemetaan 15 pemangku kepentingan — siapa, sikapnya apa, seberapa besar pengaruh dan kepentingannya.

| Kolom | Arti |
|-------|------|
| `ID` | Kode unik | `stake-01` |
| `Nama_Pemangku` | Nama pihak | "Masyarakat Desa" |
| `Sektor` | Kelompok | Masyarakat, Pemerintah Desa, Swasta, Perbankan, dll |
| `Stance_Terhadap_Kopdes` | Sikap | Kontra/menolak, Pro/mendukung, Kritis, Netral |
| `Pengaruh` | Tingkat pengaruh | Rendah/Sedang/Tinggi |
| `Kepentingan` | Tingkat kepentingan | Rendah/Sedang/Tinggi/Sangat Tinggi |
| `Narasi_Utama` | Ringkasan posisi mereka | "Tidak setuju skema pinjaman 76%" |
| `Sumber` | Referensi | CELIOS Survey, IDN Times, dll |

**Peta Pengaruh vs Kepentingan:**

```
Pengaruh TINGGI:
  ├─ Kepentingan TINGGI   → Pemerintah Pusat (Pro), PT Agrinas (Pro), Bank Himbara (Netral)
  └─ Kepentingan SEDANG   → Kemhan (Pro), DPR (Kritis)

Pengaruh SEDANG:
  ├─ Kepentingan TINGGI   → Perangkat Desa (Kontra), YLBHI/ICW (Kontra), Komnas HAM (Kritis), Dekopin (Kritis)
  └─ Kepentingan SEDANG   → Akademisi (Kritis)

Pengaruh RENDAH:
  ├─ Kepentingan TINGGI   → Masyarakat Desa (Kontra), BUMDes/UMKM (Kontra), Industri Otomotif (Kontra), Peserta SPPI (Terpaksa)
  └─ Kepentingan SEDANG   → Media (Netral)
```

---

## 7. Data Timeline

### 7.1 `raw_timeline.csv`

**File:** `data-raw/raw_timeline.csv` | **Sumber:** `docs/references/timeline.json` (B5)  
**Deskripsi:** 24 peristiwa dari Januari 2025 hingga Juli 2026, diurutkan kronologis.

| Kolom | Arti |
|-------|------|
| `Tanggal` | ISO format (YYYY-MM-DD, xx jika tanggal pasti tidak diketahui) |
| `Peristiwa` | Deskripsi peristiwa |
| `Aktor` | Pihak yang terlibat |
| `Signifikansi` | Mengapa peristiwa ini penting |
| `Sumber` | Referensi |

**Fase-Fase Timeline:**

| Fase | Rentang | Peristiwa Kunci |
|------|---------|-----------------|
| **Inisiasi** | Jan-Mar 2025 | Program diluncurkan, PMK 49/2025 terbit |
| **Ekspansi** | Apr-Jun 2025 | Target 80.000, simpanan mulai ditagih, SPPI dimulai |
| **Kritik Awal** | Okt-Des 2025 | Survei CELIOS 76% tolak, Dekopin kritik, YLBHI soal Latsarmil |
| **Kontroversi** | Feb-Mar 2026 | Impor pikap India, target turun 50% → 40.000 |
| **Krisis** | Mei-Jun 2026 | Denda Rp100jt, Kades Pati viral, 5 kematian SPPI |
| **Puncak** | Jul 2026 | Komnas HAM desak, BBC liput, DPR revisi |

---

## 8. Data Trust Analysis

### 8.1 `raw_trust_analysis.csv`

**File:** `data-raw/raw_trust_analysis.csv` | **Sumber:** `docs/references/trust_analysis.json` (B6)  
**Deskripsi:** Skor tingkat kepercayaan (trust score) berdasarkan 7 parameter + rata-rata.

| Kolom | Arti |
|-------|------|
| `Parameter` | Dimensi yang dinilai |
| `Skor` | Skor (X/10) |
| `Kategori` | Risiko Tinggi/Sedang/Rendah |
| `Catatan` | Alasan/alasan di balik skor |

**Skor per Parameter:**

| Parameter | Skor | Kategori |
|-----------|------|----------|
| Tata Kelola | 2/10 | Risiko Tinggi |
| Transparansi | 3/10 | Risiko Sedang |
| Akuntabilitas | 2/10 | Risiko Tinggi |
| Kelayakan Bisnis | 3/10 | Risiko Tinggi |
| Dampak Sosial | 2/10 | Risiko Tinggi |
| Kepercayaan Publik | 2/10 | Risiko Tinggi |
| Keberlanjutan | 3/10 | Risiko Tinggi |
| **Skor Keseluruhan** | **2,4/10** | **Sangat Rendah** |

### 8.2 `raw_analysis_insights.csv`

**File:** `data-raw/raw_analysis_insights.csv` | **Sumber:** `docs/references/analysis_insights.json` (B7)  
**Deskripsi:** Insight per dimensi — temuan utama, implikasi, dan rekomendasi.

| Kolom | Arti |
|-------|------|
| `Dimensi` | Bidang analisis |
| `Temuan_Utama` | Fakta kunci |
| `Implikasi` | Dampak jika tidak ditangani |
| `Rekomendasi` | Saran tindakan |

---

## 9. Relasi Antar Data

### 9.1 Diagram Relasi

```
                       ┌──────────────────────────────┐
                       │  raw_simkopdes_province.csv   │ ← Master provinsi (38 baris)
                       │  (Jumlah_Koperasi, NIB, NPWP, │
                       │   Simpanan, Transaksi, Lahan, │
                       │   Pembangunan)                │
                       └──────────┬───────────────────┘
                                  │
                ┌─────────────────┼──────────────────────┐
                ▼                 ▼                      ▼
   ┌────────────────────┐  ┌──────────────┐  ┌─────────────────────┐
   │ kelembagaan.csv    │  │ transaksi_   │  │ ews_top5_*.csv      │
   │ (Kolom Jumlah      │  │ per_provinsi │  │ (Filter 5 tertinggi │
   │  = Total provinsi) │  │ .csv         │  │  per metrik)        │
   └────────────────────┘  └──────────────┘  └─────────────────────┘

   ┌──────────────────────┐
   │ raw_simkopdes_       │
   │ national.csv         │ ← Agregasi dari 38 provinsi
   │ (Total_Koperasi =    │
   │  sum of Jumlah_      │
   │  Koperasi province)  │
   └──────────────────────┘

   ┌──────────────────────┐     ┌──────────────────────┐
   │ raw_issues.csv       │◄───►│ raw_stakeholders.csv │
   │ (ID: iss-001, dll)   │     │ (terkait via         │
   │ 20 isu kritis        │     │  Pihak_Terdampak)     │
   └──────────────────────┘     └──────────────────────┘
          │                              │
          ▼                              ▼
   ┌──────────────────────┐     ┌──────────────────────┐
   │ raw_data_points.csv  │     │ raw_sentiment_*.csv  │
   │ (referensi angka     │     │ (sentimen publik     │
   │  untuk argumen)      │     │  yang memicu isu)    │
   └──────────────────────┘     └──────────────────────┘

   ┌──────────────────────┐     ┌──────────────────────┐
   │ raw_timeline.csv     │     │ raw_sentiment_       │
   │ (kronologi yang      │     │ stances_media.csv    │
   │  menjelaskan isu)    │     │ (siapa bilang apa    │
   └──────────────────────┘     │  kapan)              │
                                └──────────────────────┘
```

### 9.2 Relasi Data SIMKOPDES

**Chain 1: Nasional ← Provinsi**
```
raw_simkopdes_national.csv (Total_Koperasi = 83.382)
  ← sum of raw_simkopdes_province.csv (Jumlah_Koperasi)
  ← sum of raw_simkopdes_kelembagaan.csv (Total)
```
Verifikasi: Jawa Tengah 8.524 + Jawa Timur 8.494 + ... + DKI Jakarta 268 = **83.382** ✓

**Chain 2: Province → Transaksi**
```
raw_simkopdes_province.csv (Nilai_Transaksi_2026 per provinsi)
  → raw_simkopdes_transaksi_per_provinsi.csv (top 10 by nilai)
```
Verifikasi: Nilai tertinggi di province = Jawa Timur Rp21,48T = ranking 1 di transaksi_per_provinsi ✓

**Chain 3: Province → EWS Top 5**
```
raw_simkopdes_province.csv → raw_simkopdes_ews_top5_pendapatan.csv
  (filter 5 provinsi dengan Pendapatan tertinggi)
```
**Chain 4: Province → Kelembagaan**
```
raw_simkopdes_province.csv (Jumlah_Koperasi)
  = raw_simkopdes_kelembagaan.csv (Total)
```
Verifikasi: Jawa Tengah 8.524 = 8.524 ✓ (semua 38 provinsi match)

**Chain 5: Kelembagaan → Total Nasional**
```
sum of raw_simkopdes_kelembagaan.csv (Total) = 83.382 = raw_simkopdes_national.csv (Total_Koperasi)
  ✓
```

### 9.3 Relasi Data Sentimen & Isu

**Chain A: Isu → Pihak Terdampak → Stakeholders**
```
raw_issues.csv (Pihak_Terdampak)
  → raw_stakeholders.csv (Nama_Pemangku)
```
Contoh: Iss-001 "Pemangkasan Dana Desa" berdampak pada Kepala Desa, yang di stakeholders tercatat sebagai stake-02 dengan stance "Kontra/menolak".

**Chain B: Isu → Sentimen Publik**
```
raw_issues.csv (Kategori)
  → raw_sentiment_keywords.csv (Isu_Terkait)
  → raw_sentiment_platform.csv (sentimen per platform)
```
Contoh: Isu korupsi (iss-007) terkait dengan keyword "korupsi" (bobot high) yang 65% publik melihat celah korupsi.

**Chain C: Timeline → Isu → Data Points**
```
raw_timeline.csv (Peristiwa)
  → raw_issues.csv (Judul isu terkait)
  → raw_data_points.csv (angka pendukung)
```
Contoh: Peristiwa "Kematian peserta SPPI" (23 Jun 2026) → iss-016 (Kematian Detail 5 Peserta) → data_points "Korban Jiwa SPPI: 5 orang".

**Chain D: Trust Analysis ← Semua Data Lain**
```
raw_trust_analysis.csv (skor per parameter)
  ← raw_simkopdes_ews_kesehatan.csv    (utk parameter Keberlanjutan)
  ← raw_sentiment_platform.csv         (utk parameter Kepercayaan_Publik)
  ← raw_issues.csv                     (utk parameter Tata_Kelola, Akuntabilitas)
  ← raw_stakeholders.csv              (utk parameter Dampak_Sosial)
```

### 9.4 Chart CSV → Data Mentah

| Chart CSV | Sumber Data Mentah | Cara Hitung |
|-----------|-------------------|-------------|
| `01a_kesehatan_koperasi_dari_yang_lapor.csv` | `raw_simkopdes_ews_kesehatan.csv` | Copy langsung |
| `01b_status_lapor_keuangan.csv` | `raw_simkopdes_ews_laporan.csv` | Copy langsung |
| `02_timeline_peristiwa.csv` | `raw_timeline.csv` | Pilih kolom Tanggal, Peristiwa, Signifikansi |
| `03_top10_provinsi_koperasi.csv` | `raw_simkopdes_kelembagaan.csv` | Sort by Total DESC, ambil 10 |
| `04_sebaran_pembangunan_gerai.csv` | `raw_simkopdes_province.csv` | Ambil Provinsi + Persen_Pembangunan_Gerai |
| `05_transaksi_produk_top10.csv` | `raw_simkopdes_produk_top10.csv` | Copy langsung |
| `06_perbandingan_keuangan_nasional.csv` | `raw_simkopdes_national.csv` | Ambil Pendapatan & Beban |
| `07_status_anggota_koperasi.csv` | `raw_simkopdes_national.csv` | Ambil baris RAT, NPWP, NIB |
| `08_konsentrasi_jawa.csv` | `raw_simkopdes_kelembagaan.csv` | Filter Jawa Timur, Tengah, Barat. Hitung % dari total |
| `09_simpanan_pokok_wajib.csv` | `raw_simkopdes_province.csv` | Ambil Provinsi, Simpanan_Pokok, Simpanan_Wajib |
| `10_konversi_transaksi_volume_nilai.csv` | `raw_simkopdes_produk_top10.csv` | Dual-axis: Volume & Nilai per produk |
| `11_distribusi_target_realisasi.csv` | `raw_simkopdes_ews_ringkasan_keuangan.csv` | Ambil Aset, Liabilitas, Ekuitas |
| `12_rasio_keuangan_utama.csv` | `raw_simkopdes_ews_ringkasan_keuangan.csv` | Ambil Rasio_Pendapatan_Beban, Rasio_Aset_Liabilitas |
| `13-15_provinsi_aset_liabilitas_ekuitas.csv` | `raw_simkopdes_ews_top5_*.csv` | Copy langsung |
| `16_perbandingan_target_realisasi_produk.csv` | `raw_simkopdes_produk_top10.csv` | Volume vs target per produk |
| `17_sebaran_sentimen_per_provinsi.csv` | `raw_sentiment_platform.csv` | Parse per platform |
| `18_analisis_isu_kritis.csv` | `raw_issues.csv` | Ambil ID, Judul, Kategori, Severitas |
| `19_matriks_pemangku_kepentingan.csv` | `raw_stakeholders.csv` | Ambil Nama, Stance, Pengaruh, Kepentingan |

### 9.5 Panduan Cepat: "Saya butuh data X, di mana?"

| Jika butuh... | Cari di... | File |
|---------------|------------|------|
| Angka nasional (total koperasi, pendapatan, dll) | Data Mentah | `data-raw/raw_simkopdes_national.csv` |
| Data per provinsi | Data Mentah | `data-raw/raw_simkopdes_province.csv` |
| Daftar produk terlaris | Data Mentah | `data-raw/raw_simkopdes_produk_top10.csv` |
| Kesehatan koperasi (sehat/cukup/tidak) | Data Mentah | `data-raw/raw_simkopdes_ews_kesehatan.csv` |
| Semua angka penting dalam satu tempat | Data Mentah | `data-raw/raw_data_points.csv` |
| Daftar isu kritis dan severity-nya | Data Mentah | `data-raw/raw_issues.csv` |
| Siapa saja yang pro/kontra | Data Mentah | `data-raw/raw_stakeholders.csv` |
| Skor kepercayaan | Data Mentah | `data-raw/raw_trust_analysis.csv` |
| Timeline peristiwa | Data Mentah | `data-raw/raw_timeline.csv` |
| Data siap bikin pie chart kesehatan | Chart CSV | `data-charts/01a_kesehatan_koperasi_dari_yang_lapor.csv` |
| Data siap bikin bar chart top provinsi | Chart CSV | `data-charts/03_top10_provinsi_koperasi.csv` |
| Data siap bikin stacked bar konsentrasi Jawa | Chart CSV | `data-charts/08_konsentrasi_jawa.csv` |
| Data siap bikin stakeholder map | Chart CSV | `data-charts/19_matriks_pemangku_kepentingan.csv` |
| Konten TikTok tentang Kopdes | Research | `research/tiktok_findings.csv` |
| Video YouTube tentang Kopdes | Research | `research/youtube_findings.csv` |
| Analisis sentimen lengkap | Research | `research/sentimen_analysis.md` |
| Cara data mengalir dari JSON ke chart | Pipeline | `AGREGASI.md` |

---

## 10. Glosarium

### 10.1 Singkatan

| Istilah | Kepanjangan | Penjelasan |
|---------|-------------|------------|
| **KDMP** | Koperasi Desa/Kelurahan Merah Putih | Nama resmi program kopdes |
| **KKMP** | Koperasi Kampung Nelayan Merah Putih | Varian untuk daerah nelayan |
| **EWS** | Early Warning System | Sistem penilaian kesehatan koperasi dari SIMKOPDES |
| **SPPI** | Satuan Pendidikan Pengelola Induk | Program pelatihan manajer Kopdes (diselenggarakan Kemhan) |
| **Latsarmil** | Latihan Dasar Militer | Pelatihan militer untuk peserta SPPI |
| **RAT** | Rapat Anggota Tahunan | Rapat wajib koperasi setiap tahun |
| **NIB** | Nomor Induk Berusaha | Izin usaha dari OSS |
| **BUMDes** | Badan Usaha Milik Desa | Entitas ekonomi desa yang sudah ada sebelum Kopdes |
| **Himbara** | Himpunan Bank Milik Negara | BNI, BRI, Mandiri, BTN |
| **Agrinas** | PT Agrinas Pangan Nusantara | BUMN swasta pengelola Kopdes (ditunjuk langsung) |

### 10.2 Kategori Severitas Isu

| Level | Arti | Tindakan |
|-------|------|----------|
| **Critical** | Mengancam jiwa, stabilitas, atau kerugian negara masif | Darurat, butuh intervensi segera |
| **High** | Dampak sistemik luas, reputasi negara terancam | Prioritas tinggi, butuh mitigasi cepat |
| **Medium** | Dampak terbatas atau bisa dikelola | Perlu perbaikan, tidak darurat |

### 10.3 Skor Kepercayaan

| Rentang Skor | Kategori | Arti |
|--------------|----------|------|
| 8.0–10.0 | Sangat Tinggi | Program berjalan baik, publik percaya |
| 6.0–7.9 | Tinggi | Mayoritas aspek baik, sedikit perbaikan |
| 4.0–5.9 | Sedang | Beberapa masalah signifikan |
| 2.0–3.9 | Rendah | Banyak masalah serius |
| 0.0–1.9 | Sangat Rendah | Program gagal memenuhi ekspektasi |

### 10.4 Definisi Status Koperasi (EWS)

| Status | Definisi |
|--------|----------|
| **Sehat** | Koperasi memenuhi seluruh indikator EWS: rasio keuangan sehat, patuh lapor, RAT rutin, NIB & NPWP ada |
| **Cukup Sehat** | Sebagian besar indikator terpenuhi, ada beberapa pelanggaran minor |
| **Tidak Sehat** | Gagal memenuhi indikator utama EWS — berpotensi bermasalah serius |
| **Belum Lapor** | Tidak mengirim laporan keuangan → tidak bisa dinilai EWS |

### 10.5 Sumber Data Eksternal

| Kode Sumber | Referensi |
|-------------|-----------|
| `src-bbc-2026` | BBC Indonesia — liputan Kopdes & Dana Desa |
| `src-celios-full` | CELIOS — riset lengkap Kopdes |
| `src-pmk-7-2026` | PMK 7/2026 — aturan penggunaan Dana Desa untuk Kopdes |
| `src-pmk-15-2026` | PMK 15/2026 — revisi pembiayaan Kopdes |
| `src-idn-times-ylbhi` | IDN Times — pernyataan YLBHI |
| `src-bedata-sentimen` | BeData Technology — analisis sentimen |
| `src-kemhan-latsarmil` | Kemenhan — data pelatihan SPPI |
| `src-komisi1-dpr-biaya` | Komisi I DPR — TB Hasanuddin soal biaya Rp45jt/orang |
| `src-detil-impor-pikap` | Detik — impor pikap India 105.000 unit |
| `src-cnn-pencabutan-denda` | CNN Indonesia — denda Rp100jt dicabut |
| `src-koalisi-sipil` | Koalisi Masyarakat Sipil — desakan evaluasi |
| `src-apdesi-ntb` | Apdesi NTB — penolakan potongan dana desa |
| `src-bisnis-target-dipangkas` | Bisnis.com — target turun 80.000→40.000 |
| `src-ugm-diskusi-publik` | UGM — diskusi publik tata kelola Kopdes |

---

> **Referensi:** Lihat `AGREGASI.md` untuk alur pipeline data lengkap dari JSON → CSV mentah → chart CSV.
