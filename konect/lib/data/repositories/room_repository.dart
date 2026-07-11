import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;

class RoomRepository {
  final _supabase = sp.Supabase.instance.client;

  Future<Map<String, dynamic>?> getRoomCanvas(String roomIdOrTitle) async {
    try {
      String actualRoomId = roomIdOrTitle;
      
      if (!_isValidUUID(roomIdOrTitle)) {
        // Coba cari berdasarkan code terlebih dahulu (case-insensitive)
        var match = await _supabase
            .from('discussion_rooms')
            .select('id')
            .eq('code', roomIdOrTitle.trim().toUpperCase())
            .limit(1)
            .maybeSingle();

        if (match == null) {
          match = await _supabase
              .from('discussion_rooms')
              .select('id')
              .ilike('title', roomIdOrTitle.trim())
              .limit(1)
              .maybeSingle();
        }

        if (match != null && match['id'] != null) {
          actualRoomId = match['id'];
        } else {
          return null;
        }
      }

      final response = await _supabase.rpc(
        'get_room_canvas',
        params: {'p_room_id': actualRoomId},
      );
      if (response != null) {
        return response as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  bool _isValidUUID(String str) {
    final RegExp uuidRegExp = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidRegExp.hasMatch(str);
  }

  Future<void> joinRoom(String roomId, String userId) async {
    try {
      await _supabase.from('room_participants').upsert({
        'room_id': roomId,
        'user_id': userId,
      });
    } catch (_) {
      // Graceful error handling (e.g. if room_participants table migration isn't deployed)
    }
  }

  Future<List<Map<String, dynamic>>> getJoinedRooms(String userId) async {
    try {
      final response = await _supabase
          .from('room_participants')
          .select('joined_at, discussion_rooms(id, title, description, created_at, updated_at, is_active, start_date, end_date)')
          .eq('user_id', userId)
          .order('joined_at', ascending: false);

      final List<Map<String, dynamic>> rooms = [];
      for (final item in (response as List)) {
        final room = item['discussion_rooms'];
        if (room != null) {
          rooms.add({
            'id': room['id']?.toString() ?? '',
            'title': room['title']?.toString() ?? 'Rapat Tanpa Judul',
            'time': item['joined_at']?.toString() ?? '',
            'description': room['description']?.toString() ?? '',
            'createdAt': room['created_at']?.toString() ?? '',
            'updatedAt': room['updated_at']?.toString() ?? '',
            'isActive': room['is_active'] ?? true,
            'startDate': room['start_date']?.toString() ?? '',
            'endDate': room['end_date']?.toString() ?? '',
          });
        }
      }
      return rooms;
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, double>> _getRoomCoopCoordinates(String roomId) async {
    try {
      final response = await _supabase
          .from('discussion_rooms')
          .select('koperasi_ref')
          .eq('id', roomId)
          .maybeSingle();

      if (response != null && response['koperasi_ref'] != null) {
        final coopRef = response['koperasi_ref'];
        final profile = await _supabase
            .from('profil_koperasi')
            .select('latitude, longitude')
            .eq('koperasi_ref', coopRef)
            .maybeSingle();

        if (profile != null) {
          final double lat = (profile['latitude'] as num?)?.toDouble() ?? -6.200000;
          final double lng = (profile['longitude'] as num?)?.toDouble() ?? 106.816666;
          return {'latitude': lat, 'longitude': lng};
        }
      }
    } catch (_) {}
    return {'latitude': -6.200000, 'longitude': 106.816666};
  }

  int _uuidToBigInt(String uuid) {
    int hash = 0;
    for (int i = 0; i < uuid.length; i++) {
      hash = (hash * 31 + uuid.codeUnitAt(i)) % 9007199254740991;
    }
    return hash;
  }

  Future<String?> addOpinion({
    required String roomId,
    required String userId,
    required String content,
    double? coordinateX,
    double? coordinateY,
  }) async {
    try {
      final bigIntId = _uuidToBigInt(userId);
      final response = await _supabase.from('opinions').insert({
        'room_id': roomId,
        'user_id': bigIntId,
        'content': content,
        'is_anonymous': false,
        'coordinate_x': coordinateX,
        'coordinate_y': coordinateY,
      }).select('id').maybeSingle();
      
      if (response != null && response['id'] != null) {
        return response['id'].toString();
      }
      return null;
    } catch (e, stackTrace) {
      print('[addOpinion] ERROR: $e');
      print('[addOpinion] STACK: $stackTrace');
      return null;
    }
  }

  Future<bool> moderateComment(String content) async {
    try {
      final response = await _supabase.rpc(
        'moderate_comment',
        params: {'content': content},
      );
      return response as bool;
    } catch (e) {
      print('[moderateComment] ERROR: $e');
      return true; // Fallback if offline
    }
  }

  Future<bool> addComment({
    required String opinionId,
    required String userId,
    required String content,
    double? coordinateX,
    double? coordinateY,
  }) async {
    try {
      final bigIntId = _uuidToBigInt(userId);
      await _supabase.from('opinion_comments').insert({
        'opinion_id': opinionId,
        'user_id': bigIntId,
        'content': content,
        'is_anonymous': false,
        'coordinate_x': coordinateX,
        'coordinate_y': coordinateY,
      });
      return true;
    } catch (e, stackTrace) {
      print('[addComment] ERROR: $e');
      print('[addComment] STACK: $stackTrace');
      return false;
    }
  }

  Future<bool> toggleReaction({
    required String targetId,
    required String userId,
    required String targetType,
    required String reaction,
  }) async {
    try {
      await _supabase.from('reactions').upsert({
        'user_id': userId,
        'target_id': targetId,
        'target_type': targetType,
        'reaction': reaction,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  String _generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  Future<String?> createRoom({
    required String coopRef,
    required String title,
    required String description,
    required String createdBy,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      print('[createRoom] coopRef=$coopRef | createdBy=$createdBy | title=$title');
      print('[createRoom] start=${startDate.toUtc().toIso8601String()} | end=${endDate.toUtc().toIso8601String()}');

      final String code = _generateRoomCode();

      // Insert langsung ke discussion_rooms menggunakan koperasi_ref
      final response = await _supabase.from('discussion_rooms').insert({
        'created_by': createdBy,
        'title': title,
        'description': description,
        'code': code,
        'is_active': true,
        'is_anonymous': false,
        'koperasi_ref': coopRef,
        'start_date': startDate.toUtc().toIso8601String(),
        'end_date': endDate.toUtc().toIso8601String(),
      }).select('id').single();

      final String roomId = response['id'];
      print('[createRoom] Berhasil! roomId=$roomId');

      // Daftarkan pembuat sebagai peserta dengan role host
      await _supabase.from('room_participants').insert({
        'room_id': roomId,
        'user_id': createdBy,
        'role': 'host',
      });
      print('[createRoom] Peserta host berhasil didaftarkan');

      return roomId;
    } catch (e, stackTrace) {
      print('[createRoom] ERROR: $e');
      print('[createRoom] StackTrace: $stackTrace');
      return null;
    }
  }
}

final roomRepository = RoomRepository();
