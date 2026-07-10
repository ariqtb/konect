import 'package:supabase_flutter/supabase_flutter.dart' as sp;

class RoomRepository {
  final _supabase = sp.Supabase.instance.client;

  Future<Map<String, dynamic>?> getRoomCanvas(String roomIdOrTitle) async {
    try {
      String actualRoomId = roomIdOrTitle;
      
      if (!_isValidUUID(roomIdOrTitle)) {
        final match = await _supabase
            .from('discussion_rooms')
            .select('id')
            .ilike('title', roomIdOrTitle.trim())
            .limit(1)
            .maybeSingle();
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
          .select('cooperative_id')
          .eq('id', roomId)
          .maybeSingle();

      if (response != null && response['cooperative_id'] != null) {
        final coopId = response['cooperative_id'];
        final coop = await _supabase
            .from('cooperatives')
            .select('legacy_ref')
            .eq('id', coopId)
            .maybeSingle();

        if (coop != null && coop['legacy_ref'] != null) {
          final legacyRef = coop['legacy_ref'];
          final profile = await _supabase
              .from('profil_koperasi')
              .select('koordinat_dibulatkan')
              .eq('koperasi_ref', legacyRef)
              .maybeSingle();

          if (profile != null && profile['koordinat_dibulatkan'] != null) {
            final coords = profile['koordinat_dibulatkan'].toString().split(',');
            if (coords.length == 2) {
              return {
                'latitude': double.tryParse(coords[0].trim()) ?? 0.0,
                'longitude': double.tryParse(coords[1].trim()) ?? 0.0,
              };
            }
          }
        }
      }
    } catch (_) {}
    return {'latitude': -6.200000, 'longitude': 106.816666};
  }

  Future<bool> addOpinion({
    required String roomId,
    required String userId,
    required String content,
  }) async {
    try {
      final coords = await _getRoomCoopCoordinates(roomId);
      await _supabase.from('opinions').insert({
        'room_id': roomId,
        'user_id': userId,
        'content': content,
        'is_anonymous': false,
        'latitude': coords['latitude'],
        'longitude': coords['longitude'],
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> addComment({
    required String opinionId,
    required String userId,
    required String content,
  }) async {
    try {
      final op = await _supabase
          .from('opinions')
          .select('room_id')
          .eq('id', opinionId)
          .maybeSingle();
      
      final String? roomId = op?['room_id'];
      final coords = roomId != null
          ? await _getRoomCoopCoordinates(roomId)
          : {'latitude': -6.200000, 'longitude': 106.816666};

      await _supabase.from('discussion_comments').insert({
        'opinion_id': opinionId,
        'user_id': userId,
        'content': content,
        'is_anonymous': false,
        'latitude': coords['latitude'],
        'longitude': coords['longitude'],
      });
      return true;
    } catch (_) {
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

  Future<String?> createRoom({
    required String coopRef,
    required String title,
    required String description,
    required String createdBy,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      var coop = await _supabase
          .from('cooperatives')
          .select('id')
          .eq('legacy_ref', coopRef)
          .maybeSingle();

      String coopId;
      if (coop == null) {
        final village = await _supabase.from('villages').select('id').limit(1).maybeSingle();
        final String villageId = village?['id'] ?? '00000000-0000-0000-0000-000000000001';
        
        final newCoop = await _supabase.from('cooperatives').insert({
          'legacy_ref': coopRef,
          'village_id': villageId,
          'name': 'Koperasi Stub',
          'slug': 'coop-stub-${DateTime.now().millisecondsSinceEpoch}',
        }).select('id').single();
        coopId = newCoop['id'];
      } else {
        coopId = coop['id'];
      }

      final response = await _supabase.from('discussion_rooms').insert({
        'cooperative_id': coopId,
        'created_by': createdBy,
        'title': title,
        'description': description,
        'is_active': true,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      }).select('id').single();

      final String roomId = response['id'];

      await _supabase.from('room_participants').insert({
        'room_id': roomId,
        'user_id': createdBy,
        'role': 'host',
      });

      return roomId;
    } catch (e) {
      return null;
    }
  }
}

final roomRepository = RoomRepository();
