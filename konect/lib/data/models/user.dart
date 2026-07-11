class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String role; // 'admin', 'kopdes', 'warga', 'guest'
  final DateTime createdAt;
  // Khusus untuk karyawan koperasi (admin/kopdes)
  final String? koperasiRef;
  final String? karyawanRef;
  final String? jabatan;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.role,
    required this.createdAt,
    this.koperasiRef,
    this.karyawanRef,
    this.jabatan,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatar_url'],
      role: json['role'] ?? 'member',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      koperasiRef: json['koperasi_ref'],
      karyawanRef: json['karyawan_ref'],
      jabatan: json['jabatan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'koperasi_ref': koperasiRef,
      'karyawan_ref': karyawanRef,
      'jabatan': jabatan,
    };
  }

  bool get isAdmin => role == 'admin' || role == 'kopdes';
  bool get isKopdes => role == 'kopdes' || role == 'admin';
}
