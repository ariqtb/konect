import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../models/user.dart';

class AuthRepository {
  final _supabase = sp.Supabase.instance.client;
  User? _currentUser;

  // ============================================================
  // LOGIN: Cek karyawan_koperasi dulu (admin/kopdes)
  // Jika tidak ditemukan, lanjut ke Supabase Auth (warga)
  // ============================================================
  Future<User?> login(String email, String password) async {
    // 1. Cek tabel karyawan_koperasi terlebih dahulu
    try {
      final karyawanData = await _supabase
          .from('karyawan_koperasi')
          .select('karyawan_ref, koperasi_ref, nama, jabatan, email, password, status_karyawan')
          .eq('email', email.trim())
          .maybeSingle();

      if (karyawanData != null) {
        // Verifikasi password (plaintext di tabel, bandingkan langsung)
        final storedPassword = karyawanData['password'] as String? ?? '';
        if (storedPassword == password) {
          if (karyawanData['status_karyawan'] != 'aktif') {
            throw Exception('Akun karyawan tidak aktif.');
          }

          // Coba ambil UUID asli dari tabel users menggunakan email karyawan
          String userUuid = karyawanData['karyawan_ref'] as String; // fallback
          try {
            final userRow = await _supabase
                .from('users')
                .select('id')
                .eq('email', email.trim())
                .maybeSingle();
            if (userRow != null && userRow['id'] != null) {
              userUuid = userRow['id'] as String;
            }
          } catch (_) {}

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('saved_admin_email', email.trim());

          _currentUser = User(
            id: userUuid,
            name: karyawanData['nama'] as String? ?? 'Admin Koperasi',
            email: email,
            role: 'kopdes',
            createdAt: DateTime.now(),
            karyawanRef: karyawanData['karyawan_ref'] as String?,
            koperasiRef: karyawanData['koperasi_ref'] as String?,
            jabatan: karyawanData['jabatan'] as String?,
          );
          return _currentUser;
        }
        // Email ada tapi password salah
        throw Exception('Password salah.');
      }
    } catch (e) {
      // Jika error bukan dari throw kita sendiri, log dan lanjut ke Supabase Auth
      final msg = e.toString();
      if (msg.contains('Password salah') || msg.contains('tidak aktif')) {
        rethrow;
      }
      // Selain itu abaikan dan coba Supabase Auth
    }

    // 2. Jika bukan karyawan → coba Supabase Auth (untuk warga biasa)
    try {
      final authRes = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (authRes.user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('saved_admin_email');
        return await _ensureUserRecordExists(authRes.user!.id);
      }
      return null;
    } catch (e) {
      throw Exception('Email atau password salah.');
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
        role: 'warga',
        createdAt: DateTime.now(),
      );
      return _currentUser;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_admin_email');
      await _supabase.auth.signOut();
    } catch (_) {}
    _currentUser = null;
  }

  Future<User?> getCurrentUser() async {
    // Jika ada _currentUser di memori (misal baru login sebagai karyawan)
    if (_currentUser != null) return _currentUser;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAdminEmail = prefs.getString('saved_admin_email');
      if (savedAdminEmail != null && savedAdminEmail.isNotEmpty) {
        final karyawanData = await _supabase
            .from('karyawan_koperasi')
            .select('karyawan_ref, koperasi_ref, nama, jabatan, email, status_karyawan, user_uuid')
            .eq('email', savedAdminEmail.trim())
            .maybeSingle();

        if (karyawanData != null && karyawanData['status_karyawan'] == 'aktif') {
          String userUuid = karyawanData['karyawan_ref'] as String;
          if (karyawanData['user_uuid'] != null) {
            userUuid = karyawanData['user_uuid'] as String;
          }

          _currentUser = User(
            id: userUuid,
            name: karyawanData['nama'] as String? ?? 'Admin Koperasi',
            email: savedAdminEmail,
            role: 'kopdes',
            createdAt: DateTime.now(),
            karyawanRef: karyawanData['karyawan_ref'] as String?,
            koperasiRef: karyawanData['koperasi_ref'] as String?,
            jabatan: karyawanData['jabatan'] as String?,
          );
          return _currentUser;
        } else {
          await prefs.remove('saved_admin_email');
        }
      }

      final session = _supabase.auth.currentSession;

      // Jika tidak ada sesi, lakukan Auto-Register (Anonymous Login)
      if (session == null) {
        try {
          final authRes = await _supabase.auth.signInAnonymously();
          if (authRes.user != null) {
            return await _ensureUserRecordExists(authRes.user!.id);
          }
        } catch (e) {
          print('[getCurrentUser] Supabase Anonymous sign-in failed, using local UUID fallback: $e');
          final prefs = await SharedPreferences.getInstance();
          String? localUuid = prefs.getString('local_user_uuid');
          if (localUuid == null) {
            localUuid = const Uuid().v4();
            await prefs.setString('local_user_uuid', localUuid);
          }
          return await _ensureUserRecordExists(localUuid);
        }
        return null;
      }

      // Jika sudah ada sesi, ambil data user dari database
      return await _ensureUserRecordExists(session.user.id);
    } catch (e, stackTrace) {
      print('[getCurrentUser] ERROR: $e');
      print('[getCurrentUser] STACK: $stackTrace');
      
      // Fallback terakhir dengan local UUID
      try {
        final prefs = await SharedPreferences.getInstance();
        String? localUuid = prefs.getString('local_user_uuid');
        if (localUuid == null) {
          localUuid = const Uuid().v4();
          await prefs.setString('local_user_uuid', localUuid);
        }
        return await _ensureUserRecordExists(localUuid);
      } catch (_) {}

      return User(
        id: '1',
        name: 'Guest Warga (Mock)',
        email: 'guest@konect.id',
        role: 'warga',
        createdAt: DateTime.now(),
      );
    }
  }

  int _uuidToBigInt(String uuid) {
    int hash = 0;
    for (int i = 0; i < uuid.length; i++) {
      hash = (hash * 31 + uuid.codeUnitAt(i)) % 9007199254740991;
    }
    return hash;
  }

  Future<User> _ensureUserRecordExists(String authId) async {
    try {
      final bigIntId = _uuidToBigInt(authId);
      final data = await _supabase
          .from('users')
          .select()
          .eq('uuid', bigIntId)
          .maybeSingle();

      if (data != null) {
        _currentUser = User(
          id: authId,
          name: 'Warga $bigIntId',
          email: 'anon_$bigIntId@konect.id',
          role: 'warga',
          createdAt: DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
        );
        return _currentUser!;
      }

      // Jika belum ada, auto-register ke tabel users dengan data default
      final insertData = {
        'uuid': bigIntId,
        'points': 0,
      };

      await _supabase.from('users').insert(insertData);

      _currentUser = User(
        id: authId,
        name: 'Warga $bigIntId',
        email: 'anon_$bigIntId@konect.id',
        role: 'warga',
        createdAt: DateTime.now(),
      );
      return _currentUser!;
    } catch (e, stackTrace) {
      print('[_ensureUserRecordExists] ERROR: $e');
      print('[_ensureUserRecordExists] STACK: $stackTrace');
    }

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
