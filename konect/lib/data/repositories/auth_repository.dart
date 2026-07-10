import '../models/user.dart';

class AuthRepository {
  // Placeholder - implementasikan sesuai API
  User? _currentUser;

  Future<User?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = User(
      id: '1',
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
      id: '1',
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
