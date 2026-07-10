import '../models/cooperative.dart';
import '../models/cooperative_detail.dart';

class CooperativeRepository {
  // ============================================================
  // STATIC UUIDs untuk mock data — match dengan schema DB
  // (cooperatives.id: UUID PK di PostgreSQL)
  //
  // Saat migrasi ke Supabase, ID ini akan di-seed via SQL:
  //   INSERT INTO cooperatives (id, ...) VALUES (...);
  // ============================================================
  static const String _coopTaniMakmurId =
      '11111111-1111-4111-a111-000000000001';
  static const String _coopKudMandiriId =
      '11111111-1111-4111-a111-000000000002';
  static const String _coopSembakoSejahteraId =
      '11111111-1111-4111-a111-000000000003';
  static const String _coopPeternakSusuJayaId =
      '11111111-1111-4111-a111-000000000004';

  final List<CooperativeItem> _items = [
    const CooperativeItem(
      id: _coopTaniMakmurId,
      name: 'Koperasi Tani Makmur',
      category: 'Pertanian',
      isOpen: true,
      address: 'Jl. Raya Desa No. 42, Dusun Selatan',
      distance: '200m dari lokasimu',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBVxvniUOji38kOIG4Npc4QF4zEOBHUZPvXYDcoVm8xK7jL7BV_kb37zCNEXr4FBGgm0p5wIgS3553UlS3qZzTVCcO6BSlwp7e_vfoNpVKX4Tyx1yXqK4LIqHFbMcF5FdqDUbESqU3a8KI655wE_0PDXLJCIw2Esp-pel-BeaagBEB9TFYvikAJwF9EWSy4QbTobfbIeaykuIBaUTK4O5eQYuz50gQD_XsgLfPF7ye76wcvNRnQKOiGfA',
    ),
    const CooperativeItem(
      id: _coopKudMandiriId,
      name: 'Koperasi Unit Desa (KUD) Mandiri',
      category: 'Simpan Pinjam',
      isOpen: true,
      address: 'Pusat Desa, Samping Balai Desa',
      distance: '200m dari lokasimu',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCtwGspzX5_VMi9TppI6XUTSgvaLbMV5j4X535CO3q0u0ixOFuZx-pjJZwqZmAUvLuyb8skxv9HHWSF1fTyFVPZd8moQu9Qm08xLGiRuggTBDdLUVahTyGpFh6nHoug8QEyBlHlXtz9PfQ5sz20aZPK86fmEq5hjJX0WbV0SebikSQu1EgHlnyotlRJX5pqk71c0EQ9XsSI8TwljnPIou52n_pZryDobOZVqqjDSg-eoNYDfdgyj5AbBQ',
    ),
    const CooperativeItem(
      id: _coopSembakoSejahteraId,
      name: 'Toko Koperasi Sembako Sejahtera',
      category: 'Sembako',
      isOpen: true,
      address: 'Jl. Pemuda No. 10, Dusun Barat',
      distance: '500m dari lokasimu',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA5VsV41stvFDtKwGpSKPfQeFnRKOOJeIZM-3Yy4Ay4z116mh_n2lGz_nkrh3i11N3Hz2nGolZfCY-ahnIIJ0gFsTZgUdVHF1y4IUDB7iZoXkKRAZd8m1TJ31dE7Ip5toZQf5hoSi4jDwCva0er9_EiTms9FWSFtMYdSMOFbjkLgRn_pKL6yDdMfAnubOtlfYEkJVXx3Z1atewMVUQhrvnm_ZTa2taY2s--2pIHMQYnBx0nmAvCrn7Hbw',
    ),
    const CooperativeItem(
      id: _coopPeternakSusuJayaId,
      name: 'Koperasi Peternak Susu Jaya',
      category: 'Pertanian',
      isOpen: false,
      address: 'Dusun Utara No. 15',
      distance: '1.2km dari lokasimu',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCyc41LM7xFYpceJLbO5Em-PRi7Nmz7X0oxLYCSmiG3fQzrcdnCFrZf7PK-1uw1jT1oEGevgKNvV2C1I2H98FZWjNVb-bT3dJNULzFVXNeXkIiRKUJG_CpEBeCU8zmuaMNonibl_G43QedIvQ9eeCOQ1e6xeGBo-b24XYvmvuQU1NIwEWHcK1Yr4R-gVMbs4BeEumzJZIwgY_ntdNz0mye6uW6at-wPH_C5Oz6idQA19ZToTD-_XtLI5g',
    ),
  ];

  Future<List<CooperativeItem>> getCooperatives() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(_items);
  }

  Future<CooperativeDetail> getCooperativeDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Return high-fidelity mock details matching create_cooperativedetail.html
    return CooperativeDetail(
      coopId: id,
      chairperson: 'H. Agus Setiawan',
      memberCount: 150,
      legalStatus: 'Terverifikasi Desa',
      phone: '+62 812-3456-7890',
      email: 'kopdes.makmur@desa.id',
      rooms: [
        const CoopDiscussionRoom(
          id: 'r1',
          title: 'Pembahasan Bibit Padi Q3 & Subsidi Pupuk Organik',
          description:
              'Mendiskusikan pemilihan varietas bibit unggul untuk musim tanam mendatang dan koordinasi distribusi bantuan pupuk dari pemda.',
          status: 'Aktif',
          date: '24 Okt 2023',
          membersCount: 45,
          avatars: [
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDd0CO3jjvwOOQmzbJ4alXTPN68QttR7le7VUYpbcZ3Jiu5okmtWFjgXOHfuvw2voeWJQNs9g8JOdl98bxyLAD1MCIpYSqQ1PzEk8Nhp0O1ErsZlgC6A1ilGgECodxsLwuxTlda9tHi_szaFTbQwUE9WhiKq_6SRTXr0h35EgsUo4cK4_ozd7K-Eu-1hvmFVLr6KxJIdzdJl3y9EM9SY4uQvtFwPIhZ3nuivXxdJTCQ3KANYD7Yem6FZg',
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAaf8aBH-Z2nTzOsskhVs9ZLgA3qtJqoPl9Jo7JiRLQt_vu6OpBlsW6jwUnZk2wgKe7V-J7BYQhVfudz7ZJq5aivyX2OIcFdl-_kcYrH0e4a7B95rXiEcGtwixK7ac3wmxPdi4MgRJakROIZEU6vdSN_FVzhWPLXYpnCNK2ZeSXb2CvQgWxujwIjllCHdxKcYpnQiDZU80TTBj6Y3LWe0giJsFAUTEZ6erAoIhWTd23O52OUGmF58ZqKw',
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBq0IdOQGwHs185uXjvLttdlu8fGdAc0-v4hp2bDcXsTZ2l_JxQuw5oYRRbzVzjls_uK_9CuQLuy4H5Gh8KSAzcDl33L-90kW3uVzJHIKOwHQT9nUfOi2NY-uClg6Ga1e5webRH2MTX_4GFSBhywM2molLmnKKy2xoSrw_fN92fWflY3jUov0dYo2gTXKmUlFIRDPaTjp6259p3zan-AuxfS7y0FlnXBkeLKxtWw9Wc65V2mh6KdZQsfg',
          ],
        ),
        const CoopDiscussionRoom(
          id: 'r2',
          title: 'Audit Tahunan Koperasi 2022',
          description:
              'Laporan transparansi keuangan dan pembagian Sisa Hasil Usaha (SHU).',
          status: 'Selesai',
          date: 'Sep 2023',
          membersCount: 30,
          avatars: [],
        ),
        const CoopDiscussionRoom(
          id: 'r3',
          title: 'Rencana Pengadaan Alsintan',
          description:
              'Kesepakatan pembelian traktor tangan kolektif untuk kelompok tani.',
          status: 'Selesai',
          date: 'Agu 2023',
          membersCount: 25,
          avatars: [],
        ),
      ],
      updates: [
        const CoopTimelineUpdate(
          id: 'u1',
          title: 'Penyelesaian Fondasi Tiang Surya Tahap I',
          description:
              'Sebanyak 40 titik di Dusun Krajan telah selesai dipasang dudukan beton.',
          date: '12 Oktober 2024',
          type: 'warning',
        ),
        const CoopTimelineUpdate(
          id: 'u2',
          title: 'Pengadaan Perangkat IoT Pertanian',
          description:
              'Verifikasi unit sensor tanah dan kelembaban udara oleh tim teknis desa.',
          date: '05 Oktober 2024',
          type: 'info',
        ),
      ],
    );
  }
}

final cooperativeRepository = CooperativeRepository();
