import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../models/user.dart';

class AuthRepository {
  final _supabase = sp.Supabase.instance.client;
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
    try {
      final session = _supabase.auth.currentSession;
      
      // Jika tidak ada sesi, lakukan Auto-Register (Anonymous Login)
      if (session == null) {
        final authRes = await _supabase.auth.signInAnonymously();
        if (authRes.user != null) {
          return await _ensureUserRecordExists(authRes.user!.id);
        }
        return null;
      }
      
      // Jika sudah ada sesi, ambil data user dari database
      return await _ensureUserRecordExists(session.user.id);
    } catch (e) {
      // Fallback ke mock user jika error (misal anon login belum diaktifkan di dashboard)
      return User(
        id: '1',
        name: 'Guest Warga (Mock)',
        email: 'guest@konect.id',
        role: 'warga',
        createdAt: DateTime.now(),
      );
    }
  }

  Future<User> _ensureUserRecordExists(String authId) async {
    // Coba ambil dari tabel users (schema 001)
    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('id', authId)
          .maybeSingle();

      if (data != null) {
        _currentUser = User(
          id: data['id'],
          name: data['full_name'] ?? 'Warga',
          email: data['email'] ?? '',
          role: data['role'] ?? 'warga',
          createdAt: DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
        );
        return _currentUser!;
      }

      // Jika belum ada, auto-register ke tabel users dengan data default
      // Cari village_id dummy
      final villageData = await _supabase.from('villages').select('id').limit(1).maybeSingle();
      final villageId = villageData?['id'];

      if (villageId != null) {
        final uniqueNum = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
        final insertData = {
          'id': authId,
          'village_id': villageId,
          'email': 'anon_$uniqueNum@konect.id',
          'username': 'warga_$uniqueNum',
          'full_name': 'Warga $uniqueNum',
          'password_hash': 'anon',
          'role': 'warga',
          'avatar_color': '#E14242'
        };

        await _supabase.from('users').insert(insertData);

        _currentUser = User(
          id: authId,
          name: insertData['full_name'] as String,
          email: insertData['email'] as String,
          role: insertData['role'] as String,
          createdAt: DateTime.now(),
        );
        return _currentUser!;
      }
    } catch (_) {}

    // Fallback
    _currentUser = User(
      id: authId,
      name: 'Guest Warga',
      email: 'guest@konect.id',
      role: 'warga',
      createdAt: DateTime.now(),
    );
    return _currentUser!;
  }
}

// Singleton instance
final authRepository = AuthRepository();
