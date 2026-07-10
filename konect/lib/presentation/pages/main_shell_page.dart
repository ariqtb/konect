import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import 'home/home_page.dart';
import 'koperasi/koperasi_page.dart';
import 'voucher/voucher_page.dart';
import 'profile/profile_page.dart';
import '../../core/constants.dart';
import '../../data/repositories/room_repository.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const KoperasiPage(),
    const SizedBox.shrink(), // Placeholder for the middle Add button action
    const VoucherPage(),
    const ProfilePage(),
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      _handleMiddleButton();
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  void _handleMiddleButton() {
    final authState = context.read<AuthBloc>().state;
    final bool isLoggedIn = authState is AuthAuthenticated;
    final bool isKopdes = isLoggedIn && (authState.user.role == 'kopdes' || authState.user.role == 'admin');

    if (isKopdes) {
      _showAdminMenuModal();
    } else {
      _showRoomHistoryModal();
    }
  }

  void _showAdminMenuModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 24),
              const Text(
                'Menu Admin Koperasi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626).withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_circle_outline, color: Color(0xFFDC2626)),
                ),
                title: const Text(
                  'Buat Room Rapat Baru',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                ),
                subtitle: const Text('Mulai sesi rapat/diskusi kanvas baru'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/create-room');
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.article_outlined, color: Color(0xFF10B981)),
                ),
                title: const Text(
                  'Buat Progress / Artikel',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                ),
                subtitle: const Text('Publikasikan artikel progres pembangunan atau berita'),
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

  void _showRoomHistoryModal() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu untuk melihat riwayat.')),
      );
      return;
    }
    final userId = authState.user.id;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
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
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: roomRepository.getJoinedRooms(userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDC2626)),
                        ),
                      );
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'Belum ada riwayat rapat.',
                          style: TextStyle(color: Color(0xFF64748B)),
                        ),
                      );
                    }

                    final list = snapshot.data!;
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, idx) {
                        final item = list[idx];
                        
                        String dateStr = '';
                        if (item['startDate'].toString().isNotEmpty && item['endDate'].toString().isNotEmpty) {
                          try {
                            final start = DateTime.parse(item['startDate']);
                            final end = DateTime.parse(item['endDate']);
                            
                            final startFormatted = '${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')} ${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
                            final endFormatted = '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
                            
                            dateStr = 'Mulai: $startFormatted s/d $endFormatted';
                          } catch (_) {
                            dateStr = 'Aktif';
                          }
                        } else {
                          dateStr = 'Aktif';
                        }

                        return InkWell(
                          onTap: () {
                            Navigator.pop(context); // Close bottom sheet
                            Navigator.pushNamed(
                              context,
                              AppConstants.roomDiscussionRoute,
                              arguments: item['id'],
                            );
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: _buildHistoryItem(
                            code: item['isActive'] == true ? 'AKTIF' : 'SELESAI',
                            title: item['title'] ?? 'Rapat Tanpa Judul',
                            date: dateStr,
                            isActive: item['isActive'] == true,
                          ),
                        );
                      },
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

  Widget _buildHistoryItem({
    required String code,
    required String title,
    required String date,
    required bool isActive,
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
              color: isActive
                  ? const Color(0xFF10B981).withOpacity(0.08)
                  : const Color(0xFF64748B).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              code,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isActive ? const Color(0xFF10B981) : const Color(0xFF64748B),
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
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_rounded, color: Color(0xFF64748B), size: 18),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Content
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),

          // Custom Bottom Navigation Bar overlay with blur effect
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    border: Border(
                      top: BorderSide(
                        color: Colors.black.withOpacity(0.05),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(0, Icons.cottage_outlined, 'Home'),
                      _buildNavItem(1, Icons.storefront_outlined, 'Koperasi'),
                      _buildAddButton(),
                      _buildNavItem(3, Icons.confirmation_num_outlined, 'Voucher'),
                      _buildNavItem(4, Icons.person_pin_outlined, 'Profil'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    const Color activeColor = Color(0xFFDC2626);
    const Color inactiveColor = Color(0xFF94A3B8);

    return InkWell(
      onTap: () => _onTabTapped(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return InkWell(
      onTap: _handleMiddleButton,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        width: 52,
        height: 52,
        decoration: const BoxDecoration(
          color: Color(0xFFDC2626),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0xFFDC2626),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
