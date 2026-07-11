import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/location/location_bloc.dart';
import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../core/services/supabase_service.dart';
import '../../../data/models/cooperative.dart';
import '../../../data/repositories/cooperative_repository.dart';
import '../voucher/voucher_page.dart';
import '../profile/profile_page.dart';
import '../cooperative/cooperative_page.dart';
import '../../../data/repositories/room_repository.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final TextEditingController _roomCodeController = TextEditingController();
  List<Map<String, dynamic>>? _joinedRooms;

  CooperativeItem? _nearbyCoop;
  double? _nearbyDistance;
  bool _isLoadingLocation = true;
  Map<String, dynamic>? _nearbyRoom;
  List<CooperativeItem> _nearbyCoops = [];
  bool _isLoadingNearbyCoops = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadJoinedRooms();
      _initLocationCheck();
    });
  }

  void _initLocationCheck() {
    final locationState = context.read<LocationBloc>().state;
    debugPrint('[MainPage] _initLocationCheck: state=${locationState.runtimeType}');
    if (locationState is LocationReady) {
      debugPrint('[MainPage] LocationReady → lat=${locationState.location.latitude}, lng=${locationState.location.longitude}');
      _checkNearbyCooperativeWithPosition(
        locationState.location.latitude,
        locationState.location.longitude,
      );
    } else if (locationState is LocationChecking) {
      setState(() {
        _isLoadingLocation = true;
      });
    } else {
      // Location not ready yet — keep loading state true so 
      // BlocListener can catch future LocationReady transitions
      debugPrint('[MainPage] Location not ready yet (${locationState.runtimeType}), waiting for BlocListener...');
      setState(() {
        _isLoadingLocation = true;
      });
      // Re-trigger location initialization in case it stalled
      context.read<LocationBloc>().add(const LocationInitialized());
    }
  }

  Future<void> _checkNearbyCooperativeWithPosition(double latitude, double longitude) async {
    debugPrint('[MainPage] _checkNearbyCooperativeWithPosition: user=($latitude, $longitude)');
    try {
      // Fetch cooperatives from profil_koperasi with their gerai radius
      final cooperatives = await cooperativeRepository.getNearbyCooperativesWithRadius();
      debugPrint('[MainPage] fetched ${cooperatives.length} cooperatives from profil_koperasi');
      
      CooperativeItem? closestCoop;
      double minDistance = double.infinity;
      double? matchedRadius;

      for (final entry in cooperatives) {
        final coop = entry['coop'] as CooperativeItem;
        final radius = (entry['radius'] as double?) ?? 5000.0; // Default 5km

        if (coop.latitude != null && coop.longitude != null) {
          final dist = Geolocator.distanceBetween(
            latitude,
            longitude,
            coop.latitude!,
            coop.longitude!,
          );
          debugPrint('[MainPage] coop "${coop.name}" (${coop.id}): lat=${coop.latitude}, lng=${coop.longitude}, dist=${dist.toStringAsFixed(1)}m, radius=${radius.toStringAsFixed(0)}m');
          if (dist <= radius && dist < minDistance) {
            closestCoop = coop;
            minDistance = dist;
            matchedRadius = radius;
          }
        } else {
          debugPrint('[MainPage] coop "${coop.name}" (${coop.id}): SKIPPED (null coordinates)');
        }
      }

      if (closestCoop != null) {
        debugPrint('[MainPage] closest coop: "${closestCoop.name}" at ${minDistance.toStringAsFixed(1)}m (radius: ${matchedRadius?.toStringAsFixed(0)}m)');
        final client = SupabaseService().client;
        final roomResponse = await client
            .from('discussion_rooms')
            .select('id, title, description, created_at, is_active')
            .eq('koperasi_ref', closestCoop.id)
            .eq('is_active', true)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();

        if (mounted) {
          setState(() {
            _nearbyCoop = closestCoop;
            _nearbyDistance = minDistance;
            _nearbyRoom = roomResponse;
            _isLoadingLocation = false;
          });
        }
      } else {
        debugPrint('[MainPage] NO coop found within radius');
        if (mounted) {
          setState(() {
            _nearbyCoop = null;
            _nearbyDistance = null;
            _nearbyRoom = null;
            _isLoadingLocation = false;
          });
        }
      }

      // Also fetch nearby cooperatives for the "Koperasi Desa Terdekat" section
      _fetchNearbyCooperatives(latitude, longitude);
    } catch (e) {
      debugPrint('[MainPage] ERROR in _checkNearbyCooperativeWithPosition: $e');
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
          _nearbyCoop = null;
        });
      }
    }
  }

  Future<void> _fetchNearbyCooperatives(double latitude, double longitude) async {
    try {
      final allCoops = await cooperativeRepository.getNearbyCooperatives();
      debugPrint('[MainPage] fetched ${allCoops.length} cooperatives from profil_koperasi');

      // Calculate distance and sort
      final coopsWithDistance = <MapEntry<CooperativeItem, double>>[];
      for (final coop in allCoops) {
        if (coop.latitude != null && coop.longitude != null) {
          final dist = Geolocator.distanceBetween(
            latitude,
            longitude,
            coop.latitude!,
            coop.longitude!,
          );
          coopsWithDistance.add(MapEntry(
            coop.copyWith(distance: _formatDistance(dist)),
            dist,
          ));
        }
      }

      // Sort by distance ascending
      coopsWithDistance.sort((a, b) => a.value.compareTo(b.value));

      if (mounted) {
        setState(() {
          _nearbyCoops = coopsWithDistance.map((e) => e.key).toList();
          _isLoadingNearbyCoops = false;
        });
      }
    } catch (e) {
      debugPrint('[MainPage] ERROR in _fetchNearbyCooperatives: $e');
      if (mounted) {
        setState(() {
          _nearbyCoops = [];
          _isLoadingNearbyCoops = false;
        });
      }
    }
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)}m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)}km';
    }
  }

  Future<void> _loadJoinedRooms() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final rooms = await roomRepository.getJoinedRooms(authState.user.id);
      if (mounted) {
        setState(() {
          _joinedRooms = rooms;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _joinedRooms = [];
        });
      }
    }
  }

  String _formatDateTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      final day = dt.day.toString().padLeft(2, '0');
      final month = months[dt.month - 1];
      final year = dt.year;
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$day $month $year • $hour:$minute WIB';
    } catch (_) {
      return isoString;
    }
  }

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final bool isLoggedIn = authState is AuthAuthenticated;
    final bool isKopdes = isLoggedIn && authState.user.isKopdes;

    return BlocListener<LocationBloc, LocationState>(
      listener: (context, state) {
        if (state is LocationReady) {
          _checkNearbyCooperativeWithPosition(
            state.location.latitude,
            state.location.longitude,
          );
        } else if (state is LocationChecking) {
          setState(() {
            _isLoadingLocation = true;
          });
        } else {
          setState(() {
            _nearbyCoop = null;
            _nearbyDistance = null;
            _nearbyRoom = null;
            _isLoadingLocation = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.brandBg,
        body: Stack(
          children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              // Index 0: Home Content
              SingleChildScrollView(
                padding: const EdgeInsets.only(
                    bottom:
                        100.0), // Padding to avoid overlap with bottom navigation bar
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Red background container
                        Container(
                          height: 250,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: AppColors.brandRed,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                        ),
                        // Content column (header + card)
                        SafeArea(
                          bottom: false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(),
                              const SizedBox(height: 16),
                              _buildHeroDiscussion(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildNearestCoop(),
                    const SizedBox(height: 32),
                    _buildJoinRoom(),
                    if (isLoggedIn &&
                        !authState.user.email.startsWith('anon_') &&
                        authState.user.email != 'guest@konect.id') ...[
                      const SizedBox(height: 32),
                      _buildAddProgressSection(),
                    ],
                    const SizedBox(height: 32),
                    _buildHistorySection(),
                  ],
                ),
              ),
              // Index 1: Koperasi
              const CooperativePage(showBackButton: false),
              // Index 2: Voucher
              const VoucherPage(),
              // Index 3: Profile
              const ProfilePage(),
            ],
          ),
          // Floating Translucent Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNavigationBar(),
          ),
          // Floating Center Action Button (Centering horizontally, non-clipping)
          Positioned(
            bottom: 42,
            left: 0,
            right: 0,
            child: Center(
              child: _buildCenterActionButton(),
            ),
          ),
        ],
      ),
    ),);
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Konect',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.025 * 32,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Diskusi Koperasi Desa di lokasi anda',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  icon:
                      const Icon(Icons.emoji_events_outlined, color: Colors.white),
                  onPressed: () {
                    Navigator.pushNamed(context, AppConstants.leaderboardRoute);
                  },
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final keys = prefs.getKeys();
                  final Map<String, dynamic> prefsData = {};
                  for (final key in keys) {
                    prefsData[key] = prefs.get(key);
                  }

                  if (!context.mounted) return;
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Row(
                        children: [
                          Icon(Icons.settings_outlined, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Debug Local Cache'),
                        ],
                      ),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: keys.isEmpty
                            ? const Text('Shared Preferences kosong.')
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: keys.length,
                                itemBuilder: (context, index) {
                                  final key = keys.elementAt(index);
                                  final val = prefsData[key];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            key,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '$val',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            await prefs.clear();
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Cache local berhasil dibersihkan!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'Clear All',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  width: 24,
                  height: 44,
                  color: Colors.transparent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroDiscussion() {
    if (_isLoadingLocation) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.brandRed),
          ),
        ),
      );
    }

    if (_nearbyCoop == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF1F1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_off_outlined,
                  color: AppColors.brandRed,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Di Luar Radius Koperasi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111C2D),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Anda harus berada di dalam radius 5 km dari lokasi gerai koperasi untuk dapat mengakses dan mengikuti ruang diskusi desa.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoadingLocation = true;
                  });
                  context.read<LocationBloc>().add(const LocationInitialized());
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Cek Ulang Lokasi'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.brandRed,
                  side: const BorderSide(color: AppColors.brandRed),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final hasRoom = _nearbyRoom != null;
    final title = hasRoom ? _nearbyRoom!['title'] : 'Belum Ada Diskusi Aktif';
    final desc = hasRoom ? _nearbyRoom!['description'] : 'Jadilah yang pertama untuk memulai ruang diskusi di koperasi ini.';
    final dateStr = hasRoom ? _formatDateTime(_nearbyRoom!['created_at']) : 'Sekarang';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: hasRoom ? const Color(0xFFD1FAE5) : const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        hasRoom ? 'Sedang Aktif' : 'Kosong',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: hasRoom ? const Color(0xFF065F46) : const Color(0xFF856404),
                        ),
                      ),
                    ),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _nearbyCoop!.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111C2D),
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                if (hasRoom) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppConstants.roomDiscussionRoute,
                          arguments: _nearbyRoom!['id'],
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Ikuti Diskusi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_outlined, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String url) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF2F3FF), width: 2),
      ),
      child: ClipOval(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.person_outline,
                  size: 18, color: Colors.white),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNearestCoop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Koperasi Desa Terdekat',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111C2D),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppConstants.cooperativeRoute);
                },
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _isLoadingNearbyCoops
            ? const SizedBox(
                height: 250,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.brandRed),
                ),
              )
            : _nearbyCoops.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.store_outlined,
                              size: 40, color: Color(0xFF94A3B8)),
                          const SizedBox(height: 12),
                          const Text(
                            'Belum Ada Koperasi Terdekat',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111C2D),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tidak ditemukan koperasi desa di sekitar lokasi Anda.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SizedBox(
                    height: 260,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      itemCount: _nearbyCoops.length,
                      itemBuilder: (context, index) {
                        final coop = _nearbyCoops[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppConstants.cooperativeDetailRoute,
                              arguments: coop.id,
                            );
                          },
                          child: Container(
                            width: 280,
                            margin: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: const Color(0xFFF1F5F9)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                          const BorderRadius.vertical(
                                              top: Radius.circular(16)),
                                      child: Image.network(
                                        coop.imageUrl,
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            height: 150,
                                            color: Colors.grey[200],
                                            child: const Icon(
                                                Icons.image_outlined,
                                                color: Colors.grey),
                                          );
                                        },
                                      ),
                                    ),
                                    Positioned(
                                      top: 12,
                                      left: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: coop.isOpen
                                              ? const Color(0xCC10B981)
                                              : const Color(0xCCEF4444),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircleAvatar(
                                              radius: 3,
                                              backgroundColor: Colors.white,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              coop.isOpen ? 'Buka' : 'Tutup',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (coop.category.isNotEmpty)
                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.black
                                                .withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            coop.category,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        coop.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF111C2D),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(
                                              Icons.location_on_outlined,
                                              size: 14,
                                              color: Color(0xFF94A3B8)),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              coop.distance.isNotEmpty
                                                  ? '${coop.distance} • ${coop.address}'
                                                  : coop.address,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF64748B),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
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
                    ),
                  ),
      ],
    );
  }

  Widget _buildJoinRoom() {
    final authState = context.read<AuthBloc>().state;
    final bool isLoggedIn = authState is AuthAuthenticated;
    final bool isKopdes = isLoggedIn && authState.user.isKopdes;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Masuk room',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111C2D),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isKopdes) ...[
                  const Text(
                    'Buat Rapat Baru',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111C2D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mulai sesi musyawarah desa/koperasi baru di canvas.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/create-room');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline,
                              size: 22, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Buat Rapat Baru',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      children: [
                        Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'atau',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                      ],
                    ),
                  ),
                  const Text(
                    'Masukkan Kode Ruang',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111C2D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _roomCodeController,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: DESA-2024',
                      hintStyle: TextStyle(color: Color(0xFFCBD5E1)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_roomCodeController.text.trim().isNotEmpty) {
                          await Navigator.pushNamed(
                            context,
                            AppConstants.roomDiscussionRoute,
                            arguments: _roomCodeController.text.trim(),
                          );
                          _loadJoinedRooms();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Silakan masukkan kode ruang')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5F9),
                        foregroundColor: const Color(0xFF1E293B),
                        elevation: 0,
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login, size: 22, color: Color(0xFF1E293B)),
                          SizedBox(width: 10),
                          Text(
                            'Gabung Rapat',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  const Text(
                    'Masukkan Kode Ruang',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111C2D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _roomCodeController,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: DESA-2024',
                      hintStyle: TextStyle(color: Color(0xFFCBD5E1)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_roomCodeController.text.trim().isNotEmpty) {
                          await Navigator.pushNamed(
                            context,
                            AppConstants.roomDiscussionRoute,
                            arguments: _roomCodeController.text.trim(),
                          );
                          _loadJoinedRooms();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Silakan masukkan kode ruang')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login, size: 22, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Gabung Rapat',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddProgressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progress Koperasi',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111C2D),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kirim Progress Baru',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111C2D),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Posting berita, artikel, atau update perkembangan koperasi desa Anda.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppConstants.createArticleRoute);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandRed,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.article_outlined, size: 22, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Tulis Progress Baru',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    if (_joinedRooms == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_joinedRooms!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Riwayat Ruang Saya',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111C2D),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: const Center(
                child: Text(
                  'Belum ada riwayat rapat. Silakan gabung rapat menggunakan kode ruang.',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Riwayat Ruang Saya',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111C2D),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.tune_outlined, color: Color(0xFF64748B)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Filter Riwayat')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _joinedRooms!.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = _joinedRooms![index];
              return InkWell(
                onTap: () async {
                  await Navigator.pushNamed(
                    context,
                    AppConstants.roomDiscussionRoute,
                    arguments: item['id'] as String,
                  );
                  _loadJoinedRooms();
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.people_outline,
                          color: AppColors.brandNavy,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'] as String,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111C2D),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDateTime(item['time'] as String),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _buildNavItem(Icons.home_outlined, 'Home', 0)),
            Expanded(child: _buildNavItem(Icons.storefront_outlined, 'Koperasi', 1)),
            const SizedBox(width: 72), // Empty space for FAB
            Expanded(
                child: _buildNavItem(
                    Icons.confirmation_number_outlined, 'Voucher', 2)),
            Expanded(child: _buildNavItem(Icons.person_outline, 'Profile', 3)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    final activeColor = const Color(0xFFDC2626);
    final inactiveColor = const Color(0xFF94A3B8);

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? activeColor : inactiveColor,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.05 * 10,
              color: isActive ? activeColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterActionButton() {
    final authState = context.read<AuthBloc>().state;
    final bool isLoggedIn = authState is AuthAuthenticated;
    final bool isKopdes = isLoggedIn && authState.user.isKopdes;

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            if (isKopdes) {
              _showAdminAddOptionsModal(context);
            } else {
              _showRoomHistoryModal(context);
            }
          },
          child: Icon(
            isKopdes ? Icons.add : Icons.history_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  void _showAdminAddOptionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'PILIH AKSI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626).withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.forum_outlined,
                      color: Color(0xFFDC2626)),
                ),
                title: const Text(
                  'Buat Room Diskusi Baru',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                subtitle: const Text(
                  'Mulai sesi musyawarah warga baru di canvas',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/create-room');
                },
              ),
              const Divider(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.article_outlined,
                      color: Color(0xFF1E293B)),
                ),
                title: const Text(
                  'Kirim Progress Baru (Artikel)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                subtitle: const Text(
                  'Posting berita atau update perkembangan koperasi',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppConstants.createArticleRoute);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showRoomHistoryModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pull bar
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Riwayat Room Diskusi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Daftar ruang diskusi yang pernah Anda masuki.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // History list
              Expanded(
                child: _joinedRooms == null
                    ? const Center(child: CircularProgressIndicator())
                    : _joinedRooms!.isEmpty
                        ? const Center(
                            child: Text(
                              'Belum ada riwayat rapat.',
                              style: TextStyle(color: Color(0xFF64748B)),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: _joinedRooms!.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = _joinedRooms![index];
                              final String id = item['id'] as String;
                              final String code = id.length > 6 ? id.substring(0, 6).toUpperCase() : id.toUpperCase();
                              
                              final String startStr = item['createdAt'] != '' ? _formatDateTime(item['createdAt'] as String) : '-';
                              final String endStr = (item['isActive'] as bool) 
                                  ? 'Aktif (Sedang Berjalan)' 
                                  : (item['updatedAt'] != '' ? _formatDateTime(item['updatedAt'] as String) : 'Selesai');
                              
                              return _buildHistoryItemModal(
                                id: id,
                                code: code,
                                title: item['title'] as String,
                                date: 'Mulai: $startStr\nSelesai: $endStr',
                              );
                            },
                          ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryItemModal({
    required String id,
    required String code,
    required String title,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              code,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFFDC2626),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.arrow_forward_rounded,
                color: Color(0xFF64748B), size: 18),
            onPressed: () async {
              Navigator.pop(context); // Close sheet
              await Navigator.pushNamed(
                context,
                AppConstants.roomDiscussionRoute,
                arguments: id,
              );
              _loadJoinedRooms();
            },
          ),
        ],
      ),
    );
  }
}
