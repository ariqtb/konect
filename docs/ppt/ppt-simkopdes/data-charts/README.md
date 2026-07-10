# Data Charts — SIMKOPDES PPT

> **Folder:** `docs/ppt/ppt-simkopdes/data-charts/`
> **Tanggal:** 2026-07-10
> **Sumber data:** Dashboard SIMKOPDES (9 Juli 2026) + Riset CELIOS + Analisis BeData
> **Tujuan:** File CSV siap-import ke **Canva Chart** untuk memperkaya visualisasi presentasi

---

## Cara Pakai

1. Buka Canva → buat desain presentasi
2. Tambahkan element **Chart** (bar, line, pie, dll)
3. Klik **Import data** / **Upload CSV**
4. Pilih file CSV dari folder ini
5. Pilih kolom untuk Category (sumbu-X / segment) dan Value (sumbu-Y / nilai)

Tiap file CSV sudah pre-processed: angka sudah dibersihkan dari format IDR/sumber, kategori sudah dilabel dengan jelas, dan source sudah dicantumkan di catatan.

---

## Daftar File & Rekomendasi Chart

| # | File CSV | Slide | Rekomendasi Chart | Highlight |
|---|---|---|---|---|
| 01 | `01_kondisi_koperasi.csv` | Masalah | Donut / Pie | 91.1% Tidak Sehat, 62.5% Belum Lapor |
| 02 | `02_gap_realisasi.csv` | Masalah | Bar (grouped) | Target vs Realisasi: 6 indikator |
| 03 | `03_top10_provinsi_koperasi.csv` | Pilar 3 | Horizontal Bar | Disparitas Jawa (Jateng 8.524) |
| 04 | `04_transaksi_top10_produk.csv` | Transparansi | Bar / Pie | Pupuk = 46% dari total transaksi |
| 05 | `05_survei_perangkat_desa.csv` | Pilar 3 | Bar | 76% perangkat desa tolak skema |
| 06 | `06_sentimen_tiktok_twitter.csv` | Pilar 4 | Stacked Bar | TikTok 59% negatif, Twitter 55% netral |
| 07 | `07_progres_pembangunan.csv` | Masalah | Donut / Stacked Bar | 43.3% selesai, 56.7% belum |
| 08 | `08_konsentrasi_jawa.csv` | Masalah | Pie | 27.6% koperasi di 3 provinsi Jawa |
| 09 | `09_simpanan_pokok_wajib.csv` | Pilar 3 | Bar (paired) | Rasio 4:1 simpanan pokok:wajib |
| 10 | `10_target_pemangkasan.csv` | Masalah | Line Chart | Target 80k → 40k (Jun 2026) |
| 11 | `11_keuangan_top_provinsi.csv` | Pilar 3 | Bar (grouped by metric) | Banten top pendapatan, Jatim top aset |
| 12 | `12_konsentrasi_transaksi_jatim.csv` | Transparansi | Pie | 38% transaksi di Jawa Timur |
| 13 | `13_tragedi_latsarmil.csv` | Masalah | Bar / Number highlight | 5 meninggal, 30 hari militer |
| 14 | `14_efisiensi_biaya_pendapatan.csv` | Masalah | Bar | Rp3M input vs Rp2,7jt output |
| 15 | `15_lima_pilar_konect.csv` | Fitur | Comparison Table | 5 fitur KONECT |
| 16 | `16_perbandingan_pendekatan_china.csv` | Pilar 3 | Comparison Bar | Indonesia disinsentif vs China insentif |
| 17 | `17_status_operasional_koperasi.csv` | Masalah | Bar | Status operasional koperasi |

---

## Sumber Data & Akuntabilitas

- **Dashboard SIMKOPDES** (https://simkopdes.go.id) — data per 9 Juli 2026
  - `simkopdes_national.json` (ringkasan agregat)
  - `simkopdes_province.json` (38 provinsi)
  - `simkopdes_ews_keuangan.json` (kategori kesehatan 2025)
  - `simkopdes_transaksi.json` (top 10 produk)
  - `simkopdes_kelembagaan.json` (kelembagaan per provinsi)
- **Riset CELIOS** (Desember 2025) — survei 108 perangkat desa, 34 provinsi
- **Analisis BeData** (April 2026) — sentimen TikTok & X/Twitter, 10.068 komentar
- **Media** (Bisnis, ANTARA, Media Indonesia, BBC, Kompas, Kontan, dll)

Semua angka pada CSV **langsung bersumber dari file referensi** di `docs/references/*.json`. Tidak ada angka yang di-fabricate.

---

## Catatan Penting untuk Canva

- **Format angka**: Semua nilai sudah integer (tanpa format IDR Rp atau separator). Canva akan format otomatis.
- **Persen**: Sudah dalam bentuk 0-100 (mis. 91.1 bukan 0.911). Untuk chart percent, Canva handle dari header.
- **Sort order**: Setiap file sudah disortir descending by Value (kecuali file 06 dan 11 yang di-group by category).
- **Date period**: Semua data point berlaku per 9 Juli 2026 kecuali yang secara eksplisit disebut tanggalnya.

---

## Keterbatasan Data

1. **Sentimen Twitter**: Hanya tersedia data netral (55%). Data positif/negatif tidak tersedia di source — tidak di-fabricate.
2. **Estimasi biaya proyek**: Rp240T adalah estimasi CELIOS, bukan angka pemerintah. Cantumkan "estimasi CELIOS" saat presentasi.
3. **Target pemangkasan 40k**: Ini klaim akhir Juni 2026, target resmi operasional Oktober 2026. Belum tercapai.
4. **Data 5 provinsi sehat**: Angka 55% kesehatan adalah data EWS 2025, mungkin tidak match dengan 2.2% nasional (akibat perbedaan sample size).

---

## Lisensi & Disclaimer

Data digunakan untuk presentasi **Hackathon Digital Cooperatives Expo 2026** oleh Group 3B.
Sumber publik dan terbuka. Setiap angka wajib disertai source pada slide presentasi.
