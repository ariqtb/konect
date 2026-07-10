import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/models/user_location.dart';
import '../../../data/repositories/location_repository.dart';
import '../../../data/services/location_service.dart';
import 'package:flutter/foundation.dart';

// =============================================================
// EVENTS
// =============================================================

abstract class LocationEvent extends Equatable {
  const LocationEvent();
  @override
  List<Object?> get props => [];
}

/// Pertama kali BLoC dibuild: cek izin + service. Tidak minta izin,
/// cuma status. UI decides mau minta atau tidak.
class LocationInitialized extends LocationEvent {
  const LocationInitialized();
}

/// User tap tombol "Izinkan Lokasi" di UI. Minta izin, lalu kalau granted
/// otomatis lanjut first-fix + start tracking.
class LocationPermissionRequested extends LocationEvent {
  const LocationPermissionRequested();
}

/// User dari `deniedForever` state tap "Buka Settings".
/// Setelah user balik dari Settings, dispatch [LocationInitialized]
/// lagi untuk re-check.
class LocationOpenAppSettings extends LocationEvent {
  const LocationOpenAppSettings();
}

/// User dari `serviceDisabled` state tap "Aktifkan GPS". Android only;
/// di iOS akan no-op + emit error.
class LocationOpenLocationSettings extends LocationEvent {
  const LocationOpenLocationSettings();
}

/// Ambil posisi satu kali (one-shot). Dipakai saat user buka halaman
/// koperasi / room dan butuh lokasi sekarang tanpa subscribe stream.
class LocationFetchRequested extends LocationEvent {
  const LocationFetchRequested();
}

/// Mulai listening realtime stream. Pastikan permission granted dulu
/// (emit error kalau belum).
class LocationTrackingStarted extends LocationEvent {
  final LocationStreamConfig config;
  const LocationTrackingStarted({this.config = const LocationStreamConfig()});
  @override
  List<Object?> get props => [config];
}

/// Stop listening realtime stream.
class LocationTrackingStopped extends LocationEvent {
  const LocationTrackingStopped();
}

/// Internal: dipanggil tiap [UserLocation] masuk dari stream.
/// BLoC listen repository.positionStream → dispatch event ini.
class _LocationPositionReceived extends LocationEvent {
  final UserLocation position;
  const _LocationPositionReceived(this.position);
  @override
  List<Object?> get props => [position];
}

/// Internal: error dari stream.
class _LocationStreamError extends LocationEvent {
  final Object error;
  const _LocationStreamError(this.error);
  @override
  List<Object?> get props => [error];
}

/// Reset ke initial state. Dipakai setelah user logout / ganti akun.
class LocationReset extends LocationEvent {
  const LocationReset();
}

// =============================================================
// STATES
// =============================================================

abstract class LocationState extends Equatable {
  const LocationState();

  /// Shortcut: posisi terakhir yang kita tahu, dari state apapun.
  UserLocation? get currentLocation;

  @override
  List<Object?> get props => [];
}

/// Pertama kali BLoC aktif, belum cek apa-apa.
class LocationInitial extends LocationState {
  const LocationInitial();
  @override
  UserLocation? get currentLocation => null;
}

/// Sedang cek izin + service (loading, biasanya < 1 detik).
class LocationChecking extends LocationState {
  const LocationChecking();
  @override
  UserLocation? get currentLocation => null;
}

/// Izin granted dan posisi sudah didapat. Bisa tracking atau tidak —
/// lihat [isTracking]. UI aman pakai [currentLocation].
class LocationReady extends LocationState {
  final UserLocation location;
  final bool isTracking;
  final LocationStreamConfig? activeConfig;

  const LocationReady({
    required this.location,
    this.isTracking = false,
    this.activeConfig,
  });

  LocationReady copyWith({
    UserLocation? location,
    bool? isTracking,
    LocationStreamConfig? activeConfig,
  }) {
    return LocationReady(
      location: location ?? this.location,
      isTracking: isTracking ?? this.isTracking,
      activeConfig: activeConfig ?? this.activeConfig,
    );
  }

  @override
  UserLocation? get currentLocation => location;

  @override
  List<Object?> get props => [location, isTracking, activeConfig];
}

/// Izin ditolak (tapi tidak forever). UI: tampilkan tombol "Coba lagi".
class LocationPermissionDenied extends LocationState {
  final UserLocation? lastKnown;
  const LocationPermissionDenied({this.lastKnown});
  @override
  UserLocation? get currentLocation => lastKnown;
  @override
  List<Object?> get props => [lastKnown];
}

/// User pernah tap "Jangan Tanya Lagi". UI: tampilkan tombol
/// "Buka Settings" (satu-satunya cara).
class LocationPermissionPermanentlyDenied extends LocationState {
  final UserLocation? lastKnown;
  const LocationPermissionPermanentlyDenied({this.lastKnown});
  @override
  UserLocation? get currentLocation => lastKnown;
  @override
  List<Object?> get props => [lastKnown];
}

/// GPS nonaktif di device (beda dengan izin ditolak).
/// UI: tampilkan "Aktifkan GPS" (Android) atau "Buka Settings" (iOS).
class LocationServiceDisabled extends LocationState {
  final UserLocation? lastKnown;
  const LocationServiceDisabled({this.lastKnown});
  @override
  UserLocation? get currentLocation => lastKnown;
  @override
  List<Object?> get props => [lastKnown];
}

/// Error umum (network timeout, OS error, dll). UI: tampilkan retry.
class LocationError extends LocationState {
  final String message;
  final UserLocation? lastKnown;
  const LocationError({required this.message, this.lastKnown});
  @override
  UserLocation? get currentLocation => lastKnown;
  @override
  List<Object?> get props => [message, lastKnown];
}

// =============================================================
// BLOC
// =============================================================

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepository _repo;
  StreamSubscription<UserLocation>? _positionSub;
  StreamSubscription<Object>? _errorSub;

  LocationBloc({LocationRepository? repository})
      : _repo = repository ?? locationRepository,
        super(const LocationInitial()) {
    on<LocationInitialized>(_onInitialized);
    on<LocationPermissionRequested>(_onPermissionRequested);
    on<LocationOpenAppSettings>(_onOpenAppSettings);
    on<LocationOpenLocationSettings>(_onOpenLocationSettings);
    on<LocationFetchRequested>(_onFetchRequested);
    on<LocationTrackingStarted>(_onTrackingStarted);
    on<LocationTrackingStopped>(_onTrackingStopped);
    on<LocationReset>(_onReset);
    on<_LocationPositionReceived>(_onPositionReceived);
    on<_LocationStreamError>(_onStreamError);
  }

  // =========================================================
  // HANDLERS
  // =========================================================

  Future<void> _onInitialized(
    LocationInitialized event,
    Emitter<LocationState> emit,
  ) async {
    debugPrint('[LocationBloc] _onInitialized START');
    emit(const LocationChecking());
    try {
      final serviceEnabled = await _repo.isServiceEnabled();
      debugPrint('[LocationBloc] isServiceEnabled -> $serviceEnabled');
      if (!serviceEnabled) {
        emit(LocationServiceDisabled(lastKnown: _repo.lastKnown));
        return;
      }

      final perm = await _repo.checkPermission();
      debugPrint('[LocationBloc] checkPermission -> $perm');
      switch (perm) {
        case LocationPermissionStatus.granted:
          // startTracking: true supaya stream auto-start di cold-start juga
          // (sebelumnya false → user harus buka sheet & tap Izinkan dulu
          // untuk aktivasi stream; sekarang kalau izin sudah granted dari
          // sesi sebelumnya, stream langsung jalan + emit setiap 50m).
          await _fetchAndEmitReady(emit, startTracking: true);
        case LocationPermissionStatus.denied:
          emit(LocationPermissionDenied(lastKnown: _repo.lastKnown));
        case LocationPermissionStatus.deniedForever:
          emit(LocationPermissionPermanentlyDenied(
            lastKnown: _repo.lastKnown,
          ));
        case LocationPermissionStatus.restricted:
        case LocationPermissionStatus.notDetermined:
          // restricted = parental control; treat as permanent denied.
          // notDetermined = edge case (web), treat as denied.
          emit(LocationPermissionDenied(lastKnown: _repo.lastKnown));
        case LocationPermissionStatus.serviceDisabled:
          emit(LocationServiceDisabled(lastKnown: _repo.lastKnown));
      }
    } catch (e) {
      emit(LocationError(message: e.toString(), lastKnown: _repo.lastKnown));
    }
  }

  Future<void> _onPermissionRequested(
    LocationPermissionRequested event,
    Emitter<LocationState> emit,
  ) async {
    debugPrint('[LocationBloc] _onPermissionRequested START');
    emit(const LocationChecking());
    try {
      final perm = await _repo.requestPermission();
      debugPrint('[LocationBloc] requestPermission result -> $perm');
      switch (perm) {
        case LocationPermissionStatus.granted:
          await _fetchAndEmitReady(emit, startTracking: true);
        case LocationPermissionStatus.denied:
          emit(LocationPermissionDenied(lastKnown: _repo.lastKnown));
        case LocationPermissionStatus.deniedForever:
          emit(LocationPermissionPermanentlyDenied(
            lastKnown: _repo.lastKnown,
          ));
        case LocationPermissionStatus.serviceDisabled:
          emit(LocationServiceDisabled(lastKnown: _repo.lastKnown));
        case LocationPermissionStatus.restricted:
        case LocationPermissionStatus.notDetermined:
          emit(LocationPermissionDenied(lastKnown: _repo.lastKnown));
      }
    } on LocationServiceException catch (e) {
      // Biasanya: GPS nonaktif.
      debugPrint('[LocationBloc] _onPermissionRequested LocationServiceException -> ${e.message}');
      emit(LocationError(message: e.message, lastKnown: _repo.lastKnown));
    } catch (e) {
      debugPrint('[LocationBloc] _onPermissionRequested ERROR -> $e');
      emit(LocationError(message: e.toString(), lastKnown: _repo.lastKnown));
    }
  }

  Future<void> _onOpenAppSettings(
    LocationOpenAppSettings event,
    Emitter<LocationState> emit,
  ) async {
    await _repo.openAppSettings();
    // Setelah user balik, re-init.
    add(const LocationInitialized());
  }

  Future<void> _onOpenLocationSettings(
    LocationOpenLocationSettings event,
    Emitter<LocationState> emit,
  ) async {
    final opened = await _repo.openLocationSettings();
    if (opened) {
      add(const LocationInitialized());
    } else {
      // iOS: tidak ada deep-link ke location settings. Fallback ke app settings.
      add(const LocationOpenAppSettings());
    }
  }

  Future<void> _onFetchRequested(
    LocationFetchRequested event,
    Emitter<LocationState> emit,
  ) async {
    if (state is! LocationReady) {
      // Tidak bisa fetch tanpa izin. Trigger init ulang.
      add(const LocationInitialized());
      return;
    }
    try {
      final pos = await _repo.getCurrentPosition();
      emit((state as LocationReady).copyWith(location: pos));
    } catch (e) {
      emit(LocationError(message: e.toString(), lastKnown: _repo.lastKnown));
    }
  }

  Future<void> _onTrackingStarted(
    LocationTrackingStarted event,
    Emitter<LocationState> emit,
  ) async {
    if (state is! LocationReady) {
      add(const LocationInitialized());
      return;
    }
    try {
      // Subscribe ke stream DULU, baru start service, supaya tidak ada
      // event yang terlewat.
      await _positionSub?.cancel();
      _positionSub = _repo.positionStream.listen(
        (pos) => add(_LocationPositionReceived(pos)),
        onError: (Object e) => add(_LocationStreamError(e)),
      );

      await _repo.startTracking(config: event.config);

      emit((state as LocationReady).copyWith(
        isTracking: true,
        activeConfig: event.config,
      ));
    } catch (e) {
      emit(LocationError(message: e.toString(), lastKnown: _repo.lastKnown));
    }
  }

  Future<void> _onTrackingStopped(
    LocationTrackingStopped event,
    Emitter<LocationState> emit,
  ) async {
    await _positionSub?.cancel();
    _positionSub = null;
    await _repo.stopTracking();
    if (state is LocationReady) {
      emit((state as LocationReady).copyWith(
        isTracking: false,
        activeConfig: null,
      ));
    }
  }

  Future<void> _onPositionReceived(
    _LocationPositionReceived event,
    Emitter<LocationState> emit,
  ) async {
    if (state is LocationReady) {
      emit((state as LocationReady).copyWith(location: event.position));
    } else {
      // Belum ready tapi dapat posisi — treat sebagai ready.
      emit(LocationReady(location: event.position, isTracking: true));
    }
  }

  Future<void> _onStreamError(
    _LocationStreamError event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationError(
      message: 'Stream error: ${event.error}',
      lastKnown: _repo.lastKnown,
    ));
  }

  Future<void> _onReset(
    LocationReset event,
    Emitter<LocationState> emit,
  ) async {
    await _positionSub?.cancel();
    _positionSub = null;
    await _errorSub?.cancel();
    _errorSub = null;
    await _repo.stopTracking();
    emit(const LocationInitial());
  }

  // =========================================================
  // HELPERS
  // =========================================================

  /// Dipakai oleh [LocationInitialized] dan [LocationPermissionRequested]
  /// setelah permission granted. Ambil first-fix lalu emit [LocationReady].
  /// Opsional langsung start tracking.
  Future<void> _fetchAndEmitReady(
    Emitter<LocationState> emit, {
    required bool startTracking,
  }) async {
    try {
      // Coba last-known dulu (instant) sebagai fallback kalau getCurrentPosition
      // timeout. Tapi kalau ada, langsung pakai.
      final cached = await _repo.getLastKnownPosition();
      debugPrint('[LocationBloc] _fetchAndEmitReady cached OS position -> ${cached == null ? "null" : "found ${cached.latitude},${cached.longitude}"}');
      if (cached != null) {
        emit(LocationReady(location: cached));
      }

      // Sekarang fix yang sebenarnya.
      final fresh = await _repo.getCurrentPosition();
      debugPrint('[LocationBloc] _fetchAndEmitReady fresh fix -> $fresh');
      emit(LocationReady(location: fresh));

      if (startTracking) {
        debugPrint('[LocationBloc] _fetchAndEmitReady dispatching LocationTrackingStarted');
        add(const LocationTrackingStarted());
      }
    } catch (e) {
      debugPrint('[LocationBloc] _fetchAndEmitReady ERROR -> $e');
      // Kalau dapat cached tapi gagal get current, tetap ready dengan cached.
      if (_repo.lastKnown != null) {
        emit(LocationReady(location: _repo.lastKnown!));
      } else {
        emit(LocationError(
          message: e.toString(),
          lastKnown: _repo.lastKnown,
        ));
      }
    }
  }

  @override
  Future<void> close() async {
    await _positionSub?.cancel();
    await _errorSub?.cancel();
    await _repo.stopTracking();
    return super.close();
  }
}
