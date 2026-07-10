# Discussion Rooms — Logic & Flow

> **Author:** sisyphus
> **Tanggal:** 2026-07-10
> **Status:** Final
> **Tags:** `#discussion-rooms` `#bloc` `#flutter` `#feature`

---

## 1. Ringkasan

Logic untuk **membuat ruang diskusi** (`discussion_rooms`) di Flutter. Mengikuti pattern BLoC + Repository yang sudah ada di project (lihat `architecture.md`).

**Status:** Sudah end-to-end usable. Backend masih placeholder (in-memory repository). Akan diganti ke Supabase saat DB siap.

---

## 2. File yang Terlibat

| Layer | File | Fungsi |
|---|---|---|
| Model | `lib/data/models/discussion_room.dart` | Map 1:1 ke kolom DB `discussion_rooms` |
| Repository | `lib/data/repositories/discussion_room_repository.dart` | Singleton; `createRoom`, `getRoomsByCooperative`, `getRoomById` |
| BLoC | `lib/presentation/blocs/discussion/discussion_room_bloc.dart` | Event/State management + validasi |
| UI | `lib/presentation/pages/room/create_room_page.dart` | Form, dispatch event, BlocListener |
| UI | `lib/presentation/pages/room/room_discussion_page.dart` | Terima `DiscussionRoom?` atau `String` sebagai argumen |
| Wiring | `lib/app.dart` | `BlocProvider(create: (_) => DiscussionRoomBloc())` |

---

## 3. Schema Mapping (dari `database/001_init_schema.sql`)

```sql
discussion_rooms (
    id              UUID PK auto,
    cooperative_id  UUID FK NOT NULL → cooperatives.id,
    created_by      UUID FK NOT NULL → users.id,
    title           VARCHAR(255) NOT NULL,
    description     TEXT,
    is_active       BOOL default true,
    is_anonymous    BOOL default false,
    created_at      TIMESTAMPTZ default now(),
    updated_at      TIMESTAMPTZ default now()  -- via trigger
)
```

| Param `createRoom()` | Schema Column | Keterangan |
|---|---|---|
| `cooperativeId` | `cooperative_id` | Wajib, dari dropdown "Penyelenggara" |
| `createdBy` | `created_by` | Wajib, dari `AuthBloc.state.user.id` |
| `title` | `title` | Wajib, max 255 char (divalidasi BLoC) |
| `description` | `description` | Optional, BLoC trim & null-kan jika kosong |
| `isAnonymous` | `is_anonymous` | Default `false`, dari Switch di UI |

**Auto-generated (tidak dikirim):** `id`, `is_active`, `created_at`, `updated_at`.

---

## 4. Alur Pembuatan Room

```
User isi form di CreateRoomPage
        │
        ▼
_submit() — validasi lokal
  ├─ Form validate
  ├─ _selectedCoopId != null
  └─ AuthBloc.state is AuthAuthenticated
        │
        ▼
Dispatch DiscussionRoomCreateRequested(cooperativeId, createdBy, title, description, isAnonymous)
        │
        ▼
DiscussionRoomBloc._onCreate()
  ├─ Validasi: title tidak kosong, max 255 char
  ├─ Validasi: cooperativeId, createdBy tidak kosong
  ├─ emit DiscussionRoomCreating
  └─ discussionRoomRepository.createRoom(...)
        │
        ▼ (success)
emit DiscussionRoomCreated(room)
        │
        ▼
BlocListener di CreateRoomPage navigate ke RoomDiscussionPage
arguments: state.room (DiscussionRoom object)
        │
        ▼
RoomDiscussionPage baca args sebagai DiscussionRoom
  → topic = args.title
```

---

## 5. Validasi

| Lokasi | Validasi | Pesan Error |
|---|---|---|
| `_submit()` (UI) | Form tidak valid | (per-field, dari validator di CustomTextField) |
| `_submit()` (UI) | `_selectedCoopId == null` | "Pilih koperasi penyelenggara terlebih dahulu" |
| `_submit()` (UI) | `authState is! AuthAuthenticated` | "Anda harus login terlebih dahulu" |
| `_onCreate` (BLoC) | `title.trim().isEmpty` | "Judul room tidak boleh kosong" |
| `_onCreate` (BLoC) | `title.length > 255` | "Judul room maksimal 255 karakter" |
| `_onCreate` (BLoC) | `cooperativeId.empty` | "Koperasi penyelenggara harus dipilih" |
| `_onCreate` (BLoC) | `createdBy.empty` | "User tidak terautentikasi. Silakan login ulang." |
| Repository | Exception saat `createRoom` | Dibungkus: "Gagal membuat room: <exception>" |

---

## 6. State Transitions

```
Initial ──[CreateRequested(valid)]──▶ Creating ──[repo success]──▶ Created
   ▲                                       │                          │
   │                                       └──[repo throw]──▶ Error   │
   │                                                                  │
   └─────────────────────[ResetRequested]──────────────────────────┘
```

---

## 7. Catatan untuk Iterasi Selanjutnya

1. **Kode Ruang** di form UI (`_codeController`) tidak ada kolom di schema. Saat ini hanya validasi "tidak kosong" tapi value-nya **tidak dikirim ke BLoC**. Saran: hapus field ini atau tambah kolom `invite_code` di schema (perlu migration).
2. **Repository** masih in-memory. Saat Supabase siap, ganti body `createRoom()` dengan:
   ```dart
   final response = await supabase
       .from('group3b_discussion_rooms')
       .insert(payload)
       .select()
       .single();
   return DiscussionRoom.fromJson(response);
   ```
   Prefix `group3b_` wajib karena aturan shared hackathon DB.
3. **De-duplication** `CoopDiscussionRoom` (di `cooperative_detail.dart`) vs `DiscussionRoom` (di sini). Untuk sekarang biarkan; `CoopDiscussionRoom` adalah display model di cooperative detail (punya field turunan seperti `status`, `membersCount`), sedangkan `DiscussionRoom` adalah DB model murni. Bisa di-refactor nanti.
4. **Test**: belum ada `bloc_test` atau widget test. Tambah nanti kalau ada waktu.
5. **Idempotency**: `createRoom` saat ini selalu insert baru. Kalau user double-click, bisa double-insert. BLoC sudah mitigate dengan `isCreating` flag di UI (button disabled), tapi backend perlu unique constraint atau client-generated UUID untuk benar-benar aman.
