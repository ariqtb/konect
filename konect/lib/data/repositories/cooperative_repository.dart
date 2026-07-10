import '../models/cooperative.dart';
import '../models/cooperative_detail.dart';
import '../../core/services/supabase_service.dart';

class CooperativeRepository {
  Future<List<CooperativeItem>> getCooperatives({int page = 0, int limit = 10}) async {
    try {
      final from = page * limit;
      final to = from + limit - 1;
      
      final response = await SupabaseService().client
          .from('gerai_koperasi')
          .select('*, profil_koperasi(*)')
          .range(from, to);
      
      return (response as List<dynamic>).map((data) {
        final profil = data['profil_koperasi'] as Map<String, dynamic>?;
        final name = profil?['nama_koperasi']?.toString() ?? 'Koperasi Tanpa Nama';
        final category = profil?['kategori_usaha']?.toString() ?? 'Umum';
        final address = profil?['alamat_lengkap']?.toString() ?? 'Alamat tidak tersedia';
        
        return CooperativeItem(
          id: data['koperasi_ref']?.toString() ?? '',
          name: name,
          category: category,
          isOpen: data['status_gerai'] == 'Aktif',
          address: address,
          distance: 'Gerai Koperasi',
          imageUrl: data['foto_gerai']?.toString() ?? 
              'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random',
          latitude: (data['latitude'] as num?)?.toDouble(),
          longitude: (data['longitude'] as num?)?.toDouble(),
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

      final Map<String, dynamic> data = Map<String, dynamic>.from(response);

      // Query coordinates directly from profil_koperasi to avoid modifying RPC function schema
      final profile = await client
          .from('profil_koperasi')
          .select('latitude, longitude')
          .eq('koperasi_ref', id)
          .maybeSingle();

      if (profile != null) {
        data['latitude'] = profile['latitude'];
        data['longitude'] = profile['longitude'];
      }

      return CooperativeDetail.fromJson(data);
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
