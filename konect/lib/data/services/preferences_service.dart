import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import '../models/user_location.dart';

/// Wrapper tipis di atas [SharedPreferences] khusus untuk flag-flag
/// yang terkait dengan permission UX.
///
/// Pakai Singleton pattern supaya tidak perlu-pass-pass ke semua widget.
/// Init di `main()` sebelum runApp (lihat [bootstrap]).
class PreferencesService {
  static const _kLocationPromptDismissedAt = 'location_prompt_dismissed_at';
  static const _kLocationOnboardingShown = 'location_onboarding_shown';

  /// Key untuk cache koordinat terakhir user. Disimpan sebagai JSON string
  /// (lihat [UserLocation.toJson]). Tujuan: cold-start bisa langsung
  /// menampilkan posisi sebelum GPS fix baru masuk (~1-3 detik di outdoor).
  static const _kLastLocation = 'last_known_location';

  // Throttle: setelah user pilih "Nanti", jangan tanya lagi selama 24 jam.
  static const Duration _dismissThrottle = Duration(hours: 24);

  static PreferencesService? _instance;
  static PreferencesService get instance =>
      _instance ??= PreferencesService._();

  // In-memory cache supaya tidak hit SharedPreferences tiap kali.
  DateTime? _cachedDismissedAt;
  bool? _cachedOnboardingShown;
  UserLocation? _cachedLastLocation;

  PreferencesService._();

  /// Panggil di main() SEBELUM runApp.
  /// [SharedPreferences.getInstance] itu async dan relatif lambat (~100ms
  /// di cold start), jadi preload di sini.
  static Future<void> bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final instance = PreferencesService._();
    instance._prefs = prefs;
    instance._cachedDismissedAt = prefs.getString(_kLocationPromptDismissedAt) != null
        ? DateTime.tryParse(prefs.getString(_kLocationPromptDismissedAt)!)
        : null;
    instance._cachedOnboardingShown =
        prefs.getBool(_kLocationOnboardingShown) ?? false;
    instance._cachedLastLocation = _parseLastLocation(
      prefs.getString(_kLastLocation),
    );
    _instance = instance;
  }

  late final SharedPreferences _prefs;

  // ============================================================
  // LOCATION ONBOARDING PROMPT
  // ============================================================

  /// Apakah user sudah pernah melihat onboarding sheet lokasi?
  bool get hasShownLocationOnboarding =>
      _cachedOnboardingShown ?? false;

  Future<void> markLocationOnboardingShown() async {
    _cachedOnboardingShown = true;
    await _prefs.setBool(_kLocationOnboardingShown, true);
  }

  /// True kalau user baru dismiss "Nanti" < 24 jam lalu.
  /// False kalau belum pernah dismiss, atau sudah > 24 jam.
  bool get isLocationPromptDismissedRecently {
    final at = _cachedDismissedAt;
    if (at == null) return false;
    return DateTime.now().difference(at) < _dismissThrottle;
  }

  Future<void> markLocationPromptDismissed() async {
    final now = DateTime.now();
    _cachedDismissedAt = now;
    await _prefs.setString(
      _kLocationPromptDismissedAt,
      now.toIso8601String(),
    );
  }

  // ============================================================
  // LAST KNOWN LOCATION CACHE
  // ============================================================

  /// Posisi terakhir yang tersimpan di SharedPreferences. Null kalau
  /// belum pernah ada (first launch, atau setelah clearLocationFlags).
  ///
  /// Dipakai oleh [LocationRepository] di constructor untuk hydrate
  /// in-memory `_lastKnown` sebelum GPS fix pertama masuk, sehingga UI
  /// tidak flash kosong di cold-start.
  UserLocation? get lastLocation => _cachedLastLocation;

  /// Simpan koordinat user ke SharedPreferences. Dipanggil tiap kali
  /// [LocationRepository._lastKnown] berubah (one-shot atau stream emit).
  Future<void> saveLastLocation(UserLocation loc) async {
    _cachedLastLocation = loc;
    await _prefs.setString(
      _kLastLocation,
      jsonEncode(loc.toJson()),
    );
    debugPrint('[PreferencesService] lastLocation persisted -> $loc');
  }

  /// Hapus cache koordinat (untuk testing atau setelah user reset).
  Future<void> clearLastLocation() async {
    _cachedLastLocation = null;
    await _prefs.remove(_kLastLocation);
  }

  /// Parse JSON string dari SharedPreferences menjadi [UserLocation].
  /// Return null kalau data kosong, corrupt, atau field wajib hilang.
  /// Robust terhadap data lama (schema migration aman).
  static UserLocation? _parseLastLocation(String? raw) {
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return UserLocation.fromJson(decoded);
    } catch (e) {
      debugPrint('[PreferencesService] _parseLastLocation corrupt data: $e');
      return null;
    }
  }

  /// Reset semua flag (untuk testing atau setelah user grant izin supaya
  /// banner tidak muncul lagi). Termasuk last location cache.
  Future<void> clearLocationFlags() async {
    _cachedDismissedAt = null;
    _cachedOnboardingShown = false;
    _cachedLastLocation = null;
    await _prefs.remove(_kLocationPromptDismissedAt);
    await _prefs.remove(_kLocationOnboardingShown);
    await _prefs.remove(_kLastLocation);
  }
}
