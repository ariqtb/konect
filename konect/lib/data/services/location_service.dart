import 'dart:async';
import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

import '../models/user_location.dart';

/// Status izin lokasi yang dinormalisasi lintas platform.
///
/// geolocator punya [LocationPermission] enum (Android: whileInUse/always,
/// iOS: hampir sama), permission_handler punya [PermissionStatus] enum.
/// Layer ini memaparkan satu union ke BLoC agar tidak perlu tahu
/// seluk-beluk permission per platform.
enum LocationPermissionStatus {
  /// Pertama kali app dibuka, atau setelah reset. Aman untuk request.
  notDetermined,

  /// User menolak sekali — masih bisa request lagi.
  denied,

  /// User menandai "Jangan Tanya Lagi" / "Don't Allow Again" — minta user
  /// buka Settings manual.
  deniedForever,

  /// iOS only: di-restrict oleh parental control / MDM.
  restricted,

  /// User memberi izin. Aman akses posisi.
  granted,

  /// GPS/location service di device mati — bukan masalah izin, tapi service.
  serviceDisabled,
}

/// Konfigurasi untuk stream realtime.
///
/// Defaults diset untuk use case Konect: cari koperasi & room sekitar user
/// saat mereka berdiri/diam di balai desa. Tidak perlu update super sering,
/// 50m filter cukup supaya UI tidak rebuild tiap 1m geser HP.
class LocationStreamConfig {
  /// Akurasi target. `high` cocok untuk proximity koperasi (radius 200m).
  final LocationAccuracy accuracy;

  /// Minimum perpindahan (meter) sebelum emit update baru.
  /// 0 = emit tiap fix GPS, 50 = emit hanya setelah user bergerak 50m.
  final int distanceFilter;

  const LocationStreamConfig({
    this.accuracy = LocationAccuracy.high,
    this.distanceFilter = 50,
  });

  LocationSettings toPlatformSettings() {
    return LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
    );
  }
}

/// Base exception untuk layer location.
class LocationServiceException implements Exception {
  final String message;
  const LocationServiceException(this.message);
  @override
  String toString() => 'LocationServiceException: $message';
}

/// GPS nonaktif di device.
class LocationServiceDisabledException extends LocationServiceException {
  const LocationServiceDisabledException(super.message);
}

/// Permission belum / tidak cukup.
class LocationPermissionException extends LocationServiceException {
  const LocationPermissionException(super.message);
}

/// Low-level wrapper di atas `package:geolocator`.
///
/// Tanggung jawab service ini:
/// 1. Mengecek GPS service aktif
/// 2. Mengecek & meminta permission
/// 3. Mengambil posisi saat ini (one-shot)
/// 4. Membuka stream posisi realtime
/// 5. Menghitung jarak (haversine) — disinkronkan dengan rumus DB
///    `haversine_distance()` di `database/001_init_schema.sql`.
///
/// Tidak ada dependency ke BLoC / Repository — pure stateless function.
/// Untuk facade dengan caching & singleton, lihat [LocationRepository].
class LocationService {
  StreamSubscription<Position>? _activeSub;
  final StreamController<UserLocation> _controller =
      StreamController<UserLocation>.broadcast();

  /// Stream broadcast yang emits [UserLocation] setiap fix GPS masuk.
  /// Aman didengarkan dari banyak subscriber (mis. UI + BLoC).
  Stream<UserLocation> get positionStream => _controller.stream;

  /// Apakah service ini sedang aktif listening stream?
  bool get isStreaming => _activeSub != null;

  // =========================================================
  // 1. PERMISSION LIFECYCLE
  // =========================================================

  /// Cek apakah GPS service di device aktif. Tidak menyentuh permission.
  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  /// Cek status permission saat ini tanpa memicu dialog.
  Future<LocationPermissionStatus> checkPermission() async {
    final perm = await Geolocator.checkPermission();
    return _mapGeolocatorPermission(perm);
  }

  /// Minta izin ke user. Hanya boleh dipanggil kalau status BUKAN
  /// [LocationPermissionStatus.deniedForever] — kalau dipaksa, geolocator
  /// akan silently return `denied` tanpa menampilkan dialog.
  ///
  /// Throws [LocationServiceDisabledException] kalau GPS mati.
  Future<LocationPermissionStatus> requestPermission() async {
    final serviceOk = await isServiceEnabled();
    if (!serviceOk) {
      throw const LocationServiceDisabledException(
        'Location service di device nonaktif. Aktifkan GPS di Settings.',
      );
    }

    final current = await Geolocator.checkPermission();
    if (current == LocationPermission.deniedForever) {
      // Paksa jangan request — user harus buka Settings manual.
      return LocationPermissionStatus.deniedForever;
    }

    final result = await Geolocator.requestPermission();
    final mapped = _mapGeolocatorPermission(result);
    debugPrint('[LocationService] requestPermission -> $mapped');
    return mapped;
  }

  /// Buka halaman Settings app supaya user bisa grant manual
  /// setelah `deniedForever`. Returns true kalau Settings berhasil dibuka.
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  /// Buka halaman Settings lokasi sistem (Android only, no-op di iOS).
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  // =========================================================
  // 2. ONE-SHOT POSITION
  // =========================================================

  /// Ambil posisi saat ini. Akan throw kalau service/permission belum siap.
  ///
  /// Gunakan ini untuk "first fix" — begitu user buka app dan kasih izin,
  /// kita panggil ini sekali untuk dapat koordinat awal, lalu buka stream
  /// untuk update realtime.
  Future<UserLocation> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration? timeLimit,
  }) async {
    debugPrint('[LocationService] getCurrentPosition called (accuracy=$accuracy)');
    final settings = LocationSettings(
      accuracy: accuracy,
      timeLimit: timeLimit,
    );
    try {
      final pos = await Geolocator.getCurrentPosition(locationSettings: settings);
      final userLoc = _toUserLocation(pos);
      debugPrint('[LocationService] getCurrentPosition SUCCESS -> '
          'lat=${userLoc.latitude}, lng=${userLoc.longitude}, '
          'accuracy=${userLoc.accuracy}m');
      return userLoc;
    } catch (e) {
      debugPrint('[LocationService] getCurrentPosition ERROR -> $e');
      rethrow;
    }
  }

  /// Ambil posisi terakhir yang di-cache OS. Sangat cepat (no GPS lock)
  /// tapi bisa null dan bisa stale. Cocok untuk "hydrated" state agar UI
  /// tidak kosong sebelum [getCurrentPosition] selesai.
  Future<UserLocation?> getLastKnownPosition() async {
    final pos = await Geolocator.getLastKnownPosition();
    if (pos == null) return null;
    return _toUserLocation(pos);
  }

  // =========================================================
  // 3. REALTIME STREAM
  // =========================================================

  /// Mulai listening posisi realtime. Idempotent — panggil dua kali aman,
  /// subscription lama akan di-cancel dulu.
  ///
  /// Hasilnya di-emit ke [positionStream] sebagai [UserLocation].
  /// Throws [LocationPermissionException] / [LocationServiceDisabledException]
  /// kalau prerequisite tidak terpenuhi.
  Future<void> startTracking({
    LocationStreamConfig config = const LocationStreamConfig(),
  }) async {
    debugPrint('[LocationService] startTracking called (distanceFilter=${config.distanceFilter}m, accuracy=${config.accuracy})');
    await stopTracking();

    // Pre-check biar error-nya eksplisit, bukan tiba-tiba stream diam.
    final perm = await checkPermission();
    if (perm != LocationPermissionStatus.granted) {
      throw LocationPermissionException(
        'Tidak bisa mulai tracking: status izin = $perm. '
        'Panggil requestPermission() dulu.',
      );
    }
    final serviceOk = await isServiceEnabled();
    if (!serviceOk) {
      throw const LocationServiceDisabledException(
        'Tidak bisa mulai tracking: GPS nonaktif.',
      );
    }

    _activeSub = Geolocator.getPositionStream(
      locationSettings: config.toPlatformSettings(),
    ).listen(
      (pos) => _controller.add(_toUserLocation(pos)),
      onError: (Object e) => _controller.addError(e),
    );
  }

  /// Stop listening realtime. Aman dipanggil kapan saja, termasuk
  /// kalau belum pernah start.
  Future<void> stopTracking() async {
    await _activeSub?.cancel();
    _activeSub = null;
  }

  /// Cleanup saat app shutdown. Setelah ini, service tidak bisa dipakai
  /// lagi — buat instance baru.
  Future<void> dispose() async {
    await stopTracking();
    await _controller.close();
  }

  // =========================================================
  // 4. HAVERSINE — sinkron dengan DB
  // =========================================================

  /// Hitung jarak dalam meter antara dua koordinat.
  /// Formula HARUS identik dengan `haversine_distance()` di
  /// `database/001_init_schema.sql` (Earth radius = 6371000m).
  ///
  /// Dipakai oleh client untuk:
  /// - Pre-filter koperasi sebelum query (hemat bandwidth)
  /// - Sort "terdekat" di UI
  /// - Validasi proximity sebelum submit opinion (UX feedback sebelum
  ///   dikirim ke DB yang akan trigger proximity check)
  static double haversineDistanceInMeters({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) {
    const earthRadius = 6371000.0; // meters, sama dengan DB
    final dLat = _radians(lat2 - lat1);
    final dLng = _radians(lng2 - lng1);
    final sinDLatHalf = math.sin(dLat / 2);
    final sinDLngHalf = math.sin(dLng / 2);
    final a = sinDLatHalf * sinDLatHalf +
        math.cos(_radians(lat1)) *
            math.cos(_radians(lat2)) *
            sinDLngHalf *
            sinDLngHalf;
    final c = 2 * math.asin(math.min(1.0, math.sqrt(a)));
    return earthRadius * c;
  }

  /// Helper: distance from [from] ke satu [target] (lat, lng).
  static double distanceTo(
    UserLocation from,
    double targetLat,
    double targetLng,
  ) {
    return haversineDistanceInMeters(
      lat1: from.latitude,
      lng1: from.longitude,
      lat2: targetLat,
      lng2: targetLng,
    );
  }

  // =========================================================
  // INTERNAL HELPERS
  // =========================================================

  UserLocation _toUserLocation(Position p) {
    return UserLocation(
      latitude: p.latitude,
      longitude: p.longitude,
      accuracy: p.accuracy,
      altitude: p.altitude,
      heading: p.heading,
      speed: p.speed,
      timestamp: p.timestamp,
    );
  }

  LocationPermissionStatus _mapGeolocatorPermission(LocationPermission p) {
    switch (p) {
      case LocationPermission.denied:
        return LocationPermissionStatus.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.deniedForever;
      case LocationPermission.unableToDetermine:
        return LocationPermissionStatus.notDetermined;
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return LocationPermissionStatus.granted;
    }
  }

  static double _radians(double deg) => deg * (math.pi / 180.0);
}
