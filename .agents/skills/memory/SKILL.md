---
name: memory
description: "Sistem memori bersama untuk agent AI di tim Konect. Memungkinkan agent membaca/menulis/memperbarui konteks proyek di docs/memory/ agar semua agent memiliki pemahaman yang sama dan tidak kehilangan konteks antar sesi. Panggil skill ini ketika: memulai task baru, menemukan informasi penting, atau menanyakan konteks proyek."
---

# Memory — Shared Context untuk Agent AI Tim Konect

Skill ini adalah sistem **memori bersama** yang memungkinkan semua agent AI di tim Konect berbagi konteks, pengetahuan, dan pemahaman tentang proyek melalui file markdown terstruktur di `docs/memory/`.

## Filosofi

Setiap agent AI memulai sesi dengan "blank slate" — tidak tahu apa yang sudah dikerjakan agent lain atau keputusan apa yang sudah dibuat. Skill ini menjembatani kesenjangan itu dengan menyediakan **shared memory** yang:

1. **Persisten** — informasi bertahan antar sesi dan antar agent
2. **Terstruktur** — format baku dengan author, tanggal, dan tags
3. **Self-editing** — agent bisa membaca dan menulis memory sendiri
4. **Terpusat** — satu sumber kebenaran di `docs/memory/`

## Struktur Memory

Semua file memory disimpan di **`docs/memory/`** dengan format markdown:

```
docs/memory/
├── project-overview.md      # Gambaran umum proyek
├── architecture.md           # Arsitektur sistem
├── database-schema.md        # Desain database
├── domain-context.md         # Konteks bisnis & domain
└── ... (file baru sesuai kebutuhan)
```

## Format Penulisan Memory

Setiap file memory WAJIB mengikuti format berikut:

```markdown
# Title — Subtitle (Jika Ada)

> **Author:** [nama-agent atau nama-manusia]
> **Tanggal:** YYYY-MM-DD
> **Status:** Draft | Final | Outdated
> **Tags:** `#tag1` `#tag2` `#tag3`

---

## 1. Pendahuluan

Konteks singkat tentang apa yang dibahas di file ini.

## 2. Konten Utama

Penjelasan detail, bisa berupa:
- Poin-poin penting
- Tabel perbandingan
- Diagram (ASCII / Mermaid)
- Cuplikan kode

## 3. Referensi

Link ke file lain, dokumentasi, atau sumber eksternal.
```

### Aturan Format

| Aturan | Penjelasan |
|---|---|
| **Author** | Nama agent atau manusia yang menulis. Contoh: `alwan`, `sisyphus`, `prometheus` |
| **Tanggal** | Format ISO: `YYYY-MM-DD`. Contoh: `2026-07-10` |
| **Status** | `Draft` = masih dikerjakan, `Final` = sudah fix, `Outdated` = perlu diupdate |
| **Tags** | Minimal 1 tag. Format `#tag`. Contoh: `#architecture` `#database` |
| **Heading** | Gunakan ATX heading (`#`, `##`, `###`). Jangan skip level. |
| **Tabel** | Gunakan pipe table (`\|`). |
| **Kode** | Gunakan fenced code block dengan language identifier. |

## Kapan Menulis Memory Baru

Tulis memory baru ketika:

1. **Menemukan arsitektur atau pola penting** yang akan digunakan agent lain
2. **Membuat keputusan desain** yang mempengaruhi lebih dari 1 modul
3. **Menambahkan fitur baru** yang signifikan
4. **Menyelesaikan investigasi** yang menghasilkan insight penting
5. **Mengubah konfigurasi** atau struktur proyek
6. **Menemukan bug** dengan root cause yang perlu diketahui agent lain
7. **Ada perubahan** pada business domain atau data referensi

## Kapan Membaca Memory

Baca memory yang ada ketika:

1. **Memulai task baru** — baca `project-overview.md` dulu
2. **Bekerja dengan database** — baca `database-schema.md`
3. **Memodifikasi arsitektur** — baca `architecture.md`
4. **Butuh konteks bisnis** — baca `domain-context.md`
5. **Tidak yakin** apakah suatu keputusan sudah dibuat — cari di semua file
6. **Sebelum mengubah** kode yang sudah ada — baca memory terkait modul tersebut

## Protokol Sharing

### Menambahkan Memory Baru

```markdown
1. Buat file baru di `docs/memory/<nama-file>.md`
2. Ikuti format penulisan di atas
3. Pastikan author, tanggal, status, dan tags terisi
4. Gunakan bahasa Indonesia (atau English jika topik teknis murni)
5. Jangan duplikasi informasi yang sudah ada
```

### Memperbarui Memory yang Ada

```markdown
1. Baca file yang akan diupdate
2. Update konten yang berubah
3. Update tanggal ke hari ini
4. Update status jika perlu (Final → Outdated → Final lagi)
5. Tambahkan catatan perubahan di bagian bawah file (opsional)
6. Jangan hapus informasi lama tanpa menggantinya
```

### Marking Memory Outdated

Jika menemukan memory yang sudah tidak sesuai:

```markdown
1. Ubah status menjadi `Outdated`
2. Update tanggal ke hari ini
3. Tambahkan komentar di bagian atas: "⚠️ MEMORY INI OUTDATED. Lihat [file-baru.md] untuk versi terbaru."
```

## Daftar Memory Saat Ini

| File | Status | Author | Tanggal | Deskripsi |
|---|---|---|---|---|
| `project-overview.md` | Final | alwan | 2026-07-10 | Gambaran umum proyek Konect |
| `architecture.md` | Final | alwan | 2026-07-10 | Arsitektur Flutter + Supabase + Python ML |
| `database-schema.md` | Final | alwan | 2026-07-10 | Desain database dan relasi |
| `domain-context.md` | Final | alwan | 2026-07-10 | Konteks bisnis Koperasi Desa & trust ekonomi |

## Catatan untuk Agent

- **Jangan ubah format file** — konsistensi format adalah kunci sharing yang efektif
- **Jangan hapus file** tanpa persetujuan tim
- **Jika ragu** tentang suatu keputusan, cek memory dulu sebelum bertanya ke user
- **Gunakan bahasa Indonesia** untuk konteks proyek, bahasa Inggris untuk teknis murni (code, query, dll)
- **Satu topik per file** — jangan campur arsitektur dengan database dalam satu file
- **Link antar file** jika saling berhubungan (contoh: architecture.md bisa link ke database-schema.md)
