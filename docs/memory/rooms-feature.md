# Rooms Feature — Create Room & Local Storage

> **Author:** sisyphus
> **Tanggal:** 2026-07-10
> **Status:** Final
> **Tags:** `#rooms` `#discussion_rooms` `#local-storage` `#shared-preferences`

---

## 1. Ringkasan

Fitur **Create Room** memungkinkan pengguna (warga/admin koperasi) untuk membuat ruang diskusi baru (`discussion_rooms`) di dalam koperasi. Saat ini data disimpan ke **SharedPreferences** sebagai solusi sementara sebelum backend Supabase siap digunakan.

---

## 2. File yang Terlibat

| File | Fungsi |
|---|---|
| `database/003_create_rooms.sql` | Migrasi SQL untuk tabel `discussion_rooms` (standalone) |
| `lib/data/models/discussion_room.dart` | Model `DiscussionRoom` — mapping ke tabel |
| `lib/data/repositories/discussion_room_repository.dart` | Repository dengan SharedPreferences persistence |
| `lib/presentation/blocs/discussion/discussion_room_bloc.dart` | BLoC untuk create room (validasi + state) |
| `lib/presentation/pages/room/create_room_page.dart` | Halaman form create room |
| `lib/main.dart` | Bootstrap repository di startup |
| `lib/core/constants.dart` | Route constant `createRoomRoute` |

---

## 3. Alur Create Room

```
User isi form → tekan "Buat Room Baru"
       ↓
CreateRoomPage.validate() → client-side validation
       ↓
Dispatch DiscussionRoomCreateRequested ke BLoC
       ↓
DiscussionRoomBloc._onCreate() → validasi server-side
       ↓
DiscussionRoomRepository.createRoom() → simpan ke SharedPreferences
       ↓
Emit DiscussionRoomCreated → listener navigasi ke RoomDiscussionPage
```

### Validation Rules

| Field | Rule |
|---|---|
| `title` | NOT NULL, max 255 karakter |
| `cooperativeId` | NOT NULL, harus dipilih |
| `createdBy` | NOT NULL, dari session user |

---

## 4. Local Storage (SharedPreferences)

### Key
- `discussion_rooms` — JSON array of room objects

### Format
```json
[
  {
    "id": "room_1747123456_0",
    "cooperative_id": "c1",
    "created_by": "1",
    "title": "Pembahasan Distribusi Sembako",
    "description": "...",
    "is_active": true,
    "is_anonymous": false,
    "created_at": "2026-07-10T10:00:00.000",
    "updated_at": "2026-07-10T10:00:00.000"
  }
]
```

### Bootstrap Flow
1. `main()` → `PreferencesService.bootstrap()` (shared_preferences init)
2. `main()` → `DiscussionRoomRepository.bootstrap()` (load dari disk ke cache)
3. Setiap operasi write langsung `_persist()` ke SharedPreferences

### ID Generation
Karena belum pakai UUID DB, ID dibuat dengan format:
```
room_{microsecondsSinceEpoch}_{index}
```
Contoh: `room_1747123456789_0`

---

## 5. Route

| Route | Halaman | Args |
|---|---|---|
| `/create-room` | `CreateRoomPage` | — |
| `/room-discussion` | `RoomDiscussionPage` | `String` (title) |

Route `/create-room` sudah terdaftar di `app.dart` via `onGenerateRoute`.

---

## 6. Migrasi ke Database (Future)

Saat Supabase backend siap:

1. Ganti `DiscussionRoomRepository` untuk panggil PostgREST/Supabase client
2. ID akan pakai `uuid_generate_v4()` dari PostgreSQL
3. Hapus `_persist()` dan `_loadFromDisk()`
4. Migrasi data dari SharedPreferences ke DB via export/import
5. Schema SQL sudah siap di `database/003_create_rooms.sql`

---

## 7. Catatan

- Cooperative list di dropdown di-load dari `cooperativeRepository.getCooperatives()`
- User ID diambil dari `AuthBloc` state (`AuthAuthenticated.user.id`)
- Room baru ditaruh di index 0 cache (terbaru di paling atas)
- Jika SharedPreferences corrupt, data akan di-reset otomatis
- Ada `deactivateRoom()` dan `deleteRoomPermanent()` untuk soft/hard delete
