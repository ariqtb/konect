import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/discussion_room.dart';

/// Repository untuk entity `discussion_rooms`.
///
/// Menyimpan data ke SharedPreferences (local storage JSON)
/// sebagai solusi sementara sebelum backend Supabase siap.
///
/// Pattern: singleton + bootstrap di main(), mengikuti
/// [PreferencesService] & [AuthRepository].
class DiscussionRoomRepository {
  static const String _storageKey = 'discussion_rooms';

  static DiscussionRoomRepository? _instance;
  static DiscussionRoomRepository get instance =>
      _instance ??= DiscussionRoomRepository._();

  DiscussionRoomRepository._();

  SharedPreferences? _prefs;
  List<DiscussionRoom> _cache = [];

  /// Panggil di main() SETELAH [SharedPreferences.getInstance].
  /// Memuat data dari disk ke memory cache.
  static Future<void> bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final repo = DiscussionRoomRepository._();
    repo._prefs = prefs;
    await repo._loadFromDisk();
    _instance = repo;
  }

  /// Load seluruh rooms dari SharedPreferences ke cache.
  Future<void> _loadFromDisk() async {
    final raw = _prefs!.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      _cache = [];
      return;
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      _cache = decoded
          .map((e) => DiscussionRoom.fromLocalJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Corrupted data: reset
      _cache = [];
      await _prefs!.remove(_storageKey);
    }
  }

  /// Simpan cache ke SharedPreferences.
  Future<void> _persist() async {
    final encoded = jsonEncode(_cache.map((r) => r.toLocalJson()).toList());
    await _prefs!.setString(_storageKey, encoded);
  }

  // ============================================================
  // PUBLIC API
  // ============================================================

  /// Buat room diskusi baru.
  ///
  /// Parameter sesuai kolom NOT NULL + opsional di schema:
  ///   - [cooperativeId] : FK ke cooperatives.id (wajib)
  ///   - [createdBy]     : FK ke users.id (wajib, user yang login)
  ///   - [title]         : judul room (wajib, max 255 char)
  ///   - [description]   : deskripsi (opsional)
  ///   - [isAnonymous]   : izinkan post anonim di room ini (default false)
  Future<DiscussionRoom> createRoom({
    required String cooperativeId,
    required String createdBy,
    required String title,
    String? description,
    bool isAnonymous = false,
  }) async {
    // Simulasi network delay kecil
    await Future.delayed(const Duration(milliseconds: 200));

    final now = DateTime.now();
    final room = DiscussionRoom(
      // ID unik berbasis timestamp + random, karena belum pakai UUID DB
      id: 'room_${now.microsecondsSinceEpoch}_${_cache.length}',
      cooperativeId: cooperativeId,
      createdBy: createdBy,
      title: title,
      description: description,
      isActive: true,
      isAnonymous: isAnonymous,
      createdAt: now,
      updatedAt: now,
    );

    _cache.insert(0, room); // room terbaru di index 0
    await _persist();
    return room;
  }

  /// Ambil semua room milik satu koperasi.
  /// (Untuk halaman "list room" di cooperative detail page)
  Future<List<DiscussionRoom>> getRoomsByCooperative(
    String cooperativeId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(
      _cache.where((r) => r.cooperativeId == cooperativeId),
    );
  }

  /// Ambil satu room berdasarkan id.
  /// Return null jika tidak ditemukan.
  Future<DiscussionRoom?> getRoomById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _cache.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Ambil semua room (untuk admin/debug).
  Future<List<DiscussionRoom>> getAllRooms() async {
    return List.unmodifiable(_cache);
  }

  /// Hapus room (soft: set isActive = false).
  /// Hard delete tersedia via [deleteRoomPermanent].
  Future<bool> deactivateRoom(String id) async {
    final index = _cache.indexWhere((r) => r.id == id);
    if (index == -1) return false;

    final updated =
        _cache[index].copyWith(isActive: false, updatedAt: DateTime.now());
    _cache[index] = updated;
    await _persist();
    return true;
  }

  /// Hapus permanent dari local storage.
  Future<bool> deleteRoomPermanent(String id) async {
    final before = _cache.length;
    _cache.removeWhere((r) => r.id == id);
    if (_cache.length == before) return false;
    await _persist();
    return true;
  }

  /// Hapus semua data (untuk testing/reset).
  Future<void> clearAll() async {
    _cache.clear();
    await _prefs!.remove(_storageKey);
  }
}

// Singleton instance — mengikuti pattern authRepository, cooperativeRepository
final discussionRoomRepository = DiscussionRoomRepository.instance;
