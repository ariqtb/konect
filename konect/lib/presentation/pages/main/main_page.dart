import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final TextEditingController _roomCodeController = TextEditingController();

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: Stack(
        children: [
          // Scrollable Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100.0), // Padding to avoid overlap with bottom navigation bar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildHeroDiscussion(),
                  const SizedBox(height: 32),
                  _buildNearestCoop(),
                  const SizedBox(height: 32),
                  _buildJoinRoom(),
                  const SizedBox(height: 32),
                  _buildHistorySection(),
                ],
              ),
            ),
          ),
          // Floating Translucent Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNavigationBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Konect',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111C2D),
                    letterSpacing: -0.025 * 32,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Akses layanan desa Anda hari ini.',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F3FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: IconButton(
              icon: const Icon(Icons.person_outline, color: Color(0xFF111C2D)),
              onPressed: () {
                Navigator.pushNamed(context, AppConstants.leaderboardRoute);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroDiscussion() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Diskusi Koperasi Desa di lokasi anda',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111C2D),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF2F3FF),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E7FF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Sedang Aktif',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF494BD6),
                        ),
                      ),
                    ),
                    const Text(
                      '24 Okt 2023',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Koperasi Desa Makmur Jaya',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pembahasan Bibit Padi Q3 & Subsidi Pupuk Organik',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111C2D),
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    // Overlapping Avatars
                    SizedBox(
                      height: 36,
                      width: 76,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            child: _buildAvatar('https://lh3.googleusercontent.com/aida-public/AB6AXuDtRv06_ngfuOBMx3FQhVFdo11gQ7P656W04jhE26yTQXmjyaIYocjBvGu5J_iBmIaJVm3SxW5-4GBq_HB9DHlYHGkSFNYd8GdAYzvd7rrYr7SDjT_WNGEfvxFiDpqu96h7Y9klbXuIwwVCPr3BQKqWeMJw93vs91G2_oKrQr3eSGiXBZe6l67BcoYuCwmqk0LEbU2lRPgyGlwWKhfSBcqpOV7ScQiyWhLAy8DWnRxsfkqdHokMzUt9vw'),
                          ),
                          Positioned(
                            left: 20,
                            child: _buildAvatar('https://lh3.googleusercontent.com/aida-public/AB6AXuC5s0X4zxT6Rz72_mLjmli0hSMZlyUXqLMNFgJoB9aStJuA198NhIS-VVuJpQY2GN3ESNcd97Owj83ujy8LvXY9yURjrMJ9Ze1lqoYGep4_gaGHXVfca_M6wheKrPitO7zyudY8_wlRiVb458rireAJmdKm3jyJrgxuaQAO_n3nqEIUTcEq6avB0-n2_Ml-HtC1Gozl9dgoFkp0C0nG5inPGpSUIZiYABWebZaEuvm9QWVV9cQloMhwsw'),
                          ),
                          Positioned(
                            left: 40,
                            child: _buildAvatar('https://lh3.googleusercontent.com/aida-public/AB6AXuDh1MwmbBu5s3kXhaQjmz08aufJAGbqJii-ssZi30uSPHAu1qdCxP-34X_OcI5XcVAX7AplHo4jNglpSGxtQNiAirdT7pW3VklekEEqCu9WyIwQkih5C4S3euqW7H5SaLWD8TU8M-E31-aIIXkGHSlg3g64Hmg-i4TfYIy1OJ9rGvzJsisAuLTPJd2ueXFzuUsrETvm_9UdN_ckr2HFIsQoUlx8UgcYPYOxLdXY9oehVx_TRd0in-1FLg'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E7FF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        '+42 Lainnya',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF494BD6),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppConstants.forumRoute);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE21E49),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Ikuti Diskusi',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String url) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF2F3FF), width: 2),
      ),
      child: ClipOval(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.person, size: 18, color: Colors.white),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNearestCoop() {
    final coops = [
      {
        'title': 'Koperasi Makmur Jaya',
        'location': 'Dusun Utara, 400m',
        'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuA5VsV41stvFDtKwGpSKPfQeFnRKOOJeIZM-3Yy4Ay4z116mh_n2lGz_nkrh3i11N3Hz2nGolZfCY-ahnIIJ0gFsTZgUdVHF1y4IUDB7iZoXkKRAZd8m1TJ31dE7Ip5toZQf5hoSi4jDwCva0er9_EiTms9FWSFtMYdSMOFbjkLgRn_pKL6yDdMfAnubOtlfYEkJVXx3Z1atewMVUQhrvnm_ZTa2taY2s--2pIHMQYnBx0nmAvCrn7Hbw',
      },
      {
        'title': 'Koperasi Kreatif Mandiri',
        'location': 'Dusun Timur, 1.2km',
        'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCyc41LM7xFYpceJLbO5Em-PRi7Nmz7X0oxLYCSmiG3fQzrcdnCFrZf7PK-1uw1jT1oEGevgKNvV2C1I2H98FZWjNVb-bT3dJNULzFVXNeXkIiRKUJG_CpEBeCU8zmuaMNonibl_G43QedIvQ9eeCOQ1e6xeGBo-b24XYvmvuQU1NIwEWHcK1Yr4R-gVMbs4BeEumzJZIwgY_ntdNz0mye6uW6at-wPH_C5Oz6idQA19ZToTD-_XtLI5g',
      }
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Koperasi Desa Terdekat',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111C2D),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppConstants.cooperativeRoute);
                },
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontFamily: 'Outfit',
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
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            itemCount: coops.length,
            itemBuilder: (context, index) {
              final coop = coops[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                          child: Image.network(
                            coop['image']!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 150,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xCC10B981), // emerald-500 with opacity
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Row(
                              children: [
                                CircleAvatar(
                                  radius: 3,
                                  backgroundColor: Colors.white,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Buka',
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            coop['title']!,
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111C2D),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 4),
                              Text(
                                coop['location']!,
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 14,
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
            },
          ),
        ),
      ],
    );
  }

  Widget _buildJoinRoom() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Masuk room',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111C2D),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F3FF),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Masukkan Kode Ruang',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111C2D),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _roomCodeController,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: DESA-2024',
                    hintStyle: TextStyle(color: Color(0xFFCBD5E1)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_roomCodeController.text.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Bergabung ke ruang: ${_roomCodeController.text}')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Silakan masukkan kode ruang')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE21E49),
                      elevation: 4,
                      shadowColor: const Color(0xFFFFB3B6),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login, size: 22),
                        SizedBox(width: 10),
                        Text(
                          'Gabung Rapat',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }

  Widget _buildHistorySection() {
    final historyItems = [
      {
        'title': 'Musyawarah Pembangunan Jalan',
        'time': '12 Oktober 2024 • 14:00 WIB',
        'icon': Icons.volume_up,
        'iconColor': const Color(0xFF494BD6),
        'bgColor': const Color(0xFFE0E7FF),
      },
      {
        'title': 'Distribusi Pupuk Subsidi',
        'time': '08 Oktober 2024 • 09:30 WIB',
        'icon': Icons.local_shipping,
        'iconColor': const Color(0xFF10B981),
        'bgColor': const Color(0xFFD1FAE5),
      },
      {
        'title': 'Rapat Karang Taruna',
        'time': '01 Oktober 2024 • 19:00 WIB',
        'icon': Icons.people,
        'iconColor': const Color(0xFFBA0035),
        'bgColor': const Color(0xFFFFE4E6),
      }
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Riwayat Ruang Saya',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111C2D),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.tune, color: Color(0xFF64748B)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Filter Riwayat')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: historyItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = historyItems[index];
              return InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Membuka riwayat: ${item['title']}')),
                  );
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F3FF).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: item['bgColor'] as Color,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: item['iconColor'] as Color,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'] as String,
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111C2D),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['time'] as String,
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRect(
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.storefront, 'Co-op', 1),
              _buildCenterActionButton(),
              _buildNavItem(Icons.confirmation_number_outlined, 'Voucher', 2),
              _buildNavItem(Icons.person_outline, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    final activeColor = const Color(0xFFE21E49);
    final inactiveColor = const Color(0xFF94A3B8);

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        if (index == 1) {
          Navigator.pushNamed(context, AppConstants.cooperativeRoute);
        } else if (index == 2 || index == 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Navigasi ke $label')),
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? activeColor : inactiveColor,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.05 * 10,
              color: isActive ? activeColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterActionButton() {
    return Container(
      transform: Matrix4.translationValues(0, -12, 0),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFE21E49),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE21E49).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Menu Tambah / Aksi Cepat')),
              );
            },
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
