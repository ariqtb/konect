import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class RedeemHistoryPage extends StatefulWidget {
  const RedeemHistoryPage({super.key});

  @override
  State<RedeemHistoryPage> createState() => _RedeemHistoryPageState();
}

class _RedeemHistoryPageState extends State<RedeemHistoryPage> {
  String _selectedTab = 'Semua';

  final List<Map<String, dynamic>> _transactions = [
    {
      'title': 'Bonus Gotong Royong RT 04',
      'time': '24 Okt 2024 • 09:15',
      'points': '+50',
      'type': 'Masuk',
      'icon': Icons.handshake_outlined,
      'isEarning': true,
    },
    {
      'title': 'Tukar Voucher Beras 5kg',
      'time': '22 Okt 2024 • 14:30',
      'points': '-1.500',
      'type': 'Keluar',
      'icon': Icons.shopping_bag_outlined,
      'isEarning': false,
    },
    {
      'title': 'Donasi Bank Sampah Desa',
      'time': '20 Okt 2024 • 08:00',
      'points': '+120',
      'type': 'Masuk',
      'icon': Icons.volunteer_activism_outlined,
      'isEarning': true,
    },
    {
      'title': 'Bayar Iuran Keamanan',
      'time': '15 Okt 2024 • 18:20',
      'points': '-200',
      'type': 'Keluar',
      'icon': Icons.receipt_long_outlined,
      'isEarning': false,
    },
    {
      'title': 'Juara 1 Kebersihan Lingkungan',
      'time': '10 Okt 2024 • 10:00',
      'points': '+500',
      'type': 'Masuk',
      'icon': Icons.emoji_events_outlined,
      'isEarning': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = _transactions.where((tx) {
      if (_selectedTab == 'Semua') return true;
      return tx['type'] == _selectedTab;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.brandBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.brandRed),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Riwayat Poin',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.brandNavy,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF64748B)),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Poin Saat Ini',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text(
                        '4.250',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brandRed,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Pts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brandRed.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5), // Light Green
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.trending_up, size: 16, color: Color(0xFF10B981)),
                        SizedBox(width: 4),
                        Text(
                          '+12% Bulan Ini',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Segmented Control (Tabs)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildTabButton('Semua'),
                  _buildTabButton('Masuk'),
                  _buildTabButton('Keluar'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Transaction List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Aktivitas Terakhir',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brandNavy,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mengunduh laporan...')),
                    );
                  },
                  child: const Text(
                    'Unduh Laporan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandRed,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Items
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredTransactions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final tx = filteredTransactions[index];
                return _buildTransactionItem(tx);
              },
            ),
            const SizedBox(height: 24),

            // Load More
            Center(
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.expand_more, size: 18, color: Color(0xFF94A3B8)),
                label: const Text(
                  'Lihat transaksi lebih lama',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label) {
    final bool isActive = _selectedTab == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isActive ? AppColors.brandNavy : AppColors.slate500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> tx) {
    final bool isEarning = tx['isEarning'] as bool;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              tx['icon'] as IconData,
              color: AppColors.brandNavy,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx['title'] as String,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brandNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tx['time'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                tx['points'] as String,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isEarning ? const Color(0xFF10B981) : AppColors.brandRed,
                ),
              ),
              const Text(
                'Pts',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
