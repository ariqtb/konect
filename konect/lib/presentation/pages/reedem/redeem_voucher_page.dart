import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/ticket_card.dart';

class RedeemVoucherPage extends StatelessWidget {
  final Map<String, dynamic> voucherData;

  const RedeemVoucherPage({super.key, required this.voucherData});

  @override
  Widget build(BuildContext context) {
    final title = voucherData['title'] ?? 'Voucher Belanja';
    final code = voucherData['code'] ?? 'VX-982-SML-71';
    final expiry = voucherData['expiry'] ?? '30 Hari dari Sekarang';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tukar Voucher',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ticket Card Wrapper
            TicketCard(
              notchRatio: 0.8,
              borderRadius: 16,
              notchRadius: 10,
              backgroundColor: Colors.white,
              borderColor: const Color(0xFFF1F5F9),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text(
                        'Berhasil Ditukar',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Voucher Title
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // QR Code Container
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Column(
                        children: [
                          QrImageView(
                            data: code,
                            version: QrVersions.auto,
                            size: 180.0,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: Color(0xFF1E293B),
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            code,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Instruction Tip text
                    const Text(
                      'Tunjukkan QR ini ke pengurus koperasi untuk klaim',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    
                    const SizedBox(height: 50),
                    
                    // Expiry Info Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Berlaku hingga: ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          expiry,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Save to Gallery Button
            CustomButton(
              text: 'Simpan ke Galeri',
              isPrimary: false,
              icon: Icons.download_rounded,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Voucher disimpan ke galeri...')),
                );
              },
            ),
            const SizedBox(height: 32),

            // How To Redeem Section
            const Text(
              'Cara Penukaran',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 20),
            
            // Steps
            _buildRedemptionStep(
              number: '1',
              title: 'Datang ke Koperasi',
              description: 'Kunjungi kantor Koperasi Desa VoxSilent pada jam operasional (08:00 - 16:00).',
            ),
            const SizedBox(height: 20),
            _buildRedemptionStep(
              number: '2',
              title: 'Scan QR',
              description: 'Tunjukkan kode QR di atas kepada petugas untuk divalidasi melalui sistem desa.',
            ),
            const SizedBox(height: 20),
            _buildRedemptionStep(
              number: '3',
              title: 'Terima Voucher',
              description: 'Setelah validasi sukses, Anda akan menerima fisik voucher atau potongan harga langsung.',
            ),
            const SizedBox(height: 32),

            // Footer Support Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xFF475569),
                  ),
                  children: [
                    TextSpan(text: 'Ada kendala? Hubungi Admin melalui menu '),
                    TextSpan(
                      text: 'Pesan',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                    TextSpan(text: ' atau kunjungi kantor Balai Desa.'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRedemptionStep({
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Number badge
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFF1E293B),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Text details
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
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
