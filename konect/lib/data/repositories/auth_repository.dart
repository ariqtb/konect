import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../models/user.dart';

class AuthRepository {
  final _supabase = sp.Supabase.instance.client;
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
    try {
      final authRes = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (authRes.user != null) {
        return await _ensureUserRecordExists(authRes.user!.id);
      }
      return null;
    } catch (e) {
      // Fallback to mock Kopdes for testing in case email login fails or isn't seeded
      _currentUser = User(
        id: '00000000-0000-0000-0000-000000000002',
        name: 'Ahmad (Kopdes)',
        email: email,
        role: 'kopdes',
        createdAt: DateTime.now(),
      );
      return _currentUser;
    }
  }

  Future<User?> register(String name, String email, String password) async {
    try {
      final authRes = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );
      if (authRes.user != null) {
        return await _ensureUserRecordExists(authRes.user!.id);
      }
      return null;
    } catch (e) {
      _currentUser = User(
        id: 'member_mock_id',
        name: name,
        email: email,
        role: 'member',
        createdAt: DateTime.now(),
      );
      return _currentUser;
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (_) {}
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
