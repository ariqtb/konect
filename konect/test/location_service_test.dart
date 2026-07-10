// Unit test untuk [LocationService.haversineDistanceInMeters].
//
// Formula harus identik dengan fungsi SQL `haversine_distance()` di
// `database/001_init_schema.sql` (Earth radius 6371000m).
//
// Reference values diambil dari kalkulator haversine online untuk
// memastikan formula Dart cocok dengan SQL.

import 'package:flutter_test/flutter_test.dart';
import 'package:konect/data/services/location_service.dart';

void main() {
  group('LocationService.haversineDistanceInMeters', () {
    test('identik (jarak 0)', () {
      final d = LocationService.haversineDistanceInMeters(
        lat1: -6.2088, lng1: 106.8456,
        lat2: -6.2088, lng2: 106.8456,
      );
      expect(d, closeTo(0.0, 0.01));
    });

    test('1 derajat lintang di equator ≈ 111.195 m', () {
      final d = LocationService.haversineDistanceInMeters(
        lat1: 0.0, lng1: 0.0,
        lat2: 1.0, lng2: 0.0,
      );
      expect(d, closeTo(111195.0, 5.0));
    });

    test('1 derajat bujur di equator ≈ 111.195 m', () {
      final d = LocationService.haversineDistanceInMeters(
        lat1: 0.0, lng1: 0.0,
        lat2: 0.0, lng2: 1.0,
      );
      expect(d, closeTo(111195.0, 5.0));
    });

    test('Jakarta → Bandung ≈ 115 km (sanity check)', () {
      // Jakarta: -6.2088, 106.8456
      // Bandung: -6.9175, 107.6191
      final d = LocationService.haversineDistanceInMeters(
        lat1: -6.2088, lng1: 106.8456,
        lat2: -6.9175, lng2: 107.6191,
      );
      // Real distance sekitar 115.6 km. Toleransi 1 km karena presisi.
      expect(d, closeTo(115600.0, 1000.0));
    });

    test('simetris: A→B == B→A', () {
      final ab = LocationService.haversineDistanceInMeters(
        lat1: -7.0, lng1: 107.0,
        lat2: -6.0, lng2: 106.0,
      );
      final ba = LocationService.haversineDistanceInMeters(
        lat1: -6.0, lng1: 106.0,
        lat2: -7.0, lng2: 107.0,
      );
      expect(ab, closeTo(ba, 0.001));
    });

    test('radius koperasi 200m dipakai sebagai threshold (user di dalam)', () {
      // Koperasi di (-6.2000, 106.8000), user 150m di utara
      // 0.00135 derajat lintang ≈ 150m
      final d = LocationService.haversineDistanceInMeters(
        lat1: -6.2000, lng1: 106.8000,
        lat2: -6.19865, lng2: 106.8000,
      );
      expect(d, lessThan(200));
      expect(d, greaterThan(100));
    });
  });
}
