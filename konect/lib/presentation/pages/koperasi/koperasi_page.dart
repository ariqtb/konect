import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/theme.dart';

class KoperasiPage extends StatefulWidget {
  const KoperasiPage({super.key});

  @override
  State<KoperasiPage> createState() => _KoperasiPageState();
}

class _KoperasiPageState extends State<KoperasiPage> {
  int _selectedCategoryIndex = 0;

  final List<String> _categories = [
    'Semua',
    'Sembako',
    'Token Listrik',
    'Pertanian',
  ];

  static const List<Map<String, dynamic>> _koperasiList = [
    {
      'id': '1',
      'name': 'Koperasi Tani Sukamaju',
      'address': 'Jl. Raya Desa Sukamaju No. 12',
      'distance': '1.2 km',
      'isOpen': true,
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDFoJgR2qD9tq72e1s2tG3h5k9s82H2v8L7m3y5q8s9t2v8c8L3y5s8H2v8L7m3y5s8=w400-h200-c',
      'category': 'Pertanian',
    },
    {
      'id': '2',
      'name': 'Koperasi Sembako Mulia',
      'address': 'Dusun Krajan RT 02/RW 01',
      'distance': '2.5 km',
      'isOpen': true,
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCK1yMQNzemgA8JjbukSWJhytq4ApsMrjwUF-GBeHOIrZ7qhoh945cfdFZWK5ryUh_quzDE2XS3AXfiCTlGOB7wT9LFHOW0iGlTlQMQuCNCT0VebWkqGOdGKNOiapzU814uROyR7rwGLMAw_1y9A_6dsahL0HaLcm4LFp5MckXxjnrle_wOiRd4xIQeDPM7k4Qm8uDfQMMvbsyp3uF6jKavR9mgwkud_3wIQWLMs8e2EhZccGCcJbh6VsuOXLllWVEWKkU=w400-h200-c',
      'category': 'Sembako',
    },
    {
      'id': '3',
      'name': 'Koperasi Listrik Desa',
      'address': 'Jl. Balai Desa RT 04/RW 02',
      'distance': '3.1 km',
      'isOpen': false,
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCKj0KyglLbOn2DNZtnYMsq9ynlR1zolGnlJFH_Wi5WD4UFDg61Ko5G0p_9-k8CGSHESAEm6ruFwuqZ_FeYobQJ8ZByPooIyVDKFdMzvvtBo6LWVoBA-Zg-Zh2dCoTOPIiFAuUIms3rKcoYv_fDc_O3VNQsX5BL_SieaMawl9qyZFkmKNXcN2N3EMXBEktJ3UskUHFo055njg4PkXRI3WfbsTcqT4hRBJrIKFnrdk4h6cxtTGMKTL4PS_C8XOFCMztcx00=w400-h200-c',
      'category': 'Token Listrik',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter list by category
    final filteredList = _selectedCategoryIndex == 0
        ? _koperasiList
        : _koperasiList
            .where((item) =>
                item['category'] == _categories[_selectedCategoryIndex])
            .toList();

    return Scaffold(
      backgroundColor: AppColors.brandBg, // brand bg
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // SearchBar Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search_rounded,
                          color: Color(0xFF94A3B8), size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Cari nama koperasi...',
                            hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Category Filters
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedCategoryIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategoryIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFDC2626)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFDC2626)
                                : const Color(0xFFDC2626)
                                    .withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          _categories[index],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFFDC2626),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),

            // Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Paling Dekat',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                      ),
                      icon: const Icon(Icons.my_location_rounded, size: 16),
                      label: const Text(
                        'Atur Lokasi',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 12),
            ),

            // Cooperative List
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = filteredList[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(24), // rounded-custom
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image with status chip
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(24)),
                                  child: Image.network(
                                    item['image'],
                                    height: 160,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 16,
                                  left: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: item['isOpen']
                                          ? const Color(0xFFECFDF5)
                                              .withOpacity(0.9)
                                          : const Color(0xFFFEF2F2)
                                              .withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: item['isOpen']
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFFEF4444),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          item['isOpen'] ? 'Buka' : 'Tutup',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: item['isOpen']
                                                ? const Color(0xFF065F46)
                                                : const Color(0xFF991B1B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Details
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined,
                                          size: 14, color: Color(0xFF94A3B8)),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          item['address'],
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF64748B),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF2F3FF),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                                Icons
                                                    .location_searching_rounded,
                                                size: 18,
                                                color: Color(0xFF1A2E44)),
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Jarak',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFF94A3B8)),
                                              ),
                                              Text(
                                                item['distance'],
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1E293B),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFDC2626),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            AppConstants.cooperativeDetailRoute,
                                            arguments: item['name'],
                                          );
                                        },
                                        child: const Text(
                                          'Lihat Detail',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold),
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
                    );
                  },
                  childCount: filteredList.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
