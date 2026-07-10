import '../models/user.dart';

class AuthRepository {
  // Placeholder - implementasikan sesuai API
  Future<User?> login(String email, String password) async {
    // TODO: API call
    await Future.delayed(const Duration(seconds: 1));
    return null;
  }

  Future<User?> register(String name, String email, String password) async {
    // TODO: API call
    await Future.delayed(const Duration(seconds: 1));
    return null;
  }

  Future<void> logout() async {
    // TODO: Clear storage
  }

  Future<User?> getCurrentUser() async {
    // TODO: Get from storage/API
    return null;
  }
}

// Singleton instance
final authRepository = AuthRepository();
