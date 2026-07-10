import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import 'home/home_page.dart';
import 'koperasi/koperasi_page.dart';
import 'voucher/voucher_page.dart';
import 'profile/profile_page.dart';
import '../../core/constants.dart';

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
      // Buka halaman room baru (admin create/update room)
      Navigator.pushNamed(context, '/create-room');
    } else {
      // Tampilkan bottom sheet modal riwayat room
      _showRoomHistoryModal();
    }
  }

  void _showRoomHistoryModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
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
                  'Daftar ruang diskusi yang pernah Anda masuki dari perangkat ini.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // History list
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _buildHistoryItem(
                      code: '09IO08',
                      title: 'Barang Belanja Koperasi Periode Juli',
                      date: 'Hari ini, 14:20',
                    ),
                    const SizedBox(height: 10),
                    _buildHistoryItem(
                      code: '12TR90',
                      title: 'Diskusi Rencana Panel Surya Dusun 2',
                      date: 'Kemarin, 09:15',
                    ),
                    const SizedBox(height: 10),
                    _buildHistoryItem(
                      code: '04OP55',
                      title: 'Evaluasi Pembagian Sembako Murah',
                      date: '3 Juli 2026',
                    ),
                  ],
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
                const SizedBox(height: 2),
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
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF64748B), size: 18),
            onPressed: () {
              Navigator.pop(context); // Close sheet
              Navigator.pushNamed(context, AppConstants.roomDiscussionRoute);
            },
          ),
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
