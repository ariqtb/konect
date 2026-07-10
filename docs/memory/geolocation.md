# Geolocation — Permission & Realtime Location

> **Author:** sisyphus
> **Tanggal:** 2026-07-10
> **Status:** Final
> **Tags:** `#geolocation` `#flutter` `#bloc` `#feature` `#kopdes` `#proximity`

---

## 1. Ringkasan

Fitur geolocation untuk Konect: permission lifecycle, first-fix position, dan
real-time stream. Fondasi ini dipakai untuk dua use case downstream:

1. **Cari koperasi terdekat** — `CooperativeRepository` akan filter dengan
   `LocationService.haversineDistanceInMeters()` di client, lalu query Supabase.
2. **Room diskusi aktif di sekitar user** — `DiscussionRoomRepository` (atau
   repository baru) akan query `discussion_rooms` yang join ke `cooperatives`
   dalam radius `proximity_radius_meters` user.

Implementasi mengikuti BLoC pattern project (lihat `architecture.md` dan
`discussion-rooms.md`). Package: `geolocator: ^14.0.0`.

---

## 2. File yang Terlibat

| Layer | File | Fungsi |
|---|---|---|
| Model | `lib/data/models/user_location.dart` | `UserLocation` immutable: lat, lng, accuracy, altitude, heading, speed, timestamp |
| Service | `lib/data/services/location_service.dart` | Wrapper `geolocator`: permission, current pos, stream, **haversine** |
| Repository | `lib/data/repositories/location_repository.dart` | Singleton facade + cache `lastKnown` + delegasi ke service |
| BLoC | `lib/presentation/blocs/location/location_bloc.dart` | State machine: Initial → Checking → Ready / Denied / PermanentlyDenied / ServiceDisabled / Error |
| Platform | `android/app/src/main/AndroidManifest.xml` | `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` |
| Platform | `ios/Runner/Info.plist` | `NSLocationWhenInUseUsageDescription`, `NSLocationAlwaysAndWhenInUseUsageDescription` |
| Wiring | `lib/app.dart` | `BlocProvider(create: (_) => LocationBloc()..add(LocationInitialized()))` |
| Tests | `test/location_service_test.dart` | 6 tests haversine vs reference values |
| Tests | `test/user_location_test.dart` | 7 tests untuk model invariants |

---

## 3. Schema Mapping (untuk use case downstream)

### 3.1 Ambil lokasi user (fondasi)

```dart
// Trigger pertama kali app buka
context.read<LocationBloc>().add(const LocationInitialized());

// Atau request izin (kalau user tap tombol "Izinkan")
context.read<LocationBloc>().add(const LocationPermissionRequested());

// Listen state di UI
BlocBuilder<LocationBloc, LocationState>(
  builder: (context, state) {
    if (state is LocationReady) {
      final loc = state.location; // UserLocation
      // loc.latitude, loc.longitude
    }
  },
)
```

### 3.2 Kirim lokasi saat posting opinion

Schema kolom di `database/001_init_schema.sql`:

```sql
opinions (
    latitude  DECIMAL(10,7) NOT NULL,  -- lokasi user saat kirim pendapat
    longitude DECIMAL(10,7) NOT NULL,
    ...
)
```

Mapping: `UserLocation.toSupabase()` → `{'latitude': ..., 'longitude': ...}`.
Langsung kirim ke `group3b_opinions` insert (prefix wajib karena shared DB).
DB trigger `check_opinion_proximity` akan reject kalau di luar radius koperasi.

### 3.3 Cari koperasi terdekat (BELUM diimplementasi — TODO)

```dart
// Pseudo-code untuk iterasi berikutnya
final loc = context.read<LocationBloc>().state.currentLocation;
if (loc == null) return;

final coops = await cooperativeRepository.getCooperatives();
// Filter + sort di client (pre-DB optimization)
final nearest = coops
    .where((c) => c.latitude != null && c.longitude != null)
    .map((c) => (
      coop: c,
      distance: LocationService.haversineDistanceInMeters(
        lat1: loc.latitude, lng1: loc.longitude,
        lat2: c.latitude!, lng2: c.longitude!,
      ),
    ))
    .where((r) => r.distance <= 5000) // 5km filter
    .toList()
  ..sort((a, b) => a.distance.compareTo(b.distance));
```

Nanti bisa diganti dengan PostGIS-style query di Supabase:
```sql
SELECT id, name, haversine_distance(:lat, :lng, latitude, longitude) AS distance
FROM group3b_cooperatives
WHERE is_active = true
ORDER BY distance ASC
LIMIT 10;
```

### 3.4 Cari room aktif di sekitar user (BELUM diimplementasi — TODO)

```sql
SELECT r.id, r.title, r.description,
       haversine_distance(:lat, :lng, c.latitude, c.longitude) AS distance
FROM group3b_discussion_rooms r
JOIN group3b_cooperatives c ON c.id = r.cooperative_id
WHERE r.is_active = true
  AND haversine_distance(:lat, :lng, c.latitude, c.longitude) <= 5000
ORDER BY distance ASC;
```

Room yang muncul = koperasi yang lokasinya dekat dengan user. Tetap
di-trigger proximity check di level opinion/comment (radius koperasi, bukan radius user).

---

## 4. State Machine

```
                        ┌─────────────────────────────┐
                        ▼                             │
[Initial]──LocationInitialized──▶[Checking]──────────┤
                                                │    │
                ┌──── service off ─────────────┐  │    │
                ▼                              │  │    │
        [ServiceDisabled]◀──LocationPermissionRequested──┐
                                                │  │    │
                ┌──── service on ──────────────┘  │    │
                ▼                                 │    │
        [PermissionDenied] ◀──── denied ─────────┤    │
        [PermissionPermanentlyDenied] ◀ forever ──┤    │
        [PermissionDenied] ◀──── restricted/undetermined─┤
        [Ready]  ◀──── granted ─────────────┘    │
                │                                 │
                └──LocationFetchRequested──▶[Ready with new pos]
                └──LocationTrackingStarted──▶[Ready, isTracking=true]
                └──LocationTrackingStopped──▶[Ready, isTracking=false]
                                                       │
[Error]  ◀──── any throw ─────────────────────────────┘
```

**State categories:**

| State | `currentLocation` | Use case UI |
|---|---|---|
| `LocationInitial` | null | Splash, show nothing |
| `LocationChecking` | null | Loading spinner |
| `LocationReady` | `UserLocation` | Normal — pakai `state.location` |
| `LocationPermissionDenied` | `lastKnown?` (nullable) | Tombol "Izinkan Lokasi" |
| `LocationPermissionPermanentlyDenied` | `lastKnown?` | Tombol "Buka Settings" (satu-satunya cara) |
| `LocationServiceDisabled` | `lastKnown?` | Tombol "Aktifkan GPS" |
| `LocationError` | `lastKnown?` | Tombol "Coba lagi" + error message |

Semua state non-initial bisa baca `state.currentLocation` untuk fallback
kalau user pernah kasih izin sebelumnya.

---

## 5. Alur: First-time user buka app

```
1. App boot → LocationBloc() + add(LocationInitialized)
2. Bloc cek Geolocator.isLocationServiceEnabled()
   ├─ false → emit LocationServiceDisabled
   │         → UI: tombol "Aktifkan GPS" → LocationOpenLocationSettings
   └─ true → cek permission
3. Geolocator.checkPermission()
   ├─ denied → emit LocationPermissionDenied
   │         → UI: tombol "Izinkan Lokasi" → LocationPermissionRequested
   ├─ deniedForever → emit LocationPermissionPermanentlyDenied
   │                → UI: tombol "Buka Settings"
   └─ granted → getLastKnownPosition (instant) → emit LocationReady (cached)
                                  ↓
                            getCurrentPosition (fresh fix) → emit LocationReady
                                  ↓
                            add(LocationTrackingStarted) → start stream
4. UI BlocBuilder<LocationBloc> show:
   ├─ "Halo, warga!" (jika ready)
   ├─ empty state + tombol izin (jika denied)
   └─ snackbar error (jika service disabled)
```

---

## 6. Validasi & Invariant

| Lokasi | Aturan | Catatan |
|---|---|---|
| `UserLocation` | `lat ∈ [-90, 90]`, `lng ∈ [-180, 180]` | Cek via `isValid` |
| `LocationStreamConfig` | `distanceFilter >= 0` | Default 50m untuk hemat battery |
| `LocationService.requestPermission` | Pre-check service enabled | Throw `LocationServiceDisabledException` kalau GPS off |
| `LocationService.startTracking` | Pre-check permission granted | Throw `LocationPermissionException` kalau belum |
| `LocationRepository.stopTracking` | Idempotent | Aman panggil tanpa start dulu |
| `LocationBloc.close` | Auto-stop tracking | Cleanup saat BLoC dispose |

---

## 7. Platform Configuration

### Android — `android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    ...
```

FINE_LOCATION butuh hardware GPS — tambahkan optional kalau mau:
```xml
<uses-feature android:name="android.hardware.location.gps" android:required="false" />
```

### iOS — `ios/Runner/Info.plist`

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Konect butuh akses lokasi Anda untuk menampilkan koperasi dan ruang diskusi terdekat di sekitar Anda.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Konect butuh akses lokasi untuk memverifikasi Anda berada di area koperasi saat mengirim pendapat atau komentar.</string>
```

**PENTING:** String description WAJIB jelas dan menyebut benefit ke user,
karena App Store / Play Store reject kalau vague. Teks di atas sudah diset
untuk use case Konect.

---

## 8. Haversine — sinkron dengan DB

Formula di `LocationService.haversineDistanceInMeters` HARUS identik dengan
`haversine_distance()` di `database/001_init_schema.sql` (Earth radius
`6371000.0` meter). Test di `test/location_service_test.dart` memverifikasi
dengan reference values:

- 1° lintang di equator ≈ 111.195 m
- 1° bujur di equator ≈ 111.195 m
- Jakarta → Bandung ≈ 115.6 km
- Symmetric: A→B == B→A

Kalau ada update ke SQL function (mis. ganti ke `cube` + `earthdistance`
extension), **update juga client-side** dan tambahkan test baru.

---

## 9. Catatan untuk Iterasi Berikutnya

1. **Cari koperasi terdekat** — buat `LocationAwareCooperativeRepository` atau
   extend `CooperativeRepository` dengan method `getNearest({radiusMeters, limit})`.
   Filter pre-query di client, lalu sort + limit.

2. **Cari room aktif di sekitar** — query langsung ke Supabase RPC (lihat § 3.4).
   Buat `RoomRepository.getActiveNearby(location, radiusMeters)`.

3. **Update opinion dengan lokasi** — di `DiscussionRoomBloc` (atau
   `OpinionBloc` baru), saat user submit pendapat:
   - Baca `LocationBloc.state.currentLocation`
   - Kalau null, tolak dengan pesan "Aktifkan lokasi dulu"
   - Kalau `distance > proximity_radius_meters` koperasi, warning UX
   - Kirim `UserLocation.toSupabase()` ke `group3b_opinions` insert

4. **Cache last-known lebih agresif** — simpan ke `SharedPreferences` agar
   tidak flash kosong saat app restart. Saat ini cuma in-memory.

5. **Geofencing** — kalau mau auto-start tracking saat user masuk radius
   koperasi manapun, butuh `flutter_background_geolocation` atau
   `geofencing` plugin (lebih berat, battery drain).

6. **Test BLoC** — pakai `bloc_test` package. Saat ini baru test model +
   service. BLoC integration test belum ada karena butuh mock `geolocator`
   (atau `LocationRepository` constructor inject).

7. **iOS Simulator location** — di Xcode → Features → Location, bisa set
   custom location atau "Freeway Drive" untuk testing. Defaultnya null
   dan akan stuck di `LocationChecking` forever kalau `timeLimit` tidak di-set.
