import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF), // brand.surface
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100), // Space for bottom nav
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // MainHeader
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Konect',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A), // Slate-900
                            letterSpacing: -0.75,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Akses layanan desa Anda hari ini.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B), // Slate-500
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/leaderboard'),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F3FF), // brand-container
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Icon(
                          Icons.person_pin_outlined, // non-generic profile icon
                          color: Color(0xFF475569),
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // HeroDiscussion Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Diskusi Koperasi Desa di lokasi anda',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F3FF), // brand-container
                        borderRadius: BorderRadius.circular(32), // rounded-4xl
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0E7FF), // indigo-100
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: const Text(
                                  'Sedang Aktif',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4338CA), // indigo-700
                                  ),
                                ),
                              ),
                              const Text(
                                '24 Okt 2023',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Koperasi Desa Makmur Jaya',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Pembahasan Bibit Padi Q3 & Subsidi Pupuk Organik',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              // Overlapping Avatars (mocked)
                              SizedBox(
                                width: 70,
                                height: 32,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 0,
                                      child: _buildAvatar('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=80&fit=crop'),
                                    ),
                                    Positioned(
                                      left: 16,
                                      child: _buildAvatar('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&fit=crop'),
                                    ),
                                    Positioned(
                                      left: 32,
                                      child: _buildAvatar('https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=80&fit=crop'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0E7FF),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: const Text(
                                  '+42 Lainnya',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4338CA),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE21E49), // brand-secondary red
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24), // rounded-3xl
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppConstants.roomDiscussionRoute,
                                  arguments: 'Pembahasan Bibit Padi Q3 & Subsidi Pupuk Organik',
                                );
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Ikuti Diskusi',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // NearestCoop Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Koperasi Desa Terdekat',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {}, // Navigate to koperasi list tab
                          child: const Text(
                            'Lihat Semua',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFE21E49),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        _buildNearestCoopCard(
                          name: 'Koperasi Tani Makmur',
                          distance: 'Dusun Utara, 400m',
                          imageUrl: 'https://images.unsplash.com/photo-1595974482597-4b8da8879bc5?w=400&fit=crop',
                        ),
                        _buildNearestCoopCard(
                          name: 'Koperasi Kreatif Mandiri',
                          distance: 'Dusun Timur, 1.2km',
                          imageUrl: 'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=400&fit=crop',
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // JoinRoom Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Masuk room',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F3FF),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Masukkan Kode Ruang',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _codeController,
                            style: const TextStyle(fontSize: 15),
                            decoration: InputDecoration(
                              hintText: 'Contoh: DESA-2024',
                              hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
                              fillColor: Colors.white,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(color: Color(0xFFE21E49), width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE21E49),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                if (_codeController.text.trim().isNotEmpty) {
                                  Navigator.pushNamed(
                                    context,
                                    AppConstants.roomDiscussionRoute,
                                    arguments: _codeController.text.trim(),
                                  );
                                }
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.login_rounded, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Gabung Rapat',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // HistorySection
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Riwayat Ruang Saya',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.tune_rounded, color: Color(0xFF475569)),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildHistoryItem(
                      icon: Icons.volume_up_outlined,
                      iconBg: const Color(0xFFE0E7FF),
                      iconColor: const Color(0xFF4338CA),
                      title: 'Musyawarah Pembangunan Jalan',
                      subtitle: '12 Oktober 2024 • 14:00 WIB',
                    ),
                    const SizedBox(height: 12),
                    _buildHistoryItem(
                      icon: Icons.local_shipping_outlined,
                      iconBg: const Color(0xFFD1FAE5),
                      iconColor: const Color(0xFF059669),
                      title: 'Distribusi Pupuk Subsidi',
                      subtitle: '08 Oktober 2024 • 09:30 WIB',
                    ),
                    const SizedBox(height: 12),
                    _buildHistoryItem(
                      icon: Icons.groups_outlined,
                      iconBg: const Color(0xFFFFE4E6),
                      iconColor: const Color(0xFFE21E49),
                      title: 'Rapat Karang Taruna',
                      subtitle: '01 Oktober 2024 • 19:00 WIB',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String url) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF2F3FF), width: 2),
        image: DecorationImage(
          image: NetworkImage(url),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildNearestCoopCard({
    required String name,
    required String distance,
    required String imageUrl,
  }) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Image.network(
              imageUrl,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.map_pin_rounded ?? Icons.location_on_outlined, size: 14, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 4),
                    Text(
                      distance,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppConstants.roomDiscussionRoute,
          arguments: title,
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
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
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 20),
          ],
        ),
      ),
    );
  }
}
