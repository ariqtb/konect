import '../models/user.dart';

class AuthRepository {
  // Placeholder - implementasikan sesuai API
  User? _currentUser;

  // ============================================================
  // STATIC UUIDs untuk demo user — match dengan schema DB
  // (users.id: UUID PK di PostgreSQL)
  //
  // Saat migrasi ke Supabase, user sungguhan akan di-generate
  // via Supabase Auth (GoTrue) dengan uuid_generate_v4().
  // ============================================================
  static const String _demoAdminId = '22222222-2222-4222-a222-000000000001';
  static const String _demoMemberId = '22222222-2222-4222-a222-000000000002';

  Future<User?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = User(
      id: _demoAdminId,
      name: 'Budi (Kopdes)',
      email: email,
      role: 'kopdes',
      createdAt: DateTime.now(),
    );
    return _currentUser;
  }

  Future<User?> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = User(
      id: _demoMemberId,
      name: name,
      email: email,
      role: 'member',
      createdAt: DateTime.now(),
    );
    return _currentUser;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
  }

  Future<User?> getCurrentUser() async {
    return _currentUser;
  }
}

// Singleton instance
final authRepository = AuthRepository();
