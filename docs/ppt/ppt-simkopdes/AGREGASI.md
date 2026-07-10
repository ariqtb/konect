# Panduan Agregasi Data — Koperasi Desa Merah Putih

> **Versi:** 1.0  
> **Tanggal:** Juli 2026  
> **Tujuan:** Menyediakan panduan lengkap bagi juri dan analis untuk memahami alur data dari sumber mentah hingga visualisasi presentasi.

---

## 1. Sumber Referensi

Semua data bersumber dari hasil riset tim yang dikompilasi dalam `docs/references/`.

| Kode | Nama File | Tipe Data | Cakupan |
|------|-----------|-----------|---------|
| A1 | `simkopdes_national.json` | Data agregat nasional | Dashboard SIMKOPDES 9 Juli 2026 |
| A2 | `simkopdes_province.json` | Data per provinsi | Dashboard SIMKOPDES 9 Juli 2026 |
| A3 | `simkopdes_transaksi.json` | Data transaksi/produk | Dashboard SIMKOPDES 9 Juli 2026 |
| A4 | `simkopdes_kelembagaan.json` | Data jumlah koperasi per provinsi | Dashboard SIMKOPDES |
| A5 | `simkopdes_ews_keuangan.json` | EWS Keuangan Koperasi | Dashboard SIMKOPDES |
| B1 | `sentiment.json` | Analisis sentimen publik | BeData Technology, CELIOS, Multi-source |
| B2 | `issues.json` | Isu-isu kritis | Multi-source (media, akademisi, lembaga) |
| B3 | `stakeholders.json` | Pemetaan pemangku kepentingan | Multi-source |
| B4 | `data_points.json` | Data-data penting | Multi-source |
| B5 | `timeline.json` | Kronologi peristiwa | Multi-source |
| B6 | `trust_analysis.json` | Analisis tingkat kepercayaan | Tim Riset |
| B7 | `analysis_insights.json` | Insight dan rekomendasi | Tim Riset |
| C1 | `sources_list.json` | Daftar referensi artikel/sumber | Web Research |

---

## 2. Data Chart (Canva-Ready)

Lokasi: `data-charts/` — File CSV siap pakai untuk visualisasi Canva.

### 2.1 Makro & Kesehatan (+ Dampak)

| File | Tipe Visual | Sumber Data |
|------|-------------|-------------|
| `01a_kesehatan_koperasi_dari_yang_lapor.csv` | Pie/Doughnut | A5 (EWS — 2,2% Sehat, 6,7% Cukup, 91,1% Tidak Sehat) |
| `01b_status_lapor_keuangan.csv` | Pie/Doughnut | A1 (37,5% sudah lapor, 62,5% belum) |
| `02_timeline_peristiwa.csv` | Timeline/Gantt | B5 (urutan peristiwa) |
| `03_top10_provinsi_koperasi.csv` | Bar Chart | A2, A4 (Jawa Tengah 8.524 terbanyak) |
| `04_sebaran_pembangunan_gerai.csv` | Bar Chart | A2 (persen pembangunan per provinsi) |
| `05_transaksi_produk_top10.csv` | Bar Chart | A3 (Pupuk NPK Rp15T, Urea Rp11,2T) |
| `06_perbandingan_keuangan_nasional.csv` | Bar/Multi-bar | A1 (Pendapatan Rp85T, Beban Rp29T) |
| `07_status_anggota_koperasi.csv` | Donut/Stacked | A1 (RAT, NPWP, NIB) |
| `08_konsentrasi_jawa.csv` | Stacked Bar | A2, A4 (Jawa Tengah, Timur, Barat dominasi) |
| `09_simpanan_pokok_wajib.csv` | Bar/Column | A2 (Simpanan Pokok & Wajib per provinsi) |
| `10_konversi_transaksi_volume_nilai.csv` | Dual-axis Bar | A3 (volume transaksi vs nilai) |
| `11_distribusi_target_realisasi.csv` | Bar | A5 (total aset, liabilitas, ekuitas) |
| `12_rasio_keuangan_utama.csv` | KPI Cards | A1 (Rasio P/B 2,92, Rasio A/L 7,37) |
| `13_provinsi_dengan_aset_terbesar.csv` | Horizontal Bar | A5 (Top 5 provinsi aset) |
| `14_provinsi_dengan_liabilitas_terbesar.csv` | Horizontal Bar | A5 (Top 5 provinsi liabilitas) |
| `15_provinsi_dengan_ekuitas_terbesar.csv` | Horizontal Bar | A5 (Top 5 provinsi ekuitas) |
| `16_perbandingan_target_realisasi_produk.csv` | Bar | A3 (perbandingan kuantitas produk) |
| `17_sebaran_sentimen_per_provinsi.csv` | Stacked Bar | B1 (sentimen berdasarkan wilayah) |

### 2.2 Dampak & Risiko

| File | Tipe Visual | Sumber Data |
|------|-------------|-------------|
| `18_analisis_isu_kritis.csv` | Risk Matrix / Radar | B2 (severitas, dampak, pihak terdampak) |
| `19_matriks_pemangku_kepentingan.csv` | Stakeholder Map | B3 (influence-interest grid) |

---

## 3. Data Mentah (CSV)

Lokasi: `data-raw/` — CSV mentah dari JSON referensi, untuk verifikasi juri.

### 3.1 SIMKOPDES Dashboard

| File | Sumber | Baris Data | Deskripsi |
|------|--------|------------|-----------|
| `raw_simkopdes_national.csv` | A1 | 27 baris | Metrik agregat nasional |
| `raw_simkopdes_province.csv` | A2 | 38 baris | Data per provinsi (lengkap) |
| `raw_simkopdes_produk_top10.csv` | A3 | 10 baris | Top 10 produk berdasarkan nilai transaksi |
| `raw_simkopdes_koperasi_aktif_top10.csv` | A3 | 10 baris | Top 10 koperasi aktif berdasarkan nilai |
| `raw_simkopdes_transaksi_per_provinsi.csv` | A3 | 10 baris | Transaksi per provinsi (top 10) |
| `raw_simkopdes_kelembagaan.csv` | A4 | 38 baris | Jumlah koperasi per provinsi (lengkap) |
| `raw_simkopdes_ews_kesehatan.csv` | A5 | 4 baris | Status kesehatan koperasi nasional |
| `raw_simkopdes_ews_laporan.csv` | A5 | 4 baris | Status laporan keuangan |
| `raw_simkopdes_ews_ringkasan_keuangan.csv` | A5 | 7 baris | Ringkasan keuangan (aset, liabilitas, ekuitas) |
| `raw_simkopdes_ews_top5_pendapatan.csv` | A5 | 5 baris | Top 5 provinsi pendapatan |
| `raw_simkopdes_ews_top5_beban.csv` | A5 | 5 baris | Top 5 provinsi beban |
| `raw_simkopdes_ews_top5_aset.csv` | A5 | 5 baris | Top 5 provinsi aset |
| `raw_simkopdes_ews_top5_liabilitas.csv` | A5 | 5 baris | Top 5 provinsi liabilitas |
| `raw_simkopdes_ews_top5_ekuitas.csv` | A5 | 5 baris | Top 5 provinsi ekuitas |
| `raw_simkopdes_ews_top5_provinsi_sehat.csv` | A5 | 5 baris | Top 5 provinsi dengan koperasi sehat terbanyak |

### 3.2 Sentimen & Analisis

| File | Sumber | Baris Data | Deskripsi |
|------|--------|------------|-----------|
| `raw_sentiment_platform.csv` | B1 | 7 baris | Sentimen per platform (TikTok, X, survei) |
| `raw_sentiment_keywords.csv` | B1 | 9 baris | Analisis kata kunci sentimen |
| `raw_sentiment_survei_celios.csv` | B1 | 4 baris | Hasil survei CELIOS |
| `raw_sentiment_stances_media.csv` | B1 | 22 baris | Stance/posisi berbagai pihak |
| `raw_sentiment_viral_content.csv` | B1 | 3 baris | Konten viral di media sosial |
| `raw_stakeholders.csv` | B3 | 15 baris | Pemetaan pemangku kepentingan lengkap |
| `raw_data_points.csv` | B4 | 33 baris | Data-data penting untuk argumen |
| `raw_timeline.csv` | B5 | 24 baris | Kronologi peristiwa |
| `raw_trust_analysis.csv` | B6 | 8 baris | Skor tingkat kepercayaan per parameter |
| `raw_analysis_insights.csv` | B7 | 7 baris | Insight per dimensi |
| `raw_issues.csv` | B2 | 20 baris | Isu kritis lengkap dengan detail |

---

## 4. Diagram Alur Data

```
REFERENSI (JSON)          DATA MENTAH (CSV)           DATA CHART (CSV)         VISUALISASI
─────────────────    ──────────────────────    ──────────────────────    ─────────────────
simkopdes_national  → raw_simkopdes_national  → 01a, 01b, 06, 07,     → Canva / Slides
                      raw_simkopdes_province     11, 12                    (Pie, Bar, KPI)

simkopdes_province  → raw_simkopdes_province  → 03, 04, 08, 09        → Canva / Slides
                                                                    (Bar, Stacked Bar)

simkopdes_transaksi → raw_simkopdes_produk    → 05, 10, 16            → Canva / Slides
                      raw_simkopdes_transaksi                            (Bar, Dual-axis)

simkopdes_kelembagaan→ raw_simkopdes_kelembagaan→03, 08               → Canva / Slides

simkopdes_ews       → raw_simkopdes_ews_*     → 01a, 01b, 13-17      → Canva / Slides

sentiment/issues    → raw_sentiment_*         → 17, 18               → Canva / Slides
                      raw_issues                                       (Radar, Risk Matrix)

stakeholders        → raw_stakeholders        → 19                   → Canva / Slides
                                                                    (Stakeholder Map)

data_points         → raw_data_points         → (referensi narasi)    → Narasi presentasi
timeline            → raw_timeline            → 02                    → Timeline visual
trust_analysis      → raw_trust_analysis      → (skor kepercayaan)   → KPI / Gauge chart
analysis_insights   → raw_analysis_insights   → (rekomendasi)        → Callout / Quote
```

---

## 5. Relasi Data

### 5.1 Data Utama → Data Turunan

Setiap file `raw_` dibuat langsung dari JSON referensi dengan transformasi minimal:
- Delimiter: `;`
- Header: Bahasa Inggris (konsisten dengan terminologi dashboard)
- Format angka: tanpa separator ribuan (agar bisa dibaca spreadsheet/Canva)
- Tanggal: ISO format (YYYY-MM-DD)

### 5.2 Chart → Data Mentah

Setiap file di `data-charts/` dapat diverifikasi dengan satu atau lebih file di `data-raw/`:
- Chart `01a` → `raw_simkopdes_ews_kesehatan.csv` (baris 1-3)
- Chart `01b` → `raw_simkopdes_ews_laporan.csv` (baris 1-3)
- Chart `03` → `raw_simkopdes_kelembagaan.csv` (kolom Provinsi + Total)
- Chart `05` → `raw_simkopdes_produk_top10.csv` (kolom Produk + Nilai)
- Chart `06` → `raw_simkopdes_national.csv` (baris Pendapatan & Beban)
- Chart `08` → `raw_simkopdes_kelembagaan.csv` (filter Jawa Timur, Tengah, Barat)
- Chart `09` → `raw_simkopdes_province.csv` (kolom Simpanan_Pokok & Simpanan_Wajib)
- Chart `13-15` → `raw_simkopdes_ews_top5_*.csv`

### 5.3 Antar Data Mentah

`raw_simkopdes_province.csv` adalah superset dari data per provinsi dan menjadi sumber verifikasi untuk:
- `raw_simkopdes_kelembagaan.csv` (kolom Jumlah_Koperasi)
- `raw_simkopdes_transaksi_per_provinsi.csv` (kolom Total_Transaksi & Nilai)
- `raw_simkopdes_ews_top5_*.csv` (filter 5 provinsi tertinggi)

---

## 6. Verifikasi Data

### Metode Verifikasi

1. **Cross-check JSON → CSV mentah**: Bandingkan nilai di file `raw_*.csv` dengan nilai di JSON referensi
2. **Cross-check CSV mentah → chart CSV**: Jumlah baris dan nilai agregat harus konsisten
3. **Agregasi konsistensi**: Jumlah per provinsi harus sama dengan total nasional
4. **Rasio**: Rasio yang dihitung (Pendapatan/Beban = 2,92) harus menggunakan nilai yang sama di JSON

### Spot Check

| Data | Nilai | Verifikasi |
|------|-------|------------|
| Total Koperasi Aktif | 83.382 | `raw_simkopdes_national.csv` baris 1 → A1 |
| Koperasi Sehat | 683 (2,2%) | `raw_simkopdes_ews_kesehatan.csv` baris 1 → A5 |
| Top 3 Transaksi | Rp21,48T (Jatim), Rp6,74T (Lampung), Rp5,74T (Jateng) | `raw_simkopdes_transaksi_per_provinsi.csv` baris 1-3 → A3 |
| Sentimen Negatif TikTok | 59% | `raw_sentiment_platform.csv` baris 1 → B1 |
| Skor Kepercayaan | 2,4/10 | `raw_trust_analysis.csv` baris 8 → B6 |

---

## 7. Analisis Workflow

### Workflow A — Analisis Kelembagaan & Kesehatan
```
raw_simkopdes_province (38 provinsi)
→ Filter: 10 provinsi dengan koperasi terbanyak
→ Visual: Bar chart (03_top10_provinsi_koperasi)
→ Insight: Jawa Tengah (8.524), Timur (8.494), Barat (5.970) = 22.988 (27,6% nasional)

raw_simkopdes_ews_kesehatan
→ Pie chart: 2,2% sehat, 6,7% cukup, 91,1% tidak sehat
→ Insight: Hanya 2,2% koperasi yang sehat dari 31.265 yang lapor
```

### Workflow B — Analisis Dampak Publik
```
raw_timeline (24 peristiwa)
→ Filter: Peristiwa kritis (kematian, korupsi, kontroversi)
→ Visual: Timeline chart (02_timeline_peristiwa)
→ Insight: Eskalasi krisis Mei-Juli 2026

raw_sentiment_stances_media (22 pihak)
→ Stakeholder map (19_matriks_pemangku_kepentingan)
→ Insight: Mayoritas pihak kontra atau kritis
```

### Workflow C — Analisis Risiko & Kepercayaan
```
raw_trust_analysis (8 parameter)
→ Radar/gauge chart per parameter
→ Skor rata-rata: 2,4/10 (Sangat Rendah)
→ Parameter terendah: Tata Kelola (2/10), Akuntabilitas (2/10), Dampak Sosial (2/10)
```

---

## 8. Appendix

### A. Perbaikan Data

| File | Perbaikan | Tanggal |
|------|-----------|---------|
| `03_top10_provinsi_koperasi.csv` | Nilai 8.524 → 8.524 (diverifikasi dari A2) | 10 Jul 2026 |
| `08_konsentrasi_jawa.csv` | Persentase dihitung ulang dari A4 | 10 Jul 2026 |
| `09_simpanan_pokok_wajib.csv` | Nilai Simpanan Wajib Jawa Timur dikoreksi ke 1.309.046.670 | 10 Jul 2026 |
| `01a_kesehatan_koperasi_dari_yang_lapor.csv` | Dipisah dari `01_kondisi_koperasi.csv` untuk akurasi pie | 10 Jul 2026 |

### B. Glossary

| Istilah | Definisi |
|---------|----------|
| EWS | Early Warning System — sistem penilaian kesehatan koperasi |
| Latsarmil | Latihan Dasar Militer — program pelatihan untuk pengurus Kopdes |
| SPPI | Satuan Pendidikan Pengelola Induk — program pelatihan manajer Kopdes |
| BUMDes | Badan Usaha Milik Desa |
| Himbara | Himpunan Bank Milik Negara (BNI, BRI, Mandiri, BTN) |
| RAT | Rapat Anggota Tahunan |
| SIMKOPDES | Sistem Informasi Manajemen Koperasi Desa |
| CELIOS | Center of Economic and Law Studies — lembaga riset |
| BeData | Platform analisis data dan sentimen |
| Agrinas | PT Agrinas — pihak swasta pengelola Kopdes |

### C. Format File

| Format | Delimiter | Encoding | Baris Pertama |
|--------|-----------|----------|---------------|
| .csv (chart) | `;` | UTF-8 | Header (English) |
| .csv (raw) | `;` | UTF-8 | Header (English) |
| .json | — | UTF-8 | Objek/array |
| .md | — | UTF-8 | Markdown |
