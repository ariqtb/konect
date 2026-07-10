import '../models/cooperative.dart';
import '../models/cooperative_detail.dart';
import '../../core/services/supabase_service.dart';

class CooperativeRepository {
  Future<List<CooperativeItem>> getCooperatives({int page = 0, int limit = 10}) async {
    try {
      final from = page * limit;
      final to = from + limit - 1;
      
      final response = await SupabaseService().client.from('profil_koperasi').select().range(from, to);
      
      return (response as List<dynamic>).map((data) {
        return CooperativeItem(
          id: data['koperasi_ref']?.toString() ?? '',
          name: data['nama_koperasi']?.toString() ?? 'Koperasi Tanpa Nama',
          category: data['kategori_usaha']?.toString() ?? 'Umum',
          isOpen: data['status_registrasi'] == 'Approved',
          address: data['alamat_lengkap']?.toString() ?? 'Alamat tidak tersedia',
          distance: 'Koperasi Terdekat',
          imageUrl: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(data['nama_koperasi']?.toString() ?? 'K')}&background=random',
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch cooperatives: $e');
    }
  }

  Future<CooperativeDetail> getCooperativeDetail(String id) async {
    try {
      final client = SupabaseService().client;
      final response = await client.rpc(
        'get_cooperative_detail',
        params: {'p_coop_ref': id},
      );
      
      if (response == null) {
        throw Exception('Koperasi tidak ditemukan');
      }

      return CooperativeDetail.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      throw Exception('Failed to fetch cooperative details: $e');
    }
  }

  Future<String> getAdminCooperative(String userId) async {
    try {
      final client = SupabaseService().client;
      final member = await client
          .from('cooperative_members')
          .select('cooperative_id')
          .eq('user_id', userId)
          .maybeSingle();
      if (member != null && member['cooperative_id'] != null) {
        return member['cooperative_id'];
      }

      final room = await client
          .from('discussion_rooms')
          .select('cooperative_id')
          .eq('created_by', userId)
          .limit(1)
          .maybeSingle();
      if (room != null && room['cooperative_id'] != null) {
        return room['cooperative_id'];
      }

      final coop = await client.from('cooperatives').select('id').limit(1).maybeSingle();
      if (coop != null && coop['id'] != null) {
        return coop['id'];
      }
    } catch (_) {}
    return '00000000-0000-0000-0000-0000000000a1';
  }

  Future<bool> createArticle({
    required String cooperativeId,
    required String title,
    required String content,
    required String createdBy,
  }) async {
    try {
      final client = SupabaseService().client;
      await client.from('articles').insert({
        'cooperative_id': cooperativeId,
        'title': title,
        'content': content,
        'created_by': createdBy,
      });
      return true;
    } catch (_) {
      return false;
    }
  }
}

final cooperativeRepository = CooperativeRepository();
