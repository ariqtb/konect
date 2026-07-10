// Unit test untuk [UserLocation] model — memastikan invariants
// dan serialization yang dipakai oleh repository/DB.

import 'package:flutter_test/flutter_test.dart';
import 'package:konect/data/models/user_location.dart';

void main() {
  group('UserLocation', () {
    final base = UserLocation(
      latitude: -6.2088,
      longitude: 106.8456,
      timestamp: DateTime.utc(2026, 7, 10, 12, 0, 0),
      accuracy: 5.0,
    );

    test('isValid true untuk koordinat dalam range', () {
      expect(base.isValid, isTrue);
    });

    test('isValid false untuk lintang di luar range', () {
      expect(
        base.copyWith(latitude: 91.0).isValid,
        isFalse,
      );
      expect(
        base.copyWith(latitude: -91.0).isValid,
        isFalse,
      );
    });

    test('isValid false untuk bujur di luar range', () {
      expect(
        base.copyWith(longitude: 181.0).isValid,
        isFalse,
      );
      expect(
        base.copyWith(longitude: -181.0).isValid,
        isFalse,
      );
    });

    test('isValid true untuk edge case equator & greenwich', () {
      final equator = base.copyWith(latitude: 0.0, longitude: 0.0);
      expect(equator.isValid, isTrue);
    });

    test('toSupabase() emit key latitude + longitude saja', () {
      // Repository & opinion insertion hanya butuh 2 field ini.
      final json = base.toSupabase();
      expect(json.keys, containsAll(['latitude', 'longitude']));
      expect(json['latitude'], -6.2088);
      expect(json['longitude'], 106.8456);
      // Pastikan tidak ada side data (accuracy, timestamp) yang nyasar.
      expect(json.containsKey('accuracy'), isFalse);
      expect(json.containsKey('timestamp'), isFalse);
    });

    test('copyWith preserves fields yang tidak di-override', () {
      final updated = base.copyWith(latitude: -7.0);
      expect(updated.latitude, -7.0);
      expect(updated.longitude, base.longitude);
      expect(updated.accuracy, base.accuracy);
      expect(updated.timestamp, base.timestamp);
    });

    test('Equatable: dua instance dengan field sama → == ', () {
      final a = UserLocation(
        latitude: 1.0,
        longitude: 2.0,
        timestamp: DateTime.utc(2026, 1, 1),
      );
      final b = UserLocation(
        latitude: 1.0,
        longitude: 2.0,
        timestamp: DateTime.utc(2026, 1, 1),
      );
      expect(a, equals(b));
    });

    // ============================================================
    // JSON serialization (untuk SharedPreferences cache)
    // ============================================================

    test('toJson emit key latitude, longitude, accuracy, timestamp', () {
      final json = base.toJson();
      expect(json.keys, containsAll(['latitude', 'longitude', 'accuracy', 'timestamp']));
      expect(json['latitude'], -6.2088);
      expect(json['longitude'], 106.8456);
      expect(json['accuracy'], 5.0);
      expect(json['timestamp'], isA<String>());
    });

    test('toJson → fromJson round-trip preserves semua field', () {
      final restored = UserLocation.fromJson(base.toJson());
      expect(restored, equals(base));
    });

    test('fromJson handles null accuracy (simulator tanpa mock location)', () {
      // Note: copyWith(accuracy: null) tidak bisa set null karena
      // `null ?? this.accuracy` → this.accuracy. Konstruksi langsung saja.
      final noAcc = UserLocation(
        latitude: base.latitude,
        longitude: base.longitude,
        timestamp: base.timestamp,
        accuracy: null,
      );
      final restored = UserLocation.fromJson(noAcc.toJson());
      expect(restored.accuracy, isNull);
      expect(restored.latitude, base.latitude);
      expect(restored.longitude, base.longitude);
      expect(restored.timestamp, base.timestamp);
    });
  });
}
