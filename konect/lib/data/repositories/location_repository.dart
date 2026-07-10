import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../models/user_location.dart';
import '../services/location_service.dart';
import '../services/preferences_service.dart';
import 'package:flutter/foundation.dart';

/// Singleton facade di atas [LocationService].
///
/// Mengikuti pola repository yang sudah ada di project
/// (lihat `auth_repository.dart`, `cooperative_repository.dart`):
/// - Singleton instance via `final locationRepository = LocationRepository();`
/// - Membungkus low-level service dengan state yang lebih domain-friendly
///   (mis. cached `lastKnown` agar UI tidak flash kosong)
/// - Tetap stateless dari sisi business — cuma holder in-memory cache
///   yang bisa di-rebuild kapan saja.
///
/// Layer BLoC **tidak** boleh pegang instance `LocationService` langsung;
/// selalu lewat repository ini. Alasannya: ke depan, repository bisa
/// di-swap dengan mock untuk unit test BLoC tanpa harus mock `geolocator`.
class LocationRepository {
  final LocationService _service;

  UserLocation? _lastKnown;
  StreamSubscription<UserLocation>? _trackingSub;

  LocationRepository({LocationService? service})
      : _service = service ?? LocationService(),
        // Hydrate dari SharedPreferences supaya cold-start (sebelum GPS fix
        // pertama masuk ~1-3 detik di outdoor) tidak flash kosong.
        // Aman karena PreferencesService.bootstrap() dipanggil di main()
        // SEBELUM runApp, sehingga singleton ini selalu siap.
        _lastKnown = PreferencesService.instance.lastLocation {
    debugPrint('[LocationRepository] initialized, hydrated lastKnown=$_lastKnown');
  }

  /// Last position yang pernah kita dapat (dari one-shot atau stream).
  /// Bisa null kalau belum pernah dapat fix.
  UserLocation? get lastKnown => _lastKnown;

  /// True kalau sedang listening realtime stream.
  bool get isTracking => _service.isStreaming;

  // =========================================================
  // DELEGASI KE SERVICE
  // =========================================================

  Future<bool> isServiceEnabled() => _service.isServiceEnabled();

  Future<LocationPermissionStatus> checkPermission() =>
      _service.checkPermission();

  Future<LocationPermissionStatus> requestPermission() =>
      _service.requestPermission();

  Future<bool> openAppSettings() => _service.openAppSettings();

  Future<bool> openLocationSettings() => _service.openLocationSettings();

  /// Stream broadcast posisi realtime. Subscribe dari BLoC.
  Stream<UserLocation> get positionStream => _service.positionStream;

  /// First-fix position. Sekaligus update [_lastKnown] cache.
  /// Caller bisa pass `timeLimit` untuk UX (kalau GPS lock terlalu lama,
  /// return null / cached position).
  Future<UserLocation> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration? timeLimit,
  }) async {
    final pos = await _service.getCurrentPosition(
      accuracy: accuracy,
      timeLimit: timeLimit,
    );
    _lastKnown = pos;
    debugPrint('[LocationRepository] lastKnown updated via getCurrentPosition -> $pos');
    // Fire-and-forget: kalau persist gagal (mis. disk penuh), in-memory
    // cache tetap valid untuk session ini. Tidak throw ke caller supaya
    // alur permission flow tidak terganggu.
    unawaited(PreferencesService.instance.saveLastLocation(pos));
    return pos;
  }

  /// Ambil cached posisi dari OS (bisa null). Tidak update [_lastKnown]
  /// kalau null; kalau ada, replace cache + persist.
  Future<UserLocation?> getLastKnownPosition() async {
    final cached = await _service.getLastKnownPosition();
    if (cached != null) {
      _lastKnown = cached;
      debugPrint('[LocationRepository] lastKnown updated from OS cache -> $cached');
      unawaited(PreferencesService.instance.saveLastLocation(cached));
    }
    return cached;
  }

  /// Mulai tracking realtime. Update [_lastKnown] tiap emit.
  /// Idempotent.
  Future<void> startTracking({
    LocationStreamConfig config = const LocationStreamConfig(),
  }) async {
    debugPrint('[LocationRepository] startTracking requested (distanceFilter=${config.distanceFilter}m)');
    await _trackingSub?.cancel();
    await _service.startTracking(config: config);
    _trackingSub = _service.positionStream.listen((pos) {
      _lastKnown = pos;
      debugPrint('[LocationRepository] stream emit -> $pos');
      // Fire-and-forget persist. Tiap stream emit = 1 disk write.
      // Untuk 50m distanceFilter + user yang aktif, ini ~1-10x per menit
      // — masih aman untuk SharedPreferences throughput.
      unawaited(PreferencesService.instance.saveLastLocation(pos));
    });
  }

  /// Stop tracking realtime. Tidak unsubscribe dari service stream
  /// (karena stream broadcast — listener count otomatis turun), tapi
  /// cache [_lastKnown] di-stop updating dari stream.
  Future<void> stopTracking() async {
    await _trackingSub?.cancel();
    _trackingSub = null;
    await _service.stopTracking();
  }

  /// Cleanup saat app shutdown. Setelah ini, repository tidak bisa dipakai
  /// lagi — panggil `LocationRepository()` baru.
  Future<void> dispose() async {
    await _trackingSub?.cancel();
    _trackingSub = null;
    await _service.dispose();
  }

  // =========================================================
  // HAVERSINE — delegate ke static method service
  // =========================================================

  /// Lihat [LocationService.haversineDistanceInMeters].
  static double haversineDistanceInMeters({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) {
    return LocationService.haversineDistanceInMeters(
      lat1: lat1,
      lng1: lng1,
      lat2: lat2,
      lng2: lng2,
    );
  }

  /// Lihat [LocationService.distanceTo].
  static double distanceTo(
    UserLocation from,
    double targetLat,
    double targetLng,
  ) {
    return LocationService.distanceTo(from, targetLat, targetLng);
  }
}

/// Singleton instance — sama pola dengan `cooperativeRepository`,
/// `discussionRoomRepository`, dll.
final locationRepository = LocationRepository();
