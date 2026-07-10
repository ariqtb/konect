import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/theme.dart';

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
    },
    {
      'title': 'Voucher Token Listrik Rp 20.000',
      'points': '2.000',
      'badge': '',
      'badgeColor': Colors.transparent,
      'image': 'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?auto=format&fit=crop&q=80&w=400',
      'desc': 'Potongan langsung untuk pembelian token listrik prabayar melalui koperasi.',
    },
    {
      'title': 'Voucher Belanja Koperasi',
      'points': '3.000',
      'badge': 'Spesial',
      'badgeColor': const Color(0xFF494BD6),
      'image': 'https://images.unsplash.com/photo-1578916171728-46686eac8d58?auto=format&fit=crop&q=80&w=400',
      'desc': 'Belanja kebutuhan sehari-hari di unit toko koperasi desa.',
    },
    {
      'title': 'Paket Internet Desa 24 Jam',
      'points': '500',
      'badge': '',
      'badgeColor': Colors.transparent,
      'image': 'https://images.unsplash.com/photo-1605810230434-7631ac76ec81?auto=format&fit=crop&q=80&w=400',
      'desc': 'Akses internet desa selama 24 jam penuh.',
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

  void _showVoucherDetail(Map<String, dynamic> data, {bool isOwned = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _VoucherDetailSheet(
        data: data,
        isOwned: isOwned,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        const Text(
                          '4.250 Pts',
                          style: TextStyle(
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

              // Tabs
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.brandRed, width: 1.5),
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
              const SizedBox(height: 24),

              // Category chips (only for Tersedia tab)
              if (_isAvailableSelected) ...[
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = _selectedCategory == cat;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.brandRed : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected 
                                  ? AppColors.brandRed 
                                  : AppColors.brandRed.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : AppColors.brandRed,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.68,
                ),
                itemCount: _isAvailableSelected
                    ? _availableVouchers.length
                    : _ownedVouchers.length,
                itemBuilder: (context, index) {
                  if (_isAvailableSelected) {
                    final v = _availableVouchers[index];
                    return _buildAvailableCard(v);
                  } else {
                    final v = _ownedVouchers[index];
                    return _buildOwnedCard(v);
                  }
                },
              ),
              const SizedBox(height: 40),

              // CTA banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFC7D2FE), width: 1.5),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.volunteer_activism, size: 36, color: Color(0xFF818CF8)),
                    const SizedBox(height: 12),
                    const Text(
                      'Ingin Poin Lebih Banyak?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brandNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ikuti kegiatan gotong royong warga atau bayar iuran tepat waktu untuk mendapatkan bonus poin harian!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.slate500,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Pelajari Selengkapnya',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brandRed,
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
              color: isActive ? Colors.white : AppColors.brandRed,
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
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.slate100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      image: DecorationImage(
                        image: NetworkImage(data['image']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if ((data['badge'] as String).isNotEmpty)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: data['badgeColor'] as Color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          (data['badge'] as String).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
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
            // Content
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['title'] as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brandNavy,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.stars, color: AppColors.brandRed, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${data['points']} Pts',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.brandRed,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showVoucherDetail(data),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandRed,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text(
                          'Tukar',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.slate100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      image: DecorationImage(
                        image: NetworkImage(data['image'] as String),
                        fit: BoxFit.cover,
                        colorFilter: isActive
                            ? null
                            : ColorFilter.mode(
                                Colors.black.withValues(alpha: 0.4),
                                BlendMode.darken,
                              ),
                      ),
                    ),
                    foregroundDecoration: isActive
                        ? null
                        : const BoxDecoration(
                            color: Colors.grey,
                            backgroundBlendMode: BlendMode.saturation,
                          ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isActive
                            ? data['statusColor'] as Color
                            : Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        (data['status'] as String).toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: isActive ? Colors.white : AppColors.slate500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['title'] as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brandNavy,
                        height: 1.2,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isActive
                            ? () => _showVoucherDetail(data, isOwned: true)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isActive
                              ? AppColors.brandRed
                              : AppColors.slate100,
                          foregroundColor: isActive
                              ? Colors.white
                              : AppColors.slate400,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(
                          isActive ? 'Gunakan' : 'Selesai',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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

  const _VoucherDetailSheet({required this.data, this.isOwned = false});

  @override
  State<_VoucherDetailSheet> createState() => _VoucherDetailSheetState();
}

class _VoucherDetailSheetState extends State<_VoucherDetailSheet> {
  bool _isProcessing = false;

  void _handleRedeem() {
    setState(() => _isProcessing = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voucher berhasil ditukar!')),
      );
    });
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
