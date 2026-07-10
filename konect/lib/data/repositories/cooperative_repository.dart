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
      
      final profile = await client.from('profil_koperasi').select().eq('koperasi_ref', id).maybeSingle();
      if (profile == null) throw Exception('Koperasi tidak ditemukan');

      final board = await client.from('pengurus_koperasi').select().eq('koperasi_ref', id).limit(1).maybeSingle();
      
      final members = await client.from('anggota_koperasi').select('anggota_ref').eq('koperasi_ref', id);
      
      return CooperativeDetail(
        coopId: id,
        name: profile['nama_koperasi']?.toString() ?? 'Koperasi Tanpa Nama',
        category: profile['kategori_usaha']?.toString() ?? 'Umum',
        address: profile['alamat_lengkap']?.toString() ?? 'Alamat tidak tersedia',
        about: profile['tentang_koperasi']?.toString() ?? 'Belum ada deskripsi tentang koperasi ini.',
        chairperson: board?['nama']?.toString() ?? 'Belum ada pengurus',
        memberCount: (members as List).length,
        legalStatus: profile['status_registrasi']?.toString() ?? 'Drafted',
        phone: board?['no_hp']?.toString() ?? '-',
        email: board?['email']?.toString() ?? '-',
        rooms: const [
          CoopDiscussionRoom(
            id: 'r1',
            title: 'Diskusi Tahunan',
            description: 'Membahas operasional dan SHU koperasi.',
            status: 'Aktif',
            date: 'Sekarang',
            membersCount: 10,
            avatars: [],
          )
        ],
        updates: const [
          CoopTimelineUpdate(
            id: 'u1',
            title: 'Koperasi Telah Terdaftar',
            description: 'Koperasi telah aktif dan siap melayani anggota.',
            date: 'Baru saja',
            type: 'info',
          )
        ],
      );
    } catch (e) {
      throw Exception('Failed to fetch cooperative details: $e');
    }
  }
}

final cooperativeRepository = CooperativeRepository();
