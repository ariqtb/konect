import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class VoucherPage extends StatelessWidget {
  const VoucherPage({super.key});

  static const List<Map<String, dynamic>> _voucherList = [
    {
      'id': '1',
      'title': 'Voucher Sembako Rp 15.000',
      'expiry': '24 Okt 2024',
      'category': 'Sembako',
      'status': 'Aktif',
    },
    {
      'id': '2',
      'title': 'Potongan Listrik Rp 10.000',
      'expiry': '12 Nov 2024',
      'category': 'Token Listrik',
      'status': 'Aktif',
    },
    {
      'id': '3',
      'title': 'Subsidi Pupuk Organik 5kg',
      'expiry': '05 Des 2024',
      'category': 'Pertanian',
      'status': 'Aktif',
    },
    {
      'id': '4',
      'title': 'Voucher Sembako Rp 10.000',
      'expiry': '10 Jun 2024',
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
            // Header
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Text(
                'Voucher Saya',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Tukarkan voucher Anda di koperasi terdekat',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                itemCount: _voucherList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
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

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isActive ? 1.0 : 0.6,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFFFDE8E8)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.confirmation_num_outlined,
                        color: isActive
                            ? const Color(0xFFE21E49)
                            : const Color(0xFF94A3B8),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isActive ? 'Berlaku hingga: $expiry' : 'Sudah ditukarkan / Kedaluwarsa',
                            style: TextStyle(
                              fontSize: 12,
                              color: isActive ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              category,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isActive)
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFFCBD5E1),
                        size: 20,
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
