import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/theme.dart';

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
      backgroundColor: AppColors.brandBg,
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
                      color: AppColors.brandRed,
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

  // Get theme colors and icons based on category
  Map<String, dynamic> _getCategoryData() {
    switch (category) {
      case 'Sembako':
        return {
          'text': const Color(0xFFD97706),
          'bg': const Color(0xFFFFFBEB),
          'accent': const Color(0xFFF59E0B),
          'icon': Icons.shopping_bag_outlined,
        };
      case 'Token Listrik':
        return {
          'text': const Color(0xFF2563EB),
          'bg': const Color(0xFFEFF6FF),
          'accent': const Color(0xFF3B82F6),
          'icon': Icons.electric_bolt_outlined,
        };
      case 'Pertanian':
        return {
          'text': const Color(0xFF059669),
          'bg': const Color(0xFFECFDF5),
          'accent': const Color(0xFF10B981),
          'icon': Icons.agriculture_outlined,
        };
      default:
        return {
          'text': const Color(0xFF475569),
          'bg': const Color(0xFFF8FAFC),
          'accent': const Color(0xFF64748B),
          'icon': Icons.confirmation_number_outlined,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final catData = _getCategoryData();
    const double stubWidth = 95.0;

    return Opacity(
      opacity: isActive ? 1.0 : 0.6,
      child: CustomPaint(
        foregroundPainter: TicketBorderPainter(
          color: const Color(0xFFE2E8F0),
          stubWidth: stubWidth,
          strokeWidth: 1.2,
        ),
        child: ClipPath(
          clipper: TicketClipper(stubWidth: stubWidth),
          child: Container(
            height: 120,
            color: Colors.white,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: Row(
                  children: [
                    // Main Ticket Body
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Row(
                          children: [
                            // Left Category Icon Container
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isActive ? catData['bg'] : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                catData['icon'] as IconData,
                                color: isActive ? catData['accent'] as Color : const Color(0xFF94A3B8),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Category Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isActive ? catData['bg'] : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      category.toUpperCase(),
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.8,
                                        color: isActive ? catData['text'] as Color : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // Title
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  // Expiry Date
                                  Row(
                                    children: [
                                      Icon(
                                        isActive ? Icons.access_time_rounded : Icons.lock_clock_outlined,
                                        size: 11,
                                        color: isActive ? AppColors.brandRed : const Color(0xFF94A3B8),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isActive ? 'Berlaku s.d. $expiry' : 'Sudah Ditukarkan',
                                        style: TextStyle(
                                          fontFamily: 'Outfit',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: isActive ? AppColors.brandRed : const Color(0xFF94A3B8),
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
                    ),

                    // Vertical Dashed Divider exactly where the cuts are
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(
                        7,
                        (index) => Container(
                          width: 1.5,
                          height: 4,
                          color: const Color(0xFFE2E8F0),
                        ),
                      ),
                    ),

                    // Tear-off Stub Button
                    Container(
                      width: stubWidth,
                      height: double.infinity,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isActive) ...[
                            const Icon(
                              Icons.qr_code_2_rounded,
                              size: 26,
                              color: Color(0xFF1E293B),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'GUNAKAN',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.brandRed,
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
      ),
    );
  }
}

// Custom Clipper for Ticket Cutout Shape (Cuts circular holes on top and bottom)
class TicketClipper extends CustomClipper<Path> {
  final double stubWidth;

  TicketClipper({required this.stubWidth});

  @override
  Path getClip(Size size) {
    final path = Path();
    final double cutX = size.width - stubWidth;
    final double radius = 10.0;

    path.moveTo(0.0, 0.0);
    // Top border with cutout
    path.lineTo(cutX - radius, 0.0);
    path.arcToPoint(
      Offset(cutX + radius, 0.0),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    path.lineTo(size.width, 0.0);
    
    // Right border
    path.lineTo(size.width, size.height);
    
    // Bottom border with cutout
    path.lineTo(cutX + radius, size.height);
    path.arcToPoint(
      Offset(cutX - radius, size.height),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    path.lineTo(0.0, size.height);
    
    // Left border
    path.lineTo(0.0, 0.0);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Custom Painter for Drawing Ticket Outline Borders along the Clip Path
class TicketBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double stubWidth;

  TicketBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    required this.stubWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    final double cutX = size.width - stubWidth;
    final double radius = 10.0;

    path.moveTo(0.0, 0.0);
    path.lineTo(cutX - radius, 0.0);
    path.arcToPoint(
      Offset(cutX + radius, 0.0),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    path.lineTo(size.width, 0.0);
    path.lineTo(size.width, size.height);
    path.lineTo(cutX + radius, size.height);
    path.arcToPoint(
      Offset(cutX - radius, size.height),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    path.lineTo(0.0, size.height);
    path.lineTo(0.0, 0.0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TicketBorderPainter oldDelegate) => false;
}
