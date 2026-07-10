import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../../blocs/auth/auth_bloc.dart';
import '../../../data/repositories/leaderboard_repository.dart';
import '../../../data/models/leaderboard_user.dart';
import '../../../data/repositories/cooperative_repository.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showLoginForm = false;
  
  int _userPoints = 0;
  int _userRoomsCount = 0;
  bool _loadingStats = false;
  String? _lastUserId;
  String? _adminCoopName;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserStats(String userId) async {
    if (_lastUserId == userId && _userPoints != 0) return;
    _lastUserId = userId;
    
    final authState = context.read<AuthBloc>().state;
    
    setState(() => _loadingStats = true);
    try {
      final client = sp.Supabase.instance.client;
      
      final leaderboard = await leaderboardRepository.getLeaderboard();
      final currentUser = leaderboard.firstWhere(
        (u) => u.isCurrentUser,
        orElse: () => const LeaderboardUser(id: '', name: '', score: 0, rank: 0, isCurrentUser: false),
      );
      
      final roomPartCount = await client
          .from('room_participants')
          .select()
          .eq('user_id', userId);
      
      final count = (roomPartCount as List).length;

      String? coopName;
      if (authState is AuthAuthenticated &&
          (authState.user.role == 'admin' || authState.user.role == 'kopdes')) {
        final coopId = await cooperativeRepository.getAdminCooperative(userId);
        final coop = await client
            .from('cooperatives')
            .select('name')
            .eq('id', coopId)
            .maybeSingle();
        coopName = coop?['name'] ?? 'Koperasi Terkait';
      }

      if (mounted) {
        setState(() {
          _userPoints = currentUser.score;
          _userRoomsCount = count;
          _adminCoopName = coopName;
          _loadingStats = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingStats = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
            if (state is AuthAuthenticated) {
              _loadUserStats(state.user.id);
            }
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final bool isLoggedIn = state is AuthAuthenticated;
              final String name = isLoggedIn ? state.user.name : 'Tamu (Guest)';
              final String emailOrMac = isLoggedIn ? state.user.email : 'MAC: 02:42:AC:11:00:02';
              final String role = isLoggedIn ? state.user.role.toUpperCase() : 'MASYARAKAT';
              final String? avatarUrl = isLoggedIn ? state.user.avatarUrl : null;
              final bool isKopdesOrAdmin = isLoggedIn && (state.user.role == 'admin' || state.user.role == 'kopdes');

              if (isLoggedIn) {
                _loadUserStats(state.user.id);
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const Text(
                      'Profil Saya',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Profile Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Avatar
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFF8FAFC),
                                  border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                                ),
                                child: CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                                  child: avatarUrl == null
                                      ? const Icon(
                                          Icons.person_outline,
                                          color: Color(0xFF64748B),
                                          size: 34,
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // User Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      emailOrMac,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF64748B),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    // Role Badge
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            role,
                                            style: const TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF475569),
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (_adminCoopName != null) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.storefront_outlined, size: 14, color: Color(0xFF64748B)),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              _adminCoopName!,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF475569),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Divider(color: Color(0xFFF1F5F9), height: 1),
                          const SizedBox(height: 20),

                          // Stats Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(Icons.emoji_events_outlined, '$_userPoints Pts', 'Poin', const Color(0xFF475569)),
                              _buildStatDivider(),
                              _buildStatItem(Icons.forum_outlined, '$_userRoomsCount Rapat', 'Diskusi', const Color(0xFF475569)),
                              _buildStatDivider(),
                              _buildStatItem(Icons.storefront_outlined, isKopdesOrAdmin ? 'Pengurus' : 'Warga', 'Status', const Color(0xFF475569)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Menu Section Header
                    const Text(
                      'PENGATURAN APLIKASI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Settings Menu Group Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.01),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: Icons.notifications_none_rounded,
                            title: 'Notifikasi',
                            subtitle: 'Pemberitahuan berita, rapat & voting',
                            iconBgColor: const Color(0xFFEEF2F6),
                            iconColor: const Color(0xFF475569),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Divider(color: Color(0xFFF1F5F9), height: 1),
                          ),
                          _buildMenuItem(
                            icon: Icons.security_outlined,
                            title: 'Keamanan Akun',
                            subtitle: 'Kelola data pribadi & akses perangkat',
                            iconBgColor: const Color(0xFFEEF2F6),
                            iconColor: const Color(0xFF475569),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Divider(color: Color(0xFFF1F5F9), height: 1),
                          ),
                          _buildMenuItem(
                            icon: Icons.help_outline_rounded,
                            title: 'Bantuan & FAQ',
                            subtitle: 'Panduan lengkap penggunaan aplikasi Konect',
                            iconBgColor: const Color(0xFFEEF2F6),
                            iconColor: const Color(0xFF475569),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Actions (Login / Logout / Admin Toggle)
                    if (!isKopdesOrAdmin) ...[
                      // Admin Login section words
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _showLoginForm = !_showLoginForm;
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pengurus Koperasi / Admin?',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Masuk dengan akun terdaftar di sini',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                _showLoginForm ? Icons.expand_less : Icons.expand_more,
                                color: const Color(0xFFDC2626),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (_showLoginForm) ...[
                        // Form login for Admin
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              TextField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icon(Icons.lock_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFDC2626),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (_emailController.text.trim().isNotEmpty &&
                                        _passwordController.text.trim().isNotEmpty) {
                                      context.read<AuthBloc>().add(
                                            AuthLoginRequested(
                                              email: _emailController.text.trim(),
                                              password: _passwordController.text.trim(),
                                            ),
                                          );
                                    }
                                  },
                                  child: const Text(
                                    'Masuk',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                    
                    if (isKopdesOrAdmin) ...[
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                            side: const BorderSide(color: Color(0xFFFCA5A5)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            context.read<AuthBloc>().add(AuthLogoutRequested());
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Keluar Akun',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color accentColor) {
    return Column(
      children: [
        Icon(icon, color: accentColor, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 36,
      color: const Color(0xFFE2E8F0),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
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
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
