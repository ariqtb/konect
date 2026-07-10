import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../voucher/voucher_page.dart';
import '../profile/profile_page.dart';
import '../cooperative/cooperative_page.dart';
import '../../../data/repositories/room_repository.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final TextEditingController _roomCodeController = TextEditingController();
  List<Map<String, dynamic>>? _joinedRooms;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadJoinedRooms();
    });
  }

  Future<void> _loadJoinedRooms() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final rooms = await roomRepository.getJoinedRooms(authState.user.id);
      if (mounted) {
        setState(() {
          _joinedRooms = rooms;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _joinedRooms = [];
        });
      }
    }
  }

  String _formatDateTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      final day = dt.day.toString().padLeft(2, '0');
      final month = months[dt.month - 1];
      final year = dt.year;
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$day $month $year • $hour:$minute WIB';
    } catch (_) {
      return isoString;
    }
  }

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandBg,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              // Index 0: Home Content
              SingleChildScrollView(
                padding: const EdgeInsets.only(
                    bottom:
                        100.0), // Padding to avoid overlap with bottom navigation bar
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Red background container
                        Container(
                          height: 250,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: AppColors.brandRed,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                        ),
                        // Content column (header + card)
                        SafeArea(
                          bottom: false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(),
                              const SizedBox(height: 16),
                              _buildHeroDiscussion(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildNearestCoop(),
                    const SizedBox(height: 32),
                    _buildJoinRoom(),
                    const SizedBox(height: 32),
                    _buildHistorySection(),
                  ],
                ),
              ),
              // Index 1: Koperasi
              const CooperativePage(showBackButton: false),
              // Index 2: Voucher
              const VoucherPage(),
              // Index 3: Profile
              const ProfilePage(),
            ],
          ),
          // Floating Translucent Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNavigationBar(),
          ),
          // Floating Center Action Button (Centering horizontally, non-clipping)
          Positioned(
            bottom: 42,
            left: 0,
            right: 0,
            child: Center(
              child: _buildCenterActionButton(),
            ),
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
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.025 * 32,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Akses layanan desa Anda hari ini.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              icon:
                  const Icon(Icons.emoji_events_outlined, color: Colors.white),
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
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Sedang Aktif',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF065F46),
                        ),
                      ),
                    ),
                    const Text(
                      '24 Okt 2023',
                      style: TextStyle(
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
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pembahasan Bibit Padi Q3 & Subsidi Pupuk Organik',
                  style: TextStyle(
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
                            child: _buildAvatar(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuDtRv06_ngfuOBMx3FQhVFdo11gQ7P656W04jhE26yTQXmjyaIYocjBvGu5J_iBmIaJVm3SxW5-4GBq_HB9DHlYHGkSFNYd8GdAYzvd7rrYr7SDjT_WNGEfvxFiDpqu96h7Y9klbXuIwwVCPr3BQKqWeMJw93vs91G2_oKrQr3eSGiXBZe6l67BcoYuCwmqk0LEbU2lRPgyGlwWKhfSBcqpOV7ScQiyWhLAy8DWnRxsfkqdHokMzUt9vw'),
                          ),
                          Positioned(
                            left: 20,
                            child: _buildAvatar(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuC5s0X4zxT6Rz72_mLjmli0hSMZlyUXqLMNFgJoB9aStJuA198NhIS-VVuJpQY2GN3ESNcd97Owj83ujy8LvXY9yURjrMJ9Ze1lqoYGep4_gaGHXVfca_M6wheKrPitO7zyudY8_wlRiVb458rireAJmdKm3jyJrgxuaQAO_n3nqEIUTcEq6avB0-n2_Ml-HtC1Gozl9dgoFkp0C0nG5inPGpSUIZiYABWebZaEuvm9QWVV9cQloMhwsw'),
                          ),
                          Positioned(
                            left: 40,
                            child: _buildAvatar(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuDh1MwmbBu5s3kXhaQjmz08aufJAGbqJii-ssZi30uSPHAu1qdCxP-34X_OcI5XcVAX7AplHo4jNglpSGxtQNiAirdT7pW3VklekEEqCu9WyIwQkih5C4S3euqW7H5SaLWD8TU8M-E31-aIIXkGHSlg3g64Hmg-i4TfYIy1OJ9rGvzJsisAuLTPJd2ueXFzuUsrETvm_9UdN_ckr2HFIsQoUlx8UgcYPYOxLdXY9oehVx_TRd0in-1FLg'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        '+42 Lainnya',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
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
                      Navigator.pushNamed(
                        context,
                        AppConstants.roomDiscussionRoute,
                        arguments:
                            'Pembahasan Bibit Padi Q3 & Subsidi Pupuk Organik',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_outlined, size: 20),
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
              child: const Icon(Icons.person_outline,
                  size: 18, color: Colors.white),
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
        'image':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuA5VsV41stvFDtKwGpSKPfQeFnRKOOJeIZM-3Yy4Ay4z116mh_n2lGz_nkrh3i11N3Hz2nGolZfCY-ahnIIJ0gFsTZgUdVHF1y4IUDB7iZoXkKRAZd8m1TJ31dE7Ip5toZQf5hoSi4jDwCva0er9_EiTms9FWSFtMYdSMOFbjkLgRn_pKL6yDdMfAnubOtlfYEkJVXx3Z1atewMVUQhrvnm_ZTa2taY2s--2pIHMQYnBx0nmAvCrn7Hbw',
      },
      {
        'title': 'Koperasi Kreatif Mandiri',
        'location': 'Dusun Timur, 1.2km',
        'image':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCyc41LM7xFYpceJLbO5Em-PRi7Nmz7X0oxLYCSmiG3fQzrcdnCFrZf7PK-1uw1jT1oEGevgKNvV2C1I2H98FZWjNVb-bT3dJNULzFVXNeXkIiRKUJG_CpEBeCU8zmuaMNonibl_G43QedIvQ9eeCOQ1e6xeGBo-b24XYvmvuQU1NIwEWHcK1Yr4R-gVMbs4BeEumzJZIwgY_ntdNz0mye6uW6at-wPH_C5Oz6idQA19ZToTD-_XtLI5g',
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
              Expanded(
                child: const Text(
                  'Koperasi Desa Terdekat',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111C2D),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppConstants.cooperativeRoute);
                },
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDC2626),
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
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppConstants.cooperativeDetailRoute,
                    arguments: coop['title']!,
                  );
                },
                child: Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                            child: Image.network(
                              coop['image']!,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 150,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_outlined,
                                      color: Colors.grey),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 16,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(
                                    0xCC10B981), // emerald-500 with opacity
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
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111C2D),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 16, color: Color(0xFF94A3B8)),
                                const SizedBox(width: 4),
                                Text(
                                  coop['location']!,
                                  style: const TextStyle(
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildJoinRoom() {
    final authState = context.read<AuthBloc>().state;
    final bool isLoggedIn = authState is AuthAuthenticated;
    final bool isKopdes = isLoggedIn &&
        (authState.user.role == 'kopdes' || authState.user.role == 'admin');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Masuk room',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111C2D),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Masukkan Kode Ruang',
                  style: TextStyle(
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

                // Kopdes/Admin: Buat Rapat (Primary) + atau + Gabung Rapat (Secondary)
                // Masyarakat:   Gabung Rapat only (Primary)
                if (isKopdes) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/create-room');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline,
                              size: 22, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Buat Rapat Baru',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Center(
                      child: Text(
                        'atau',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_roomCodeController.text.trim().isNotEmpty) {
                          await Navigator.pushNamed(
                            context,
                            AppConstants.roomDiscussionRoute,
                            arguments: _roomCodeController.text.trim(),
                          );
                          _loadJoinedRooms();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Silakan masukkan kode ruang')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5F9),
                        foregroundColor: const Color(0xFF1E293B),
                        elevation: 0,
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login, size: 22, color: Color(0xFF1E293B)),
                          SizedBox(width: 10),
                          Text(
                            'Gabung Rapat',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // Masyarakat: single primary red Gabung Rapat button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_roomCodeController.text.trim().isNotEmpty) {
                          await Navigator.pushNamed(
                            context,
                            AppConstants.roomDiscussionRoute,
                            arguments: _roomCodeController.text.trim(),
                          );
                          _loadJoinedRooms();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Silakan masukkan kode ruang')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login, size: 22, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Gabung Rapat',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    if (_joinedRooms == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_joinedRooms!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Riwayat Ruang Saya',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111C2D),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: const Center(
                child: Text(
                  'Belum ada riwayat rapat. Silakan gabung rapat menggunakan kode ruang.',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      );
    }

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
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111C2D),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.tune_outlined, color: Color(0xFF64748B)),
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
            itemCount: _joinedRooms!.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = _joinedRooms![index];
              return InkWell(
                onTap: () async {
                  await Navigator.pushNamed(
                    context,
                    AppConstants.roomDiscussionRoute,
                    arguments: item['id'] as String,
                  );
                  _loadJoinedRooms();
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.people_outline,
                          color: AppColors.brandNavy,
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
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111C2D),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDateTime(item['time'] as String),
                              style: const TextStyle(
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
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _buildNavItem(Icons.home_outlined, 'Home', 0)),
            Expanded(child: _buildNavItem(Icons.storefront_outlined, 'Koperasi', 1)),
            const SizedBox(width: 72), // Empty space for FAB
            Expanded(
                child: _buildNavItem(
                    Icons.confirmation_number_outlined, 'Voucher', 2)),
            Expanded(child: _buildNavItem(Icons.person_outline, 'Profile', 3)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    final activeColor = const Color(0xFFDC2626);
    final inactiveColor = const Color(0xFF94A3B8);

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
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
    final authState = context.read<AuthBloc>().state;
    final bool isLoggedIn = authState is AuthAuthenticated;
    final bool isKopdes = isLoggedIn &&
        (authState.user.role == 'kopdes' || authState.user.role == 'admin');

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            if (isKopdes) {
              _showAdminAddOptionsModal(context);
            } else {
              _showRoomHistoryModal(context);
            }
          },
          child: Icon(
            isKopdes ? Icons.add : Icons.history_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  void _showAdminAddOptionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'PILIH AKSI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626).withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.forum_outlined,
                      color: Color(0xFFDC2626)),
                ),
                title: const Text(
                  'Buat Room Diskusi Baru',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                subtitle: const Text(
                  'Mulai sesi musyawarah warga baru di canvas',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/create-room');
                },
              ),
              const Divider(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.article_outlined,
                      color: Color(0xFF1E293B)),
                ),
                title: const Text(
                  'Kirim Progress Baru (Artikel)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                subtitle: const Text(
                  'Posting berita atau update perkembangan koperasi',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppConstants.createArticleRoute);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showRoomHistoryModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pull bar
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Riwayat Room Diskusi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Daftar ruang diskusi yang pernah Anda masuki.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // History list
              Expanded(
                child: _joinedRooms == null
                    ? const Center(child: CircularProgressIndicator())
                    : _joinedRooms!.isEmpty
                        ? const Center(
                            child: Text(
                              'Belum ada riwayat rapat.',
                              style: TextStyle(color: Color(0xFF64748B)),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: _joinedRooms!.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = _joinedRooms![index];
                              final String id = item['id'] as String;
                              final String code = id.length > 6 ? id.substring(0, 6).toUpperCase() : id.toUpperCase();
                              
                              final String startStr = item['createdAt'] != '' ? _formatDateTime(item['createdAt'] as String) : '-';
                              final String endStr = (item['isActive'] as bool) 
                                  ? 'Aktif (Sedang Berjalan)' 
                                  : (item['updatedAt'] != '' ? _formatDateTime(item['updatedAt'] as String) : 'Selesai');
                              
                              return _buildHistoryItemModal(
                                id: id,
                                code: code,
                                title: item['title'] as String,
                                date: 'Mulai: $startStr\nSelesai: $endStr',
                              );
                            },
                          ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryItemModal({
    required String id,
    required String code,
    required String title,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              code,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFFDC2626),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.arrow_forward_rounded,
                color: Color(0xFF64748B), size: 18),
            onPressed: () async {
              Navigator.pop(context); // Close sheet
              await Navigator.pushNamed(
                context,
                AppConstants.roomDiscussionRoute,
                arguments: id,
              );
              _loadJoinedRooms();
            },
          ),
        ],
      ),
    );
  }
}
