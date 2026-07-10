import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat pagi,',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Warga Desa',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: Color(0xFF475569),
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Search Bar
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
                        'Cari update, koperasi, voucher...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Koperasi Terdekat — horizontal scroll
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Koperasi Terdekat',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _buildKoperasiCard('Makmur Jaya', 'Desa Sukamaju', 142),
                    _buildKoperasiCard('Harapan Baru', 'Desa Mekarjaya', 89),
                    _buildKoperasiCard('Sejahtera', 'Desa Cikaret', 215),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Update Terbaru
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Update Terbaru',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Lihat semua',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFE21E49),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Article Feed
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildArticleCard(
                      context,
                      title: 'Penyelesaian Fondasi Tiang Surya Tahap I',
                      category: 'Energi Terbarukan',
                      date: '24 Okt 2023',
                      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCKj0KyglLbOn2DNZtnYMsq9ynlR1zolGnlJFH_Wi5WD4UFDg61Ko5G0p_9-k8CGSHESAEm6ruFwuqZ_FeYobQJ8ZByPooIyVDKFdMzvvtBo6LWVoBA-Zg-Zh2dCoTOPIiFAuUIms3rKcoYv_fDc_O3VNQsX5BL_SieaMawl9qyZFkmKNXcN2N3EMXBEktJ3UskUHFo055njg4PkXRI3WfbsTcqT4hRBJrIKFnrdk4h6cxtTGMKTL4PS_C8XOFCMztcx00',
                    ),
                    const SizedBox(height: 12),
                    _buildArticleCard(
                      context,
                      title: 'Panen Perdana Kelompok Tani Sejahtera',
                      category: 'Pertanian',
                      date: '20 Okt 2023',
                      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCKj0KyglLbOn2DNZtnYMsq9ynlR1zolGnlJFH_Wi5WD4UFDg61Ko5G0p_9-k8CGSHESAEm6ruFwuqZ_FeYobQJ8ZByPooIyVDKFdMzvvtBo6LWVoBA-Zg-Zh2dCoTOPIiFAuUIms3rKcoYv_fDc_O3VNQsX5BL_SieaMawl9qyZFkmKNXcN2N3EMXBEktJ3UskUHFo055njg4PkXRI3WfbsTcqT4hRBJrIKFnrdk4h6cxtTGMKTL4PS_C8XOFCMztcx00',
                    ),
                    const SizedBox(height: 12),
                    _buildArticleCard(
                      context,
                      title: 'Gotong Royong Perbaikan Jembatan Dusun 3',
                      category: 'Infrastruktur',
                      date: '15 Okt 2023',
                      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCKj0KyglLbOn2DNZtnYMsq9ynlR1zolGnlJFH_Wi5WD4UFDg61Ko5G0p_9-k8CGSHESAEm6ruFwuqZ_FeYobQJ8ZByPooIyVDKFdMzvvtBo6LWVoBA-Zg-Zh2dCoTOPIiFAuUIms3rKcoYv_fDc_O3VNQsX5BL_SieaMawl9qyZFkmKNXcN2N3EMXBEktJ3UskUHFo055njg4PkXRI3WfbsTcqT4hRBJrIKFnrdk4h6cxtTGMKTL4PS_C8XOFCMztcx00',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKoperasiCard(String name, String location, int members) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8E8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  color: Color(0xFFE21E49),
                  size: 18,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF94A3B8)),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  '$location · $members anggota',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(
    BuildContext context, {
    required String title,
    required String category,
    required String date,
    required String imageUrl,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppConstants.articleDetailRoute),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Image.network(
                imageUrl,
                width: 100,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            // Text content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFE21E49),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
