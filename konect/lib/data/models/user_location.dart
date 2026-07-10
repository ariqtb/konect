import 'package:equatable/equatable.dart';

/// Representasi posisi geografis user pada satu titik waktu.
///
/// Immutable. Dipakai oleh [LocationBloc] sebagai stream output dan
/// sebagai input untuk repository koperasi / room yang akan menghitung
/// jarak via [haversineDistanceInMeters].
class UserLocation extends Equatable {
  /// Lintang (latitude) dalam derajat desimal, range -90.0 .. 90.0.
  final double latitude;

  /// Bujur (longitude) dalam derajat desimal, range -180.0 .. 180.0.
  final double longitude;

  /// Akurasi horizontal dalam meter (semakin kecil semakin akurat).
  /// Null bila device tidak menyediakan (mis. simulator tanpa mock).
  final double? accuracy;

  /// Ketinggian dalam meter di atas permukaan laut. Null bila tidak tersedia.
  final double? altitude;

  /// Heading/arah hadap user dalam derajat (0-360, 0 = utara). Null jika diam.
  final double? heading;

  /// Kecepatan gerak dalam m/s. Null jika diam.
  final double? speed;

  /// Waktu pengukuran posisi (UTC).
  final DateTime timestamp;

  const UserLocation({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracy,
    this.altitude,
    this.heading,
    this.speed,
  });

  /// Cek apakah koordinat berada dalam range geografis yang valid.
  bool get isValid =>
      latitude >= -90.0 &&
      latitude <= 90.0 &&
      longitude >= -180.0 &&
      longitude <= 180.0;

  /// Salin dengan field yang di-override (untuk update real-time dari stream).
  UserLocation copyWith({
    double? latitude,
    double? longitude,
    double? accuracy,
    double? altitude,
    double? heading,
    double? speed,
    DateTime? timestamp,
  }) {
    return UserLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      heading: heading ?? this.heading,
      speed: speed ?? this.speed,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Serialisasi untuk dikirim ke Supabase sebagai payload insert
  /// (mis. ke `opinions.latitude` / `opinions.longitude`).
  Map<String, dynamic> toSupabase() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Serialisasi lengkap (latitude, longitude, accuracy, timestamp)
  /// untuk SharedPreferences cache — supaya saat cold-start, UI bisa
  /// langsung menampilkan posisi terakhir sebelum GPS fix baru masuk.
  ///
  /// Berbeda dengan [toSupabase]: ini menyimpan metadata lokal (accuracy,
  /// timestamp) yang tidak perlu dikirim ke backend.
  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'timestamp': timestamp.toIso8601String(),
      };

  /// Factory dari [toJson]. Return null-safety untuk field optional
  /// (accuracy bisa null di simulator tanpa mock location).
  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// String human-readable untuk log / debug. JANGAN dipakai di UI.
  @override
  String toString() =>
      'UserLocation(lat: $latitude, lng: $longitude, '
      'acc: ${accuracy ?? "?"}m, at: $timestamp)';

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        accuracy,
        altitude,
        heading,
        speed,
        timestamp,
      ];
}
