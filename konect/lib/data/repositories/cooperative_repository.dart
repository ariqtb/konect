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
      
      // 1. Cek karyawan_koperasi berdasarkan user_uuid atau karyawan_ref
      final employee = await client
          .from('karyawan_koperasi')
          .select('koperasi_ref')
          .or('user_uuid.eq.$userId,karyawan_ref.eq.$userId')
          .limit(1)
          .maybeSingle();
      if (employee != null && employee['koperasi_ref'] != null) {
        return employee['koperasi_ref'];
      }

      // 2. Cek discussion_rooms berdasarkan created_by
      final room = await client
          .from('discussion_rooms')
          .select('koperasi_ref')
          .eq('created_by', userId)
          .limit(1)
          .maybeSingle();
      if (room != null && room['koperasi_ref'] != null) {
        return room['koperasi_ref'];
      }

      // 3. Fallback ke koperasi pertama di profil_koperasi
      final coop = await client.from('profil_koperasi').select('koperasi_ref').limit(1).maybeSingle();
      if (coop != null && coop['koperasi_ref'] != null) {
        return coop['koperasi_ref'];
      }
    } catch (_) {}
    return 'KOPSUKB-001';
  }

  Future<bool> createArticle({
    required String cooperativeId,
    required String title,
    required String content,
    required String createdBy,
  }) async {
    try {
      final client = SupabaseService().client;
      
      String actualCreatedBy = createdBy;
      final RegExp uuidRegExp = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      );
      if (!uuidRegExp.hasMatch(createdBy)) {
        final karyawan = await client
            .from('karyawan_koperasi')
            .select('user_uuid')
            .eq('karyawan_ref', createdBy)
            .maybeSingle();
        if (karyawan != null && karyawan['user_uuid'] != null) {
          actualCreatedBy = karyawan['user_uuid'];
        } else {
          actualCreatedBy = '704a44f7-060f-47ad-9594-51f991ced8d9'; // fallback admin uuid
        }
      }

      await client.from('articles').insert({
        'koperasi_ref': cooperativeId,
        'title': title,
        'content': content,
        'created_by': actualCreatedBy,
      });
      return true;
    } catch (e) {
      print('[createArticle] ERROR: $e');
      return false;
    }
  }

  /// Fetch cooperatives from profil_koperasi that have coordinates,
  /// joining gerai_koperasi for store image. Returns all items;
  /// distance calculation and sorting is done client-side.
  Future<List<CooperativeItem>> getNearbyCooperatives() async {
    try {
      final client = SupabaseService().client;
      final response = await client
          .from('profil_koperasi')
          .select('*, gerai_koperasi(foto_gerai, status_gerai)')
          .not('latitude', 'is', null)
          .not('longitude', 'is', null);

      return (response as List<dynamic>).map((data) {
        final name = data['nama_koperasi']?.toString() ?? 'Koperasi Tanpa Nama';
        final category = data['kategori_usaha']?.toString() ?? 'Umum';
        final address = data['alamat_lengkap']?.toString() ?? 'Alamat tidak tersedia';

        // Get the first gerai image if available
        String? imageUrl;
        bool isOpen = data['status_registrasi'] == 'Approved';
        final geraiList = data['gerai_koperasi'];
        if (geraiList is List && geraiList.isNotEmpty) {
          imageUrl = geraiList[0]['foto_gerai']?.toString();
          // If any gerai is active, mark as open
          if (geraiList.any((g) => g['status_gerai'] == 'Aktif')) {
            isOpen = true;
          }
        }

        return CooperativeItem(
          id: data['koperasi_ref']?.toString() ?? '',
          name: name,
          category: category,
          isOpen: isOpen,
          address: address,
          distance: '',
          imageUrl: imageUrl ??
              'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random',
          latitude: (data['latitude'] as num?)?.toDouble(),
          longitude: (data['longitude'] as num?)?.toDouble(),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch nearby cooperatives: $e');
    }
  }

  /// Fetch cooperatives from profil_koperasi with their gerai radius.
  /// Returns a list of maps: { 'coop': CooperativeItem, 'radius': double? }
  /// The radius comes from the largest gerai_koperasi.radius for each cooperative.
  Future<List<Map<String, dynamic>>> getNearbyCooperativesWithRadius() async {
    try {
      final client = SupabaseService().client;
      final response = await client
          .from('profil_koperasi')
          .select('*, gerai_koperasi(foto_gerai, status_gerai, radius)')
          .not('latitude', 'is', null)
          .not('longitude', 'is', null);

      return (response as List<dynamic>).map((data) {
        final name = data['nama_koperasi']?.toString() ?? 'Koperasi Tanpa Nama';
        final category = data['kategori_usaha']?.toString() ?? 'Umum';
        final address = data['alamat_lengkap']?.toString() ?? 'Alamat tidak tersedia';

        String? imageUrl;
        bool isOpen = data['status_registrasi'] == 'Approved';
        double? maxRadius;
        final geraiList = data['gerai_koperasi'];
        if (geraiList is List && geraiList.isNotEmpty) {
          imageUrl = geraiList[0]['foto_gerai']?.toString();
          if (geraiList.any((g) => g['status_gerai'] == 'Aktif')) {
            isOpen = true;
          }
          // Use the largest radius among all gerai for this cooperative
          for (final g in geraiList) {
            final r = (g['radius'] as num?)?.toDouble();
            if (r != null && (maxRadius == null || r > maxRadius)) {
              maxRadius = r;
            }
          }
        }

        final coop = CooperativeItem(
          id: data['koperasi_ref']?.toString() ?? '',
          name: name,
          category: category,
          isOpen: isOpen,
          address: address,
          distance: '',
          imageUrl: imageUrl ??
              'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random',
          latitude: (data['latitude'] as num?)?.toDouble(),
          longitude: (data['longitude'] as num?)?.toDouble(),
        );

        return {
          'coop': coop,
          'radius': maxRadius,
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch nearby cooperatives with radius: $e');
    }
  }
}

final cooperativeRepository = CooperativeRepository();
