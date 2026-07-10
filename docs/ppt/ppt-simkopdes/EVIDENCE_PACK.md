# Evidence Pack — Koperasi Desa Merah Putih

> **Paket Bukti Terpadu untuk Juri**  
> **Versi:** 1.0 | **Tanggal:** 10 Juli 2026  
> **Fungsi:** Tabel pivot yang menyilangkan data dari 26+ file mentah → satu referensi cepat.

---

## Daftar Tabel Pivot

1. [Master Isu × Stakeholder × Data](#1-master-isu--stakeholder--data-pivot)
2. [Stakeholder Power-Interest Grid](#2-stakeholder-power-interest-grid)
3. [Financial Ratio Dashboard](#3-financial-ratio-dashboard)
4. [Timeline × Kategori × Severitas](#4-timeline--kategori--severitas)
5. [Sentimen Publik — Semua Sumber](#5-sentimen-publik--semua-sumber)
6. [Kepatuhan & Kesehatan Koperasi](#6-kepatuhan--kesehatan-koperasi)
7. [Trust Score — Seluruh Parameter](#7-trust-score--seluruh-parameter)
8. [Distribusi Pembangunan Gerai](#8-distribusi-pembangunan-gerai)
9. [Relasi Data — Satu Halaman](#9-relasi-data--satu-halaman)
10. [Key Verdict Questions](#10-key-verdict-questions)

---

## 1. Master Isu × Stakeholder × Data Pivot

> **Sumber:** `data-raw/raw_issues.csv` × `raw_stakeholders.csv` × `raw_data_points.csv`

| # | Isu | Kategori | Severitas | Stakeholder Kunci (Stance) | Data Pendukung | Data Point ID |
|---|-----|----------|-----------|---------------------------|----------------|---------------|
| 1 | Pemangkasan Dana Desa 58% | Anggaran | 🔴 Critical | Kades (Kontra), Kemendes (Pro), Apdesi (Kontra) | Potongan 58%, Dana Desa Rp71T | DP-01, DP-02 |
| 2 | Skema Pembiayaan & Gagal Bayar | Keuangan | 🔴 Critical | Bank Himbara (Netral), Masyarakat (Kontra) | Risiko Rp2,8-4,6T/bulan | DP-03 |
| 3 | Pendekatan Top-Down & Komando | Tata Kelola | 🟠 High | YLBHI (Kontra), Dekopin (Kritis), Masyarakat | Melanggar prinsip bottom-up | — |
| 4 | Keterlibatan TNI & Militerisasi Ekonomi | Tata Kelola | 🟠 High | YLBHI (Kontra), GMNI (Kontra), TNI (Pro) | TNI插手 ekonomi sipil | — |
| 5 | Korban Jiwa dalam Pelatihan Militer | Keselamatan | 🔴 Critical | Komnas HAM (Kritis), Keluarga (Korban), Kemhan (Pro) | 5 meninggal, Rp1,35T | DP-21 |
| 6 | Lokasi Bangunan Tidak Strategis | Operasional | 🟢 Medium | Masyarakat Desa (Kontra), Pemda (Netral) | Koperasi di hutan, gunung, tambak | DP-25 |
| 7 | Risiko Korupsi & Kebocoran Anggaran | Korupsi | 🔴 Critical | ICW (Kontra), KPK (Potensi), Kejaksaan | 65% publik lihat celah korupsi | DP-18, DP-19 |
| 8 | Impor Pikap 105.000 Unit India | Pengadaan | 🟠 High | Kemenperin (Kontra), Agrinas (Pro), ICW (Kontra) | 105.000 unit | DP-22 |
| 9 | Denda Rp100 Juta Calon Manajer | Kebijakan | 🟢 Medium | Calon Manajer (Terpaksa), Pemerintah | Denda (sudah dicabut) | DP-23 |
| 10 | Krisis Kepercayaan Publik | Sosial | 🟠 High | Masyarakat (Kontra), Media (Netral) | 76% tolak, 59% sentimen negatif | DP-17, DP-18 |
| 11 | Kompetisi dengan BUMDes & Lokal | Ekonomi | 🟠 High | BUMDes (Terancam), UMKM (Terancam) | BUMDes mati suri | DP-15 |
| 12 | Sentralisasi & Otonomi Desa Tergerus | Tata Kelola | 🟠 High | Kades (Kontra), Pemerintah Pusat (Pro) | Otonomi desa terkikis | — |
| 13 | Tidak Ada Studi Kelayakan | Perencanaan | 🟠 High | KPPOD (Kritis), Akademisi (Kritis) | Risiko tinggi gagal | — |
| 14 | Biaya Pelatihan Tidak Efisien | Keuangan | 🟢 Medium | DPR (Kritis), Kemhan (Pro) | Rp45jt/orang | DP-05 |
| 15 | Target 80.000 → 40.000 | Kebijakan | 🟠 High | Pemerintah Pusat (Pro), Masyarakat | Turun 50% | DP-04 |
| 16 | Detail Kematian 5 Peserta SPPI | Keselamatan | 🔴 Critical | Komnas HAM (Kritis), Keluarga (Korban) | 5 korban, investigasi | DP-21 |
| 17 | Santunan Belum Jelas | Keselamatan | 🟢 Medium | Keluarga (Korban), Koalisi Sipil (Kritis) | Belum ada kepastian | — |
| 18 | Tim Investigasi Kemhan-Kemenkes | Tata Kelola | 🟢 Medium | Kemhan (Pro), Kemenkes (Netral) | Respons institusional | — |
| 19 | PMK 15/2026 Gantikan 49 & 63/2025 | Regulasi | 🟢 Medium | Pemerintah, Bank Himbara | Perubahan kerangka hukum | DP-01 |
| 20 | Proyek tanpa Studi Layak & Sentralistik | Perencanaan | 🟠 High | KPK (Potensi), BPK, Akademisi (Kritis) | Kredibilitas dipertanyakan | — |

**Ringkasan:** 6 Critical + 8 High + 6 Medium = **20 isu total**.  
**Mayoritas isu (70%)** berada pada level critical atau high.  
**3 dari 6 isu critical** terkait **kematian dan keselamatan**.

---

## 2. Stakeholder Power-Interest Grid

> **Sumber:** `data-raw/raw_stakeholders.csv`  
> **Fungsi:** Peta kekuatan politik — siapa yang bisa mendorong/menghambat program.

### 2.1 Matrix Pengaruh × Kepentingan

```
                           KEPENTINGAN
                Rendah            Sedang            Tinggi       Sangat Tinggi
  ┌──────────┬──────────────────────────────────────────────────────────────
  │ TINGGI   │                   │ DPR (Kritis)    │ Pemerintah Pusat (Pro) │
  │          │                   │ Kemhan (Pro)    │ PT Agrinas (Pro)       │
  │          │                   │                 │ Bank Himbara (Netral)  │
  ├──────────┼──────────────────────────────────────────────────────────────
  │ SEDANG   │                   │ Akademisi       │ Perangkat Desa (Kontra)│
  │          │                   │ (Kritis)        │ YLBHI/ICW (Kontra)     │
  │          │                   │                 │ Komnas HAM (Kritis)   │
  │          │                   │                 │ Dekopin (Kritis)       │
  ├──────────┼──────────────────────────────────────────────────────────────
  │ RENDAH   │                   │ Media (Netral)  │ Masyarakat Desa (Kontra)│ Peserta SPPI │
  │          │                   │                 │ BUMDes/UMKM (Terancam) │ (Terpaksa)   │
  │          │                   │                 │ Ind. Otomotif (Kontra) │              │
  └──────────┴──────────────────────────────────────────────────────────────
```

### 2.2 Tabel Stakeholder — Diurutkan oleh Kekuatan Oposisi

| Stakeholder | Sektor | Stance | Power | Interest | Narasi |
|------------|--------|--------|-------|----------|--------|
| **Perangkat Desa** (Kades) | Pemdes | KONTRA 🟥 | Sedang | Tinggi | Potongan 58% hancurkan infrastruktur |
| **YLBHI / ICW / KPPOD** | LSM | KONTRA 🟥 | Sedang | Tinggi | Evaluasi total, hentikan TNI |
| **Komnas HAM** | HAM | KRITIS 🟧 | Sedang | Tinggi | Hentikan pelatihan militer |
| **Dekopin** | Koperasi | KRITIS 🟧 | Sedang | Tinggi | Tata kelola bermasalah |
| **DPR / Komisi I** | Legislatif | KRITIS 🟧 | Tinggi | Sedang | Sorot anggaran & impor |
| **Akademisi** (UGM, UI) | Akademisi | KRITIS 🟧 | Sedang | Sedang | Tata kelola problematik |
| **Bank Himbara** | Perbankan | NETRAL ⬜ | Tinggi | Tinggi | Risiko kredit Rp2,8-4,6T/bln |
| **Media** (Kompas, BBC) | Media | NETRAL ⬜ | Rendah | Sedang | Liputan kontroversi |
| **Pemerintah Pusat** | Pemerintah | PRO 🟩 | Tinggi | Tinggi | Program prioritas nasional |
| **PT Agrinas** | Swasta | PRO 🟩 | Tinggi | Tinggi | Manajer pengelola |
| **Kemhan** | Pemerintah | PRO 🟩 | Tinggi | Sedang | Pelatihan SPPI |

**Insight:** Blok oponen (Kontra + Kritis) terdiri dari **8 pihak** dengan pengaruh sedang-tinggi.  
Blok pendukung hanya **3 pihak**. Ini menunjukkan program menghadapi oposisi luas dan terorganisir.

---

## 3. Financial Ratio Dashboard

> **Sumber:** `data-raw/raw_simkopdes_ews_ringkasan_keuangan.csv`, `raw_simkopdes_national.csv`

| Metrik | Nilai | Satuan | Kategori | Rumus |
|--------|-------|--------|----------|-------|
| **Pendapatan** | Rp85,26T | IDR | P&L | — |
| **Beban** | Rp29,19T | IDR | P&L | — |
| **Rasio P/B** | **2,92×** | ratio | ✅ Sehat | Pendapatan ÷ Beban |
| **Aset** | Rp453,89T | IDR | Neraca | — |
| **Liabilitas** | Rp61,59T | IDR | Neraca | — |
| **Ekuitas** | Rp215,91T | IDR | Neraca | Aset − Liabilitas |
| **Rasio A/L** | **7,37×** | ratio | ✅ Sehat | Aset ÷ Liabilitas |
| **Simpanan Pokok** | Rp41,51T | IDR | Modal | — |
| **Simpanan Wajib** | Rp10,37T | IDR | Modal | — |
| **Rasio Pokok/Wajib** | **4,0×** | ratio | ❓ | Simpanan Pokok ÷ Wajib |
| **Nilai Transaksi 2026** | Rp56,57T | IDR | Transaksi | — |
| **Volume Transaksi 2026** | 53.262 | unit | Transaksi | — |
| **Nilai per Transaksi** | **Rp1,06M** | IDR | Rata-rata | Nilai ÷ Volume |

### 3.1 Perbandingan Skala

| Metrik | Nilai (Rp) | Ekivalensi |
|--------|-----------|------------|
| Dana Desa Total | 71 Triliun | 100% |
| Dipotong untuk Kopdes (58%) | 41 Triliun | — |
| Pendapatan Koperasi | 85,26 Triliun | 1,2× Dana Desa |
| Aset Koperasi | 453,89 Triliun | 6,4× Dana Desa |
| Anggaran Latsarmil | 1,35 Triliun | 1,9% Dana Desa |
| Biaya per Peserta SPPI | 45 Juta/orang | — |
| Modal per Kopdes (rata-rata) | 5,4 Miliar | Aset ÷ Total Koperasi |

### 3.2 Top 5 Provinsi — Transaksi

> **Sumber:** `data-raw/raw_simkopdes_transaksi_per_provinsi.csv`

| Rank | Provinsi | Nilai Transaksi | % Nasional | Jumlah Transaksi |
|------|----------|----------------|-----------|-----------------|
| 1 | **JAWA TIMUR** | Rp21,48T | **38,0%** | 23.276 |
| 2 | LAMPUNG | Rp6,74T | 11,9% | 1.116 |
| 3 | JAWA TENGAH | Rp5,75T | 10,2% | 9.301 |
| 4 | NUSA TENGGARA BARAT | Rp3,98T | 7,0% | 409 |
| 5 | JAWA BARAT | Rp3,53T | 6,2% | 2.778 |
| | **Top 5 Total** | **Rp41,48T** | **73,4%** | 36.880 |
| | Nasional | Rp56,57T | 100% | 53.262 |

**Insight:** Jawa Timur **sendiri** menguasai 38% transaksi. Top 5 provinsi = 73,4% dari total nasional. Konsentrasi sangat tinggi.

### 3.3 Top 5 Produk

> **Sumber:** `data-raw/raw_simkopdes_produk_top10.csv`

| Rank | Produk | Nilai | % Transaksi |
|------|--------|-------|-------------|
| 1 | **Pupuk NPK Phonska** | Rp15,09T | **26,7%** |
| 2 | Pupuk Urea | Rp11,27T | 19,9% |
| 3 | Barang Lainnya | Rp7,90T | 14,0% |
| 4 | Minyak Goreng Bimoli 2L | Rp3,63T | 6,4% |
| 5 | Beras Medium SPHP 5KG | Rp2,42T | 4,3% |
| | **Pupuk Total (1+2)** | **Rp26,37T** | **46,6%** |

**Insight:** Hampir setengah transaksi (46,6%) adalah pupuk bersubsidi. Kopdes berfungsi sebagai **saluran distribusi pupuk**, bukan koperasi serba usaha sesungguhnya.

---

## 4. Timeline × Kategori × Severitas

> **Sumber:** `data-raw/raw_timeline.csv`, `data-raw/raw_issues.csv`

### 4.1 Fase Eskalasi

| Fase | Rentang | Durasi | Peristiwa Kunci | Severitas |
|------|---------|--------|----------------|-----------|
| 🔵 Inisiasi | Jan–Mar 2025 | 3 bln | Peluncuran program, PMK 49/2025 | Normal |
| 🟢 Ekspansi | Apr–Jun 2025 | 3 bln | Target 80.000, SPPI mulai, simpanan ditagih | Normal |
| 🟡 Kritik Awal | Okt–Des 2025 | 3 bln | Survei CELIOS (76% tolak), Dekopin kritik, YLBHI soal Latsarmil | Medium |
| 🟠 Kontroversi | Feb–Mar 2026 | 2 bln | Impor pikap India, target turun 50% | High |
| 🔴 **Krisis** | **Mei–Jul 2026** | **3 bln** | **5 kematian SPPI**, denda Rp100jt, Kades Pati viral | **Critical** |
| 🟣 Respons | Jul 2026 | Skrg | Komnas HAM desak, BBC liput, DPR revisi, overhaul | High |

### 4.2 Peristiwa Kritis (Juni–Juli 2026)

| Tanggal | Peristiwa | Dampak |
|---------|-----------|--------|
| 17 Jun | Kematian pertama peserta SPPI 🔴 | Krisis dimulai |
| 20 Jun | Kematian kedua | Krisis kian dalam |
| 23 Jun | Kematian ketiga & keempat (dalam satu hari) 🔴 | Puncak krisis |
| 28 Jun | Kematian kelima | Total 5 korban |
| 30 Jun | Komnas HAM desak investigasi | Tekanan publik |
| 1 Jul | Tim investigasi Kemhan-Kemenkes dibentuk | Respons institusional |
| 3 Jul | Koalisi Sipil: "5 kematian = konsekuensi kebijakan keliru" 🔴 | Eskalasi tuntutan |
| 4 Jul | BBC Indonesia rilis liputan mendalam | Liputan internasional |
| 5 Jul | Menkop angkat bicara soal lokasi terpencil | Respons |
| 6 Jul | Purbaya: Prabowo to overhaul program | Overhaul diumumkan |
| 7 Jul | Putri Bung Hatta kritik tata kelola | Tokoh berpengaruh |
| 8 Jul | YLBHI desak evaluasi total | Tuntutan formal |
| 9 Jul | DPR grilling Bappenas | Pengawasan legislatif |
| 10 Jul | BBC: omzet harian Bojonegoro Rp100.000 | Krisis keberlanjutan |

**Insight:** Eskalasi dari kritik (Okt 2025) ke krisis kematian (Jun 2026) memakan **8 bulan**.  
Hanya butuh **2 minggu** (17 Jun – 1 Jul) bagi krisis kematian untuk memicu respons institusional dan overhaul.

---

## 5. Sentimen Publik — Semua Sumber

> **Sumber:** `data-raw/raw_sentiment_platform.csv`, `raw_sentiment_survei_celios.csv`, `raw_sentiment_viral_content.csv`, `research/sentimen_analysis.md`

### 5.1 Sentimen Terukur

| Sumber | Positif | Netral | Negatif | Periode |
|--------|---------|--------|---------|---------|
| TikTok (BeData) | 14% | 27% | **59%** | 28 Mar – 5 Apr 2026 |
| Survei Perangkat Desa (CELIOS) | — | — | **76%** tolak skema | Okt–Des 2025 |
| Google News / Portal | — | — | **Mayoritas** negatif | Jul 2026 |
| YouTube | Campuran | — | **60%** kritis | Jul 2026 |

### 5.2 Indikator Survei CELIOS

| Pernyataan | % Setuju | Arti |
|-----------|----------|------|
| Tidak setuju skema pinjaman Kopdes | **76%** | Mayoritas perangkat desa menolak |
| Melihat celah korupsi besar | **65%** | Risiko integritas sangat tinggi |
| Khawatir konflik sosial | **46%** | Hampir setengah khawatir pecah konflik |
| Mencium kepentingan politik | **35%** | Sepertiga lihat agenda di balik program |

### 5.3 Konten Viral Teratas

| Konten | Platform | Views | Sentimen |
|--------|----------|-------|----------|
| Yel-yel Latsarmil calon manajer | TikTok | 9,2M 🏆 | Negatif (parodi militer) |
| Kopdes Blora diserbu warga | TikTok | 3,0M | Positif (harga murah) |
| Parodi pelayanan ala militer | TikTok | 2,3M | Negatif (sindiran) |
| Pegawai rebahan sepi pembeli | TikTok | 1,3M | Negatif (omzet nol) |
| "Berapa Gaji Pengurus Kopdes?" | YouTube | 162,5K | Netral (informasi) |

### 5.4 Peta Stance Media & Lembaga

| Sikap | Pihak | Jumlah |
|-------|-------|--------|
| **Kontra** 🟥 | YLBHI, GMNI, Apdesi, Kades Purworejo, Kades Pati, Koalisi Sipil, Agus Pambagio, PSPK UGM, Komunitas Baduy, ICW, KPPOD | **11** |
| **Kritis** 🟧 | PDIP, Dekopin, FH UGM, TB Hasanuddin (DPR), Menteri Perindustrian, Akademisi UI, Komnas HAM | **7** |
| **Netral** ⬜ | BBC, Kompas, Media umum | **3** |
| **Defensif** 🟨 | Mendagri Tito Karnavian | **1** |
| **Pro** 🟩 | Pemerintah Pusat, Kemhan, PT Agrinas | **3** |

---

## 6. Kepatuhan & Kesehatan Koperasi

> **Sumber:** `data-raw/raw_simkopdes_ews_kesehatan.csv`, `raw_simkopdes_ews_laporan.csv`

### 6.1 Status Laporan Keuangan
```
                    Total Koperasi: 83.382
                  ┌──────────────────────────────────────┐
                  │                                      │
          ┌───────▼──────────┐              ┌────────────▼──────────┐
          │   SUDAH LAPOR    │              │     BELUM LAPOR       │
          │    31.265 unit   │              │     52.117 unit       │
          │     (37,5%)      │              │      (62,5%)          │
          └───────┬──────────┘              └───────────────────────┘
                  │
     ┌────────────┼────────────┐
     ▼            ▼            ▼
  ┌──────┐   ┌────────┐   ┌──────────┐
  │SEHAT │   │ CUKUP  │   │ TIDAK    │
  │ 683  │   │ 2.087  │   │ SEHAT    │
  │2,2%  │   │ 6,7%   │   │ 28.495   │
  └──────┘   └────────┘   │ 91,1%    │
                          └──────────┘
```

### 6.2 Deret Angka Kunci

| Metrik | Angka | Interpretasi |
|--------|-------|-------------|
| Total koperasi | 83.382 | Lebih dari target 40.000 |
| Sudah lapor keuangan | 31.265 (37,5%) | **Mayoritas belum lapor** |
| Sehat (dari yang lapor) | 683 (2,2%) | Hampir tidak ada |
| Cukup sehat | 2.087 (6,7%) | Sangat minoritas |
| Tidak sehat | 28.495 (91,1%) | **Hampir semua tidak sehat** |
| Sudah RAT 2025 | 50.264 (60,3%) | Cukup baik |
| Belum RAT | 18.772 (22,5%) | Perlu perhatian |
| Memiliki NPWP | 80.978 (97,1%) | ✅ Sangat baik |
| Memiliki NIB | 60.773 (72,9%) | Perlu ditingkatkan |

### 6.3 Provinsi dengan Koperasi Sehat Terbanyak

> **Sumber:** `data-raw/raw_simkopdes_ews_top5_provinsi_sehat.csv`

| Rank | Provinsi | Jumlah Sehat |
|------|----------|-------------|
| 1 | Jawa Tengah | ~55 |
| 2 | Jawa Timur | ~55 |
| 3 | Jawa Barat | ~55 |
| 4 | Sumatera Selatan | ~54 |
| 5 | Aceh | ~53 |

**Insight:** Bahkan provinsi "terbaik" hanya memiliki ~55 koperasi sehat — dari ribuan koperasi di provinsi tersebut. Ini menunjukkan kegagalan sistemik.

---

## 7. Trust Score — Seluruh Parameter

> **Sumber:** `data-raw/raw_trust_analysis.csv`

### 7.1 Dashboard Skor

```
 Parameter                   Skor     0  1  2  3  4  5  6  7  8  9  10
 ─────────────────────────────────────────────────────────────────────
 Tata Kelola                 2/10     ████████░░░░░░░░░░░░░░░░░░░░░░
 Transparansi                3/10     ████████████░░░░░░░░░░░░░░░░░░
 Akuntabilitas               2/10     ████████░░░░░░░░░░░░░░░░░░░░░░
 Kelayakan Bisnis            3/10     ████████████░░░░░░░░░░░░░░░░░░
 Dampak Sosial               2/10     ████████░░░░░░░░░░░░░░░░░░░░░░
 Kepercayaan Publik          2/10     ████████░░░░░░░░░░░░░░░░░░░░░░
 Keberlanjutan               3/10     ████████████░░░░░░░░░░░░░░░░░░
 ─────────────────────────────────────────────────────────────────────
 SKOR KESELURUHAN           2,4/10    Sangat Rendah
```

### 7.2 Penalty per Parameter

| Parameter | Skor | Penyebab Utama |
|-----------|------|----------------|
| Tata Kelola | 2 | Top-down, sentralistik, tanpa partisipasi desa, overlap BUMDes |
| Transparansi | 3 | Data SIMKOPDES tersedia, tapi penggunaan dana tidak transparan |
| Akuntabilitas | 2 | Tidak ada mekanisme checks and balances |
| Kelayakan Bisnis | 3 | Tanpa studi kelayakan, fokus jual pupuk, tanpa agunan |
| Dampak Sosial | 2 | 5 kematian, konflik sosial, militerisasi ekonomi |
| Kepercayaan Publik | 2 | 76% tolak skema, 65% lihat celah korupsi, 59% negatif TikTok |
| Keberlanjutan | 3 | Target turun 50%, pembangunan 43,3%, sehat hanya 2,2% |
| **SKOR RATA-RATA** | **2,4/10** | **Sangat Rendah** |

---

## 8. Distribusi Pembangunan Gerai

> **Sumber:** `data-raw/raw_simkopdes_national.csv`, `raw_simkopdes_province.csv`

### 8.1 Pipeline Pembangunan Nasional
```
Lahan Diajukan          38.053  ───────────────────────────── 100%
Lahan Terverifikasi     35.870  ─────────────────────── 94,3%
Gerai 100% Jadi         15.533  ──────────── 43,3%
Sedang Dibangun         —       55,3%
Belum Mulai             —        1,4%
```

### 8.2 Top 5 Provinsi — Pembangunan Tercepat

> **Sumber:** `data-raw/raw_simkopdes_province.csv` (sort by Persen_Pembangunan_Gerai DESC)

| Rank | Provinsi | % Pembangunan |
|------|----------|--------------|
| 1 | Kalimantan Utara | **80,69%** |
| 2 | DKI Jakarta | **87,26%** |
| 3 | Jawa Timur | **81,84%** |
| 4 | DI Yogyakarta | **77,95%** |
| 5 | Jawa Tengah | **77,80%** |

### 8.3 Bottom 5 Provinsi — Pembangunan Terlambat

| Rank | Provinsi | % Pembangunan |
|------|----------|--------------|
| 34 | Papua | 17,75% |
| 35 | Papua Tengah | 17,67% |
| 36 | Papua Selatan | 19,22% |
| 37 | Papua Pegunungan | 20,80% |
| 38 | Kalimantan Barat | 23,53% |

**Insight:** Kesenjangan pembangunan sangat tajam — DKI 87% vs Papua Tengah 18%. Wilayah timur Indonesia tertinggal jauh.

---

## 9. Relasi Data — Satu Halaman

### 9.1 Data SIMKOPDES
```
[raw_simkopdes_national.csv] ← agregat ← [raw_simkopdes_province.csv] ← [raw_simkopdes_kelembagaan.csv]
                                                   ↓
                                    [raw_simkopdes_transaksi_per_provinsi.csv]
                                    [raw_simkopdes_ews_top5_*.csv]
                                    [raw_simkopdes_produk_top10.csv]
                                    [raw_simkopdes_koperasi_aktif_top10.csv]

[raw_simkopdes_ews_kesehatan.csv]  ← subset dari nasional (31.265 pelapor)
[raw_simkopdes_ews_laporan.csv]    ← kepatuhan (sudah/belum lapor)
[raw_simkopdes_ews_ringkasan_keuangan.csv] ← P&L, neraca, rasio
```

### 9.2 Data Analisis
```
[raw_issues.csv]        ← 20 isu, tiap isu punya ID (iss-001 ... iss-020)
      ↕ terkait via severity & pihak terdampak
[raw_stakeholders.csv]  ← 15 pemangku kepentingan (stake-01 ... stake-15)
      ↓
[raw_data_points.csv]   ← 33 data point pendukung argumen
[raw_timeline.csv]      ← 24 peristiwa dalam kronologi
[raw_sentiment_*.csv]   ← 5 file sentimen dari berbagai sumber
[raw_trust_analysis.csv]← 7 parameter + skor rata-rata 2,4/10
[raw_analysis_insights.csv] ← 7 dimensi insight & rekomendasi
```

### 9.3 Research — Data Sosial Media
```
research/tiktok_findings.csv        ← 24 konten TikTok (real-time scrape)
research/youtube_findings.csv       ← 20 video YouTube (real-time scrape)
research/sentimen_analysis.md       ← Analisis lintas platform + web
```

---

## 10. Key Verdict Questions

Untuk juri — pertanyaan kunci yang harus dijawab berdasarkan bukti:

### Struktural
1. **Apakah Kopdes adalah koperasi sungguhan atau proyek negara?**  
   *Bukti: Pendekatan top-down (iss-003), tanpa partisipasi anggota (iss-012), dibentuk seragam dari pusat (YLBHI)*

2. **Apakah TNI seharusnya terlibat dalam ekonomi desa?**  
   *Bukti: Pelatihan militer SPPI (iss-004), 5 kematian (iss-005), kritik Komnas HAM & YLBHI*

### Ekonomi
3. **Apakah model bisnis Kopdes berkelanjutan?**  
   *Bukti: 46,6% transaksi = pupuk bersubsidi, omzet Rp100.000/hari (BBC), tanpa studi kelayakan (iss-013)*

4. **Apakah risiko gagal bayar terkelola?**  
   *Bukti: Rp2,8-4,6T/bulan risiko bank Himbara (iss-002), 91,1% koperasi tidak sehat*

### Sosial
5. **Apakah program ini didukung masyarakat?**  
   *Bukti: 76% tolak skema (CELIOS), 59% sentimen negatif TikTok, 11 lembaga kontra, viral penolakan Kades*

### Kelembagaan
6. **Apakah Kopdes memperkuat atau mematikan BUMDes?**  
   *Bukti: Iss-011 (BUMDes mati suri), potongan dana desa 58% (iss-001), Kades Pati & Purworejo menolak*

### Tata Kelola
7. **Apakah tata kelola Kopdes cukup transparan?**  
   *Bukti: Skor transparansi 3/10, skor akuntabilitas 2/10, penunjukkan langsung Agrinas tanpa tender (ICW)*

### Keselamatan
8. **Apakah program SPPI/Latsarmil layak dilanjutkan?**  
   *Bukti: 5 kematian (iss-005, iss-016), Rp1,35T anggaran, biaya Rp45jt/orang, pelatihan tidak relevan dengan manajemen koperasi*

---

## Lampiran A — File Reference Cepat

| Kebutuhan | File | Baris |
|-----------|------|-------|
| Semua data nasional dalam satu tempat | `data-raw/raw_simkopdes_national.csv` | 34 baris |
| Data per provinsi | `data-raw/raw_simkopdes_province.csv` | 38 provinsi |
| Semua angka penting untuk argumen | `data-raw/raw_data_points.csv` | 33 data point |
| Daftar isu lengkap | `data-raw/raw_issues.csv` | 20 isu |
| Daftar stakeholder | `data-raw/raw_stakeholders.csv` | 15 pihak |
| Timeline | `data-raw/raw_timeline.csv` | 24 event |
| Skor kepercayaan | `data-raw/raw_trust_analysis.csv` | 8 parameter |
| Insight & rekomendasi | `data-raw/raw_analysis_insights.csv` | 7 dimensi |
| Sentimen TikTok terbaru | `research/tiktok_findings.csv` | 24 konten |
| Sentimen YouTube | `research/youtube_findings.csv` | 20 video |
| Analisis sentimen lengkap | `research/sentimen_analysis.md` | Narasi |
| Panduan alur data | `AGREGASI.md` | Pipeline |
| Definisi & rumus | `GUIDANCE_DATA.md` | Lengkap |

---

> **Dibuat:** 10 Juli 2026  
> **Sumber data:** `docs/references/*.json` (15 file), `data-raw/` (26 CSV), `research/` (3 file)  
> **Referensi:** `AGREGASI.md` (pipeline), `GUIDANCE_DATA.md` (definisi & rumus)
