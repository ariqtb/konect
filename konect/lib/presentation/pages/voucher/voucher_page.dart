import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../core/services/supabase_service.dart';
import '../../blocs/auth/auth_bloc.dart';

class VoucherPage extends StatefulWidget {
  const VoucherPage({super.key});

  @override
  State<VoucherPage> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  bool _isAvailableSelected = true;
  String _selectedCategory = 'Semua';

  final List<String> _categories = ['Semua', 'Sembako', 'Listrik', 'Hiburan'];

  final List<Map<String, dynamic>> _availableVouchers = [
    {
      'title': 'Voucher Sembako Rp 15.000',
      'points': '1.500',
      'badge': 'Populer',
      'badgeColor': const Color(0xFFDC2626),
      'image': 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=400',
      'desc': 'Voucher ini dapat digunakan untuk pembelian sembako (beras, minyak, telur) di seluruh unit Koperasi Desa Makmur Jaya.',
      'category': 'Sembako',
    },
    {
      'title': 'Voucher Token Listrik Rp 20.000',
      'points': '2.000',
      'badge': '',
      'badgeColor': Colors.transparent,
      'image': 'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?auto=format&fit=crop&q=80&w=400',
      'desc': 'Potongan langsung untuk pembelian token listrik prabayar melalui koperasi.',
      'category': 'Listrik',
    },
    {
      'title': 'Voucher Belanja Koperasi',
      'points': '3.000',
      'badge': 'Spesial',
      'badgeColor': const Color(0xFF494BD6),
      'image': 'https://images.unsplash.com/photo-1578916171728-46686eac8d58?auto=format&fit=crop&q=80&w=400',
      'desc': 'Belanja kebutuhan sehari-hari di unit toko koperasi desa.',
      'category': 'Sembako',
    },
    {
      'title': 'Paket Internet Desa 24 Jam',
      'points': '500',
      'badge': '',
      'badgeColor': Colors.transparent,
      'image': 'https://images.unsplash.com/photo-1605810230434-7631ac76ec81?auto=format&fit=crop&q=80&w=400',
      'desc': 'Akses internet desa selama 24 jam penuh.',
      'category': 'Hiburan',
    },
  ];

  final List<Map<String, dynamic>> _ownedVouchers = [
    {
      'title': 'Voucher Sembako Rp 15.000',
      'status': 'Aktif',
      'statusColor': const Color(0xFF10B981),
      'image': 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=400',
      'isActive': true,
      'desc': 'Voucher ini dapat digunakan untuk pembelian sembako (beras, minyak, telur) di seluruh unit Koperasi Desa Makmur Jaya.',
    },
    {
      'title': 'Token Listrik Rp 20.000',
      'status': 'Digunakan',
      'statusColor': const Color(0xFF94A3B8),
      'image': 'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?auto=format&fit=crop&q=80&w=400',
      'isActive': false,
      'desc': 'Potongan langsung untuk pembelian token listrik prabayar.',
    },
  ];

  int _points = 0;
  List<Map<String, dynamic>> _vouchersFromDb = [];
  List<Map<String, dynamic>> _ownedVouchersFromDb = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  int _uuidToBigInt(String uuid) {
    int hash = 0;
    for (int i = 0; i < uuid.length; i++) {
      hash = (hash * 31 + uuid.codeUnitAt(i)) % 9007199254740991;
    }
    return hash;
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final client = SupabaseService().client;
      final authState = context.read<AuthBloc>().state;
      String userId = 'guest';
      if (authState is AuthAuthenticated) {
        userId = authState.user.id;
      } else {
        final currentSessionUser = client.auth.currentUser;
        if (currentSessionUser != null) {
          userId = currentSessionUser.id;
        }
      }
      final bigIntId = _uuidToBigInt(userId);

      // Fetch points from users table
      final userData = await client
          .from('users')
          .select('points')
          .eq('uuid', bigIntId)
          .maybeSingle();
      
      int pts = 0;
      if (userData != null) {
        pts = userData['points'] as int? ?? 0;
      }

      if (mounted) {
        setState(() {
          _points = pts;
          _vouchersFromDb = _availableVouchers;
          _ownedVouchersFromDb = _ownedVouchers;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('[VoucherPage._loadData] ERROR: $e');
      if (mounted) {
        setState(() {
          _points = 4250;
          _vouchersFromDb = _availableVouchers;
          _ownedVouchersFromDb = _ownedVouchers;
          _isLoading = false;
        });
      }
    }
  }

  String _formatPoints(int points) {
    return points.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void _showVoucherDetail(Map<String, dynamic> data, {bool isOwned = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _VoucherDetailSheet(
        data: data,
        isOwned: isOwned,
        userPoints: _points,
        onRedeemSuccess: _loadData,
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Pilih Kategori',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const Divider(color: Color(0xFFF1F5F9), height: 1),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = _selectedCategory == cat;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedCategory = cat;
                            });
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  cat,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? AppColors.brandRed : const Color(0xFF0F172A),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_rounded,
                                    color: AppColors.brandRed,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.brandBg,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.brandRed,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.brandBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Voucher Tersedia',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.brandRed,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),

              // Points Hero
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF991B1B), AppColors.brandRed],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL POIN ANDA',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatPoints(_points)} Pts',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Warga Aktif',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, AppConstants.redeemRoute);
                          },
                          child: Row(
                            children: [
                              Text(
                                'Riwayat',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                size: 16,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tab & Filter Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _buildTabButton('Tersedia', _isAvailableSelected, () {
                            setState(() => _isAvailableSelected = true);
                          }),
                          _buildTabButton('Milik Saya', !_isAvailableSelected, () {
                            setState(() => _isAvailableSelected = false);
                          }),
                        ],
                      ),
                    ),
                  ),
                  if (_isAvailableSelected) ...[
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _showFilterBottomSheet(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          color: _selectedCategory == 'Semua' 
                              ? const Color(0xFF475569) 
                              : AppColors.brandRed,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),

              // Grid
              Builder(
                builder: (context) {
                  final filteredVouchers = _isAvailableSelected
                      ? _vouchersFromDb.where((v) => _selectedCategory == 'Semua' || v['category'] == _selectedCategory).toList()
                      : _ownedVouchersFromDb;

                  if (filteredVouchers.isEmpty) {
                    return SizedBox(
                      height: 200,
                      child: Center(
                        child: Text(
                          'Tidak ada voucher untuk kategori "$_selectedCategory"',
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: filteredVouchers.length,
                    itemBuilder: (context, index) {
                      final v = filteredVouchers[index];
                      if (_isAvailableSelected) {
                        return _buildAvailableCard(v);
                      } else {
                        return _buildOwnedCard(v);
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 40),

              // CTA banner (Monochrome & Clean)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 32, color: Color(0xFF64748B)),
                    const SizedBox(height: 12),
                    const Text(
                      'Ingin Poin Lebih Banyak?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ikuti kegiatan gotong royong warga atau bayar iuran tepat waktu untuk mendapatkan bonus poin harian!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => _showPointsInfoModal(context),
                      child: const Text(
                        'Pelajari Selengkapnya',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          decoration: TextDecoration.underline,
                        ),
                      ),
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

  void _showPointsInfoModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pull bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Cara Mendapatkan Poin',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Anda dapat mengumpulkan poin keaktifan dengan berpartisipasi aktif dalam kegiatan koperasi dan diskusi desa. Berikut rincian poin yang didapatkan:',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              
              // Points details list
              _buildPointInfoRow(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Berikan Pendapat',
                description: 'Berikan gagasan atau pendapat baru pada forum diskusi rapat aktif.',
                points: '+10 Poin',
              ),
              const SizedBox(height: 16),
              _buildPointInfoRow(
                icon: Icons.thumb_up_alt_outlined,
                title: 'Pendapat Mendapat Vote',
                description: 'Pendapat yang Anda berikan disukai atau mendapat dukungan/vote dari warga lain.',
                points: '+10 Poin',
              ),
              const SizedBox(height: 16),
              _buildPointInfoRow(
                icon: Icons.volunteer_activism_outlined,
                title: 'Partisipasi Kegiatan',
                description: 'Terlibat dalam kegiatan gotong royong fisik atau pembayaran iuran tepat waktu.',
                points: '+20 Poin',
              ),
              
              const SizedBox(height: 32),
              
              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B), // slate-800
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Mengerti',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPointInfoRow({
    required IconData icon,
    required String title,
    required String description,
    required String points,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9), // slate-100
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF475569)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Text(
          points,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.brandRed : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableCard(Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () => _showVoucherDetail(data),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  data['image'],
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data['title'] as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        height: 1.3,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.stars_rounded, color: Color(0xFFDC2626), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${data['points']} Pts',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_forward_rounded, color: Color(0xFF94A3B8), size: 14),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnedCard(Map<String, dynamic> data) {
    final bool isActive = data['isActive'] as bool;

    return GestureDetector(
      onTap: () => _showVoucherDetail(data, isOwned: true),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  data['image'] as String,
                  fit: BoxFit.cover,
                  color: isActive ? null : Colors.black.withOpacity(0.4),
                  colorBlendMode: isActive ? null : BlendMode.darken,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data['title'] as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isActive ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                        height: 1.3,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFFECFDF5) // emerald-50
                                : const Color(0xFFF1F5F9), // slate-100
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isActive ? 'Tersedia' : 'Selesai',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isActive
                                  ? const Color(0xFF059669) // emerald-600
                                  : const Color(0xFF64748B), // slate-500
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_rounded, color: Color(0xFF94A3B8), size: 14),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Detail Bottom Sheet (replaces the separate page)
// ─────────────────────────────────────────────
class _VoucherDetailSheet extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool isOwned;
  final int userPoints;
  final VoidCallback onRedeemSuccess;

  const _VoucherDetailSheet({
    required this.data,
    this.isOwned = false,
    required this.userPoints,
    required this.onRedeemSuccess,
  });

  @override
  State<_VoucherDetailSheet> createState() => _VoucherDetailSheetState();
}

class _VoucherDetailSheetState extends State<_VoucherDetailSheet> {
  bool _isProcessing = false;

  int _uuidToBigInt(String uuid) {
    int hash = 0;
    for (int i = 0; i < uuid.length; i++) {
      hash = (hash * 31 + uuid.codeUnitAt(i)) % 9007199254740991;
    }
    return hash;
  }

  void _handleRedeem() async {
    final pointsRequired = int.tryParse(widget.data['points']?.toString().replaceAll('.', '') ?? '0') ?? 0;
    
    if (widget.userPoints < pointsRequired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Poin Anda tidak mencukupi untuk menukar voucher ini.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final client = SupabaseService().client;
      final authState = context.read<AuthBloc>().state;
      String userId = 'guest';
      if (authState is AuthAuthenticated) {
        userId = authState.user.id;
      } else {
        final currentSessionUser = client.auth.currentUser;
        if (currentSessionUser != null) {
          userId = currentSessionUser.id;
        }
      }
      final bigIntId = _uuidToBigInt(userId);

      // 1. Deduct points from users table
      final newPoints = widget.userPoints - pointsRequired;
      await client
          .from('users')
          .update({'points': newPoints})
          .eq('uuid', bigIntId);

      // 2. Insert into voucher_redemptions
      final voucherId = widget.data['id'] ?? '00000000-0000-0000-0000-000000000101';
      final int uniqueHash = (widget.data['title'].toString().hashCode).abs() % 1000;
      final String voucherCode = 'VX-$uniqueHash-KNC-${10 + (widget.data['points'].toString().hashCode % 90).abs()}';

      await client.from('voucher_redemptions').insert({
        'voucher_id': voucherId,
        'user_id': userId,
        'qr_code_used': voucherCode,
        'status': 'pending',
      });

      if (!mounted) return;
      setState(() => _isProcessing = false);
      Navigator.pop(context);

      widget.onRedeemSuccess();

      Navigator.pushNamed(
        context,
        '/redeem-voucher',
        arguments: {
          'title': widget.data['title'] ?? 'Voucher Belanja',
          'points': widget.data['points'] ?? '1.500',
          'code': voucherCode,
          'expiry': '30 Hari dari Sekarang',
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voucher berhasil ditukar!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      print('[VoucherPage._handleRedeem] ERROR: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menukar voucher: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final isActive = data['isActive'] as bool? ?? true;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.slate300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  children: [
                    // Hero Image
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(data['image'] as String),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          if (!widget.isOwned)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981)
                                      .withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'TERSEDIA',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          if (widget.isOwned)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? const Color(0xFF10B981)
                                      : AppColors.slate400,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  ((data['status'] as String?) ?? 'Aktif')
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      data['title'] as String,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brandNavy,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Points (only for available)
                    if (!widget.isOwned)
                      Row(
                        children: [
                          const Icon(Icons.stars,
                              color: AppColors.brandRed, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            '${data['points']} Pts',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.brandRed,
                            ),
                          ),
                        ],
                      ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(color: AppColors.slate200, height: 1),
                    ),

                    // Deskripsi
                    const Text(
                      'Deskripsi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brandNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['desc'] as String? ??
                          'Voucher ini dapat digunakan di seluruh unit Koperasi Desa.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.slate500,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Syarat & Ketentuan
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.slate50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.slate100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outline,
                                  size: 18, color: AppColors.slate500),
                              SizedBox(width: 8),
                              Text(
                                'Syarat & Ketentuan',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.brandNavy,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _termItem('1', 'Berlaku untuk satu kali transaksi.'),
                          const SizedBox(height: 6),
                          _termItem('2', 'Tidak dapat diuangkan.'),
                          const SizedBox(height: 6),
                          _termItem(
                              '3', 'Tunjukkan QR code saat pembayaran.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),

              // Sticky bottom button
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: AppColors.slate100, width: 1),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (widget.isOwned && !isActive)
                          ? null
                          : (_isProcessing ? null : _handleRedeem),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandRed,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.slate100,
                        disabledForegroundColor: AppColors.slate400,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.isOwned
                                  ? (isActive ? 'Gunakan' : 'Selesai')
                                  : 'Tukar Sekarang',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _termItem(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$number.',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.brandRed,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.slate500,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
