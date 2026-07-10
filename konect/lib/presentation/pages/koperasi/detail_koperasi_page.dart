import 'package:flutter/material.dart';

class DetailKoperasiPage extends StatelessWidget {
  const DetailKoperasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String name = ModalRoute.of(context)?.settings.arguments as String? ?? 'Koperasi Tani Makmur';

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Banner with back button overlay
            Stack(
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1595974482597-4b8da8879bc5?w=600&fit=crop',
                  height: 240,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 50,
                  left: 20,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),

            // Content Details
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Text(
                          'Buka',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF065F46),
                          ),
                        ),
                      ),
                      const Text(
                        'ID Koperasi: KP-042',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: Color(0xFFE21E49)),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Jl. Raya Desa No. 42, Dusun Selatan',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Stats row
                  Row(
                    children: [
                      _buildStatItem('142', 'Anggota'),
                      _buildStatItem('4.8 ★', 'Rating'),
                      _buildStatItem('200m', 'Jarak'),
                    ],
                  ),
                  const SizedBox(height: 28),

                  const Text(
                    'Tentang Koperasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Koperasi Tani Makmur didirikan untuk menyejahterakan para petani di Dusun Selatan melalui penyediaan bibit unggul, pupuk bersubsidi, serta pendampingan masa tanam. Kami juga melayani simpan pinjam untuk modal usaha tani.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF475569),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),

                  const Text(
                    'Program & Layanan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildProgramItem(
                    icon: Icons.agriculture_rounded,
                    title: 'Penyaluran Pupuk Organik',
                    subtitle: 'Subsidi pupuk untuk anggota terdaftar.',
                  ),
                  const SizedBox(height: 10),
                  _buildProgramItem(
                    icon: Icons.savings_outlined,
                    title: 'Simpan Pinjam Tani',
                    subtitle: 'Bunga ringan khusus modal bibit padi.',
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE21E49),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            onPressed: () {},
            child: const Text(
              'Hubungi Pengurus',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String val, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Column(
          children: [
            Text(
              val,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE21E49),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F3FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF1A2E44), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
