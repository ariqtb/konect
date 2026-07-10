import 'package:flutter/material.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // desa-surface
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA).withOpacity(0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shadowColor: Colors.black.withOpacity(0.05),
              elevation: 2,
            ),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Peringkat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE21E49), // desa-red
                height: 1.1,
              ),
            ),
            Text(
              'Warga',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE21E49),
                height: 1.1,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF475569)),
            onPressed: () {},
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shadowColor: Colors.black.withOpacity(0.05),
              elevation: 2,
            ),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&fit=crop',
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // UserRankCard
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE21E49), // desa-red
                borderRadius: BorderRadius.circular(24), // rounded-3xl
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE21E49).withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Peringkat Anda',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Ahmad Sulaiman',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Rank',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                '2nd',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.arrow_upward_rounded, size: 10, color: Colors.white),
                                    SizedBox(width: 2),
                                    Text(
                                      '+1',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Total Poin',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '94.2%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ResidentList Section
            const Text(
              'Warga Teraktif',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),

            // Rank Items
            _buildResidentItem(
              rank: 1,
              name: 'Ibu Rahayu',
              score: '9,850 pts',
              hasStar: true,
            ),
            const SizedBox(height: 10),
            _buildResidentItem(
              rank: 2,
              name: 'Ahmad Sulaiman',
              score: '8,450 pts',
              isCurrentUser: true,
            ),
            const SizedBox(height: 10),
            _buildResidentItem(
              rank: 3,
              name: 'Bpk. Slamet',
              score: '8,910 pts',
            ),
            const SizedBox(height: 10),
            _buildResidentItem(
              rank: 4,
              name: 'Rian',
              score: '8,230 pts',
            ),
            const SizedBox(height: 28),

            // RewardTargetSection
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF1F5F9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Target Hadiah Pribadi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Kumpulkan poin untuk hadiah pilihanmu',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.favorite_border_rounded,
                          color: Color(0xFF475569),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Gift Info Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F0), // warm stone
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.card_giftcard_rounded, color: Color(0xFF475569), size: 24),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Target Hadiah:',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF9A3412), // orange-700
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Voucher Belanja Sembako',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Progress
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '8,450 ',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE21E49),
                              ),
                            ),
                            TextSpan(
                              text: '/ 10,000 pts',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '84%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const LinearProgressIndicator(
                      value: 0.84,
                      minHeight: 8,
                      backgroundColor: Color(0xFFEEF2FF),
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE21E49)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Hint Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2), // rose-50
                      border: Border.all(color: const Color(0xFFFFE4E6)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Hanya 1,550 poin lagi untuk klaim voucher! Setoran sampah berikutnya menambah 50 poin.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9F1239),
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE21E49),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {},
                      child: const Text(
                        'Tukar Point',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResidentItem({
    required int rank,
    required String name,
    required String score,
    bool hasStar = false,
    bool isCurrentUser = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCurrentUser ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          width: isCurrentUser ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isCurrentUser ? const Color(0xFFE21E49) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isCurrentUser ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Skor: $score',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          if (hasStar)
            const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 24),
          if (isCurrentUser)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'ANDA',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
