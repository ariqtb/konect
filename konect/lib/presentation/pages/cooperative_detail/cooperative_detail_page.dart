import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/cooperative/cooperative_detail_bloc.dart';
import '../../../data/models/cooperative_detail.dart';
import '../../../core/constants.dart';

class CooperativeDetailPage extends StatefulWidget {
  final String coopId;

  const CooperativeDetailPage({
    super.key,
    required this.coopId,
  });

  @override
  State<CooperativeDetailPage> createState() => _CooperativeDetailPageState();
}

class _CooperativeDetailPageState extends State<CooperativeDetailPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<CooperativeDetailBloc>()
        .add(CooperativeDetailLoadRequested(widget.coopId));
  }

  Color _parseHexColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return const Color(0xFFDC2626);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Design System Tokens (from documents/design.md)
    const Color colorSurface = Color(0xFFF8FAFC);
    const Color colorSecondaryContainer = Color(0xFFDC2626); // Brand Red/Rose

    return Scaffold(
      backgroundColor: colorSurface,
      body: BlocBuilder<CooperativeDetailBloc, CooperativeDetailState>(
        builder: (context, state) {
          if (state is CooperativeDetailLoading ||
              state is CooperativeDetailInitial) {
            return const Center(
                child:
                    CircularProgressIndicator(color: colorSecondaryContainer));
          }
          if (state is CooperativeDetailError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: colorSecondaryContainer),
                  const SizedBox(height: 8),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context
                        .read<CooperativeDetailBloc>()
                        .add(CooperativeDetailLoadRequested(widget.coopId)),
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            );
          }
          if (state is CooperativeDetailLoaded) {
            final details = state.details;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Section
                  _buildHeroSection(context, details),
                  // Main Content
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rooms / Discussions Section
                        _buildRoomsSection(context, state),
                        const SizedBox(height: 48),
                        // Updates / Timeline Section
                        _buildUpdatesSection(context, details.updates),
                        const SizedBox(height: 48),
                        // Detail Koperasi Section
                        _buildDetailKoperasiSection(context, details),
                        const SizedBox(height: 48),
                        // Contact Section
                        _buildContactSection(context, details),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, CooperativeDetail details) {
    const Color colorNavy = Color(0xFF1E293B);

    return Stack(
      children: [
        // Hero Image
        SizedBox(
          height: 350,
          width: double.infinity,
          child: Image.network(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCeqegAewlRAAXMd70mT68j05769MIZY35KhmvJEWOj2_6gGxL6PsY3XBUZ_z3LWdlej1MMR5GisRfgnpr-lwq6hzMtxy7FxXtBc2apH_fAyqxofTaDRvH6tMmCPrcmjQqGJdNHyPDFPgtUi9jT4ZIsyFqENlFYReJyAC4SH2eIc4beLvhEJcnU21WC5KFW0d-3qIDm2mw-MbFXK5XUmdIcoIvi1akAtnl15hlYlBW36qsNX3RYaYeZ4mWtysdpXxeo6Lw',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: colorNavy,
                child: const Icon(Icons.storefront,
                    color: Colors.white70, size: 64),
              );
            },
          ),
        ),
        // Dark Bottom-to-Top Gradient Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.85),
                  Colors.black.withValues(alpha: 0.2),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        // Back Button Overlay
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 20,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: colorNavy,
                size: 16,
              ),
            ),
          ),
        ),
        // Hero Details Content
        Positioned(
          bottom: 24,
          left: 24,
          right: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge "Mitra Utama"
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text(
                  'Mitra Utama',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colorNavy,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Cooperative Title
              Text(
                details.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              // Address Row
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      details.address,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                details.about,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoomsSection(
      BuildContext context, CooperativeDetailLoaded state) {
    const Color colorNavy = Color(0xFF1E293B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ruang yang Dibuat',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colorNavy,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Partisipasi aktif dalam pembangunan desa',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 24),
        // Filter Dropdown Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Filter Status Ruangan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF475569),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: colorNavy,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: colorNavy,
                ),
                child: DropdownButton<String>(
                  value: state.selectedFilter,
                  icon: const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.keyboard_arrow_down,
                        color: Colors.white, size: 18),
                  ),
                  underline: const SizedBox.shrink(),
                  dropdownColor: colorNavy,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  onChanged: (val) {
                    if (val != null) {
                      context
                          .read<CooperativeDetailBloc>()
                          .add(CooperativeDetailFilterRooms(val));
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'Semua', child: Text('Semua')),
                    DropdownMenuItem(value: 'Aktif', child: Text('Aktif')),
                    DropdownMenuItem(value: 'Selesai', child: Text('Selesai')),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Discussion Cards List
        if (state.filteredRooms.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: Text(
                'Tidak ada ruangan dengan status ini.',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.filteredRooms.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final room = state.filteredRooms[index];
              if (room.status == 'Aktif') {
                return _buildActiveDiscussionCard(context, room);
              } else {
                return _buildCompletedDiscussionCard(context, room);
              }
            },
          ),
        const SizedBox(height: 24),
        // Pagination (Static replica for high-fidelity)
        _buildPagination(),
      ],
    );
  }

  Widget _buildActiveDiscussionCard(
      BuildContext context, CoopDiscussionRoom room) {
    const Color colorNavy = Color(0xFF1E293B);
    const Color colorSecondaryContainer = Color(0xFFDC2626);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32), // rounded-vox (32px)
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Badge status Aktif
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF), // indigo-50
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text(
                  'Aktif',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4F46E5), // indigo-600
                  ),
                ),
              ),
              Text(
                room.date,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            room.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorNavy,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            room.description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 24),
          // Avatars & Join Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Avatars Stack
                  if (room.avatars.isNotEmpty)
                    SizedBox(
                      height: 32,
                      width: 32 + (room.avatars.length - 1) * 20.0,
                      child: Stack(
                        children: List.generate(room.avatars.length, (idx) {
                          final avatarVal = room.avatars[idx];
                          final isHex = avatarVal.startsWith('#');
                          final Color bgColor = isHex ? _parseHexColor(avatarVal) : const Color(0xFFDC2626);
                          
                          // Determine letter dynamically (e.g. A, R, B)
                          final String letter = idx == 0 ? 'A' : (idx == 1 ? 'R' : 'B');

                          return Positioned(
                            left: idx * 20.0,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: bgColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  letter,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '+${room.membersCount - room.avatars.length} Lainnya',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppConstants.roomDiscussionRoute,
                  arguments: room.id,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorSecondaryContainer,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ikuti Diskusi',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedDiscussionCard(
      BuildContext context, CoopDiscussionRoom room) {
    const Color colorNavy = Color(0xFF1E293B);

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppConstants.roomDiscussionRoute,
          arguments: room.id,
        );
      },
      borderRadius: BorderRadius.circular(32),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32), // rounded-vox (32px)
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, color: Color(0xFF64748B), size: 16),
                const SizedBox(width: 6),
                Text(
                  'Selesai • ${room.date}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              room.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorNavy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              room.description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    const Color colorNavy = Color(0xFF1E293B);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Active 1
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorNavy,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
        ),
        const SizedBox(width: 8),
        _buildPaginationButton('2'),
        const SizedBox(width: 8),
        _buildPaginationButton('3'),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
        ),
        _buildPaginationButton('67'),
        const SizedBox(width: 8),
        _buildPaginationButton('68'),
      ],
    );
  }

  Widget _buildPaginationButton(String text) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF475569),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildUpdatesSection(
      BuildContext context, List<CoopTimelineUpdate> updates) {
    const Color colorNavy = Color(0xFF1E293B);
    const Color colorSecondaryContainer = Color(0xFFDC2626);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Update Terkini',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colorNavy,
          ),
        ),
        const SizedBox(height: 24),
        // Timeline Layout
        Stack(
          children: [
            // Vertical Line
            Positioned(
              left: 23,
              top: 0,
              bottom: 0,
              child: Container(
                width: 2,
                color: const Color(0xFFD2D9F4),
              ),
            ),
            // Timeline items
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: updates.length,
              separatorBuilder: (_, __) => const SizedBox(height: 24),
              itemBuilder: (context, index) {
                final update = updates[index];
                final isWarning = update.type == 'warning';
                final dotColor = isWarning
                    ? const Color(0xFFFF7A3D)
                    : const Color(0xFF94A3B8);
                final dotBorderColor = isWarning
                    ? const Color(0xFFFFEDD5)
                    : const Color(0xFFF1F5F9);

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline Point
                    Container(
                      margin:
                          const EdgeInsets.only(left: 16, right: 16, top: 12),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: dotBorderColor, width: 3),
                      ),
                    ),
                    // Timeline Card
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                              context, AppConstants.articleDetailRoute);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(32), // rounded-vox
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                update.date,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                update.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colorNavy,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                update.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF64748B),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        // saran dan masukan button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Membuka formulir saran & masukan')),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline,
                color: Colors.white, size: 18),
            label: const Text(
              'Ruang saran dan masukan',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorSecondaryContainer,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailKoperasiSection(
      BuildContext context, CooperativeDetail details) {
    const Color colorNavy = Color(0xFF1E293B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detail Koperasi',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colorNavy,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32), // rounded-vox (32px)
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Chairperson
              _buildDetailItem(
                context,
                Icons.person_outline,
                const Color(0xFFEEF2FF), // indigo-50
                const Color(0xFF4F46E5), // indigo-600
                'Ketua Koperasi',
                details.chairperson,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Divider(color: Color(0xFFF1F5F9)),
              ),
              // Member count
              _buildDetailItem(
                context,
                Icons.people_outline,
                const Color(0xFFECFDF5), // emerald-50
                const Color(0xFF10B981), // emerald-600
                'Total Anggota',
                '${details.memberCount} Anggota',
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Divider(color: Color(0xFFF1F5F9)),
              ),
              // Legal Status
              _buildDetailItem(
                context,
                Icons.verified_outlined,
                const Color(0xFFFFF7ED), // orange-50
                const Color(0xFFF97316), // orange-600
                'Status Legal',
                details.legalStatus,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    IconData icon,
    Color bgIcon,
    Color colorIcon,
    String label,
    String value,
  ) {
    const Color colorNavy = Color(0xFF1E293B);

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: bgIcon,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: colorIcon, size: 24),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorNavy,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactSection(BuildContext context, CooperativeDetail details) {
    const Color colorNavy = Color(0xFF1E293B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kontak Koperasi',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colorNavy,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32), // rounded-vox (32px)
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.phone_outlined, color: colorNavy, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    details.phone,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.mail_outline, color: colorNavy, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    details.email,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
