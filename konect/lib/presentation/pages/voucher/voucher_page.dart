import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class VoucherPage extends StatelessWidget {
  const VoucherPage({super.key});

  static const List<Map<String, dynamic>> _voucherList = [
    {
      'id': '1',
      'title': 'Voucher Sembako Rp 15.000',
      'expiry': '24 Okt 2026',
      'category': 'Sembako',
      'status': 'Aktif',
    },
    {
      'id': '2',
      'title': 'Potongan Listrik Rp 10.000',
      'expiry': '12 Nov 2026',
      'category': 'Token Listrik',
      'status': 'Aktif',
    },
    {
      'id': '3',
      'title': 'Subsidi Pupuk Organik 5kg',
      'expiry': '05 Des 2026',
      'category': 'Pertanian',
      'status': 'Aktif',
    },
    {
      'id': '4',
      'title': 'Voucher Sembako Rp 10.000',
      'expiry': '10 Jun 2026',
      'category': 'Sembako',
      'status': 'Terpakai',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Voucher Saya',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Klaim subsidi & sembako dari Koperasi Desa',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Icon(
                      Icons.confirmation_number_outlined,
                      color: Color(0xFFE21E49),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // List of Vouchers
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                itemCount: _voucherList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final voucher = _voucherList[index];
                  final isActive = voucher['status'] == 'Aktif';
                  return _VoucherCard(
                    title: voucher['title'],
                    expiry: voucher['expiry'],
                    category: voucher['category'],
                    isActive: isActive,
                    onTap: isActive
                        ? () => Navigator.pushNamed(context, AppConstants.redeemRoute)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoucherCard extends StatelessWidget {
  final String title;
  final String expiry;
  final String category;
  final bool isActive;
  final VoidCallback? onTap;

  const _VoucherCard({
    required this.title,
    required this.expiry,
    required this.category,
    required this.isActive,
    this.onTap,
  });

  // Get theme colors based on category
  Map<String, Color> _getCategoryColors() {
    switch (category) {
      case 'Sembako':
        return {
          'text': const Color(0xFFD97706), // Amber-600
          'bg': const Color(0xFFFFFBEB), // Amber-50
          'accent': const Color(0xFFF59E0B), // Amber-500
        };
      case 'Token Listrik':
        return {
          'text': const Color(0xFF2563EB), // Blue-600
          'bg': const Color(0xFFEFF6FF), // Blue-50
          'accent': const Color(0xFF3B82F6), // Blue-500
        };
      case 'Pertanian':
        return {
          'text': const Color(0xFF059669), // Emerald-600
          'bg': const Color(0xFFECFDF5), // Emerald-50
          'accent': const Color(0xFF10B981), // Emerald-500
        };
      default:
        return {
          'text': const Color(0xFF475569), // Slate-600
          'bg': const Color(0xFFF8FAFC), // Slate-50
          'accent': const Color(0xFF64748B), // Slate-500
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColors = _getCategoryColors();

    return Opacity(
      opacity: isActive ? 1.0 : 0.6,
      child: Container(
        height: 125,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Row(
                children: [
                  // Left color bar indicating category
                  Container(
                    width: 8,
                    height: double.infinity,
                    color: isActive ? catColors['accent'] : const Color(0xFFCBD5E1),
                  ),
                  
                  // Main Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Category Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: isActive ? catColors['bg'] : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              category.toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: isActive ? catColors['text'] : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Title
                          Text(
                            title,
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          // Expiry / Info
                          Row(
                            children: [
                              Icon(
                                isActive ? Icons.access_time_rounded : Icons.lock_clock_outlined,
                                size: 12,
                                color: isActive ? const Color(0xFFE21E49) : const Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isActive ? 'Berlaku s.d. $expiry' : 'Sudah Ditukarkan',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isActive ? const Color(0xFFE21E49) : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Symmetrical Dashed Stub Divider
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(
                      8,
                      (index) => Container(
                        width: 1.5,
                        height: 5,
                        color: const Color(0xFFE2E8F0),
                      ),
                    ),
                  ),

                  // Right Stub Button
                  Container(
                    width: 95,
                    height: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isActive) ...[
                          const Icon(
                            Icons.qr_code_2_rounded,
                            size: 24,
                            color: Color(0xFF1E293B),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'GUNAKAN',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE21E49),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ] else ...[
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 24,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'SELESAI',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
