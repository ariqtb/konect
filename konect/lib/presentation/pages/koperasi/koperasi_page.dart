import 'package:flutter/material.dart';

class KoperasiPage extends StatelessWidget {
  const KoperasiPage({super.key});

  static const List<Map<String, dynamic>> _koperasiList = [
    {
      'name': 'Koperasi Makmur Jaya',
      'location': 'Desa Sukamaju, Kec. Ciomas',
      'members': 142,
      'status': 'Aktif',
      'category': 'Simpan Pinjam',
    },
    {
      'name': 'Koperasi Harapan Baru',
      'location': 'Desa Mekarjaya, Kec. Bogor',
      'members': 89,
      'status': 'Aktif',
      'category': 'Konsumsi',
    },
    {
      'name': 'Koperasi Sejahtera',
      'location': 'Desa Cikaret, Kec. Cibinong',
      'members': 215,
      'status': 'Aktif',
      'category': 'Produksi',
    },
    {
      'name': 'Koperasi Tani Subur',
      'location': 'Desa Sukamakmur, Kec. Sukaraja',
      'members': 67,
      'status': 'Tidak Aktif',
      'category': 'Pertanian',
    },
    {
      'name': 'Koperasi Wanita Mandiri',
      'location': 'Desa Pabuaran, Kec. Kemang',
      'members': 53,
      'status': 'Aktif',
      'category': 'Simpan Pinjam',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Text(
                'Koperasi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Temukan koperasi di sekitar Anda',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Cari koperasi...',
                      style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                itemCount: _koperasiList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final kop = _koperasiList[index];
                  final isActive = kop['status'] == 'Aktif';
                  return _KoperasiCard(
                    name: kop['name'],
                    location: kop['location'],
                    members: kop['members'],
                    category: kop['category'],
                    isActive: isActive,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KoperasiCard extends StatelessWidget {
  final String name;
  final String location;
  final int members;
  final String category;
  final bool isActive;

  const _KoperasiCard({
    required this.name,
    required this.location,
    required this.members,
    required this.category,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFFDE8E8)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.storefront_outlined,
              color: isActive
                  ? const Color(0xFFE21E49)
                  : const Color(0xFF94A3B8),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFFECFDF5)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        isActive ? 'Aktif' : 'Nonaktif',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? const Color(0xFF059669)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$location · $members anggota',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 20),
        ],
      ),
    );
  }
}
