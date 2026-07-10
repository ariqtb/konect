# Domain Context — Koperasi Desa & Trust Ekonomi

> **Author:** alwan
> **Tanggal:** 2026-07-10
> **Status:** Final
> **Tags:** `#domain` `#kopdes` `#kdmp` `#trust`

---

## 1. Program Koperasi Desa Merah Putih (KDMP)

### 1.1 Latar Belakang

**Koperasi Desa Merah Putih (KDMP/KKMP)** adalah program unggulan Presiden Prabowo yang bertujuan membentuk koperasi di setiap desa/kelurahan di Indonesia. Program ini diinisiasi melalui **Inpres No. 9/2025** dan didanai dari **Dana Desa (58% dipotong)**.

### 1.2 Data Terkini (per 9 Juli 2026)

| Indikator | Nilai |
|---|---|
| Total koperasi berbadan hukum | **83.382** (104,2% dari target awal 80.000) |
| Target operasional (revisi) | **40.000** akhir 2026 |
| Selesai pembangunan fisik | 12.533 unit (31,3% dari target revisi) |
| Masih dibangun | 22.737 unit |
| Koperasi sehat | **683 (2,2%)** dari 31.265 yang lapor |
| Koperasi tidak sehat | **28.495 (91,1%)** |
| Belum pernah lapor keuangan | **52.117 (62,5%)** |
| Pendapatan nasional | Rp 85,26 Miliar (rata-rata Rp 2,7jt/koperasi/tahun) |
| Pelaksanaan RAT | 60,3% (22,5% belum RAT) |
| Sudah punya NIB | 72,9% |
| Sentimen publik negatif (TikTok) | **59%** |

### 1.3 Isu-Isu Kritis

1. **91,1% koperasi tidak sehat** — masalah fundamental tata kelola
2. **62,5% belum pernah lapor keuangan** — transparansi sangat rendah
3. **Target dipangkas** dari 80.000 → 40.000 — indikasi target awal tidak realistis
4. **Tragedi Latsarmil** — 5 peserta meninggal dalam 10 hari pertama pelatihan
5. **Pendekatan top-down** — dikritik sebagai pelanggaran UU Perkoperasian
6. **Disinsentif fiskal** — Dana Desa tidak cair jika Kopdes tidak dibentuk (berbeda dengan China yang pakai insentif)
7. **Kesenjangan Jawa vs Timur Indonesia** — 32x lipat (Jateng 8.524 vs DKI 268)

---

## 2. Mengapa Konect Penting

### 2.1 Masalah yang Diselesaikan

| Masalah | Solusi Konect |
|---|---|
| Partisipasi anggota rendah | Forum diskusi digital yang mudah diakses |
| Transparansi rendah | Voting publik + node graph visualisation |
| Tidak ada struktur diskusi | Hierarki Topik → Pendapat → Komentar |
| Informasi tenggelam | ML relevance scoring + ranking |
| Tidak ada insentif partisipasi | Poin + reward + leaderboard |
| Trust rendah | Geolocation verification + anonymous option |

### 2.2 Trust & Transparansi

Konect mengedepankan **trust, transparansi, dan keterlibatan** sebagai nilai utama:

1. **Geolocation Trust** — Setiap posting mencatat lokasi, dipastikan dalam radius koperasi
2. **Voting Transparan** — Setiap pendapat adalah vote (agree/disagree), semua orang bisa lihat
3. **Node Graph** — Visualisasi korelasi antar pendapat, tidak ada yang bisa "dikubur"
4. **Anonymity Option** — Warga bisa posting anonim jika perlu
5. **ML Fairness** — Relevance score tidak bias, berdasarkan semantic similarity

### 2.3 Insight dari Riset

Berdasarkan riset di `docs/references/`:

- **Trust deficit bersifat multidimensi** — bukan masalah komunikasi, tapi desain program
- **55% responden netral** di Twitter, **59% negatif** di TikTok
- **Keyword dominan negatif:** korupsi, anggaran, proyek
- **Keyword positif:** ekonomi, produk lokal, memajukan
- **65% perangkat desa** melihat celah korupsi besar
- **76% perangkat desa** menolak skema pembiayaan Rp3M/unit

---

## 3. User Personas

### 3.1 Warga Desa (Anggota Koperasi)

- **Tujuan:** Berpartisipasi dalam diskusi koperasi, memberikan pendapat, voting
- **Kebutuhan:** Aplikasi simple, bahasa Indonesia, bisa anonim
- **Pain point:** Gaptek, kuota terbatas, tidak percaya pemerintah

### 3.2 Admin Koperasi

- **Tujuan:** Mengelola forum, membuat topik, memoderasi konten
- **Kebutuhan:** Dashboard sederhana, bisa hapus/edit konten
- **Pain point:** Waktu terbatas, sibuk urusan lapangan

### 3.3 Pengurus Koperasi (Ketua/Bendahara)

- **Tujuan:** Melihat opini anggota, mengambil keputusan berdasarkan data
- **Kebutuhan:** Report, leaderboard, analisis diskusi
- **Pain point:** Sulit mengukur sentimen anggota secara manual

---

## 4. Glossary

| Istilah | Definisi |
|---|---|
| **Kopdes** | Koperasi Desa |
| **KDMP** | Koperasi Desa Merah Putih |
| **KKMP** | Koperasi Kampung Merah Putih (untuk kampung nelayan) |
| **RAT** | Rapat Anggota Tahunan (kewajiban koperasi) |
| **NIB** | Nomor Induk Berusaha (izin usaha) |
| **SHU** | Sisa Hasil Usaha (laba koperasi) |
| **Latsarmil** | Latihan Dasar Kemiliteran (program SPPI) |
| **SPPI** | Sekolah Penggerak dan Pengelola Koperasi Indonesia |
| **SIMKOPDES** | Sistem Informasi Manajemen Koperasi Desa |
| **pgvector** | PostgreSQL extension untuk vector similarity search |
| **IVFFlat** | Inverted File with Flat Compression (pgvector index) |
| **Haversine** | Formula untuk menghitung jarak antar titik di bumi |
| **Force-directed Graph** | Visualisasi graph dengan simulasi fisika |
| **Cross-Encoder** | Model ML untuk pairwise relevance scoring |
| **Bi-Encoder** | Model ML untuk generate text embedding |
