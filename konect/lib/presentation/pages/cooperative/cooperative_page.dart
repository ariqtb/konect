import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/cooperative/cooperative_bloc.dart';
import '../../widgets/location_permission_banner.dart';
import '../../../data/models/cooperative.dart';

class CooperativePage extends StatefulWidget {
  final bool showBackButton;
  const CooperativePage({super.key, this.showBackButton = true});

  @override
  State<CooperativePage> createState() => _CooperativePageState();
}

class _CooperativePageState extends State<CooperativePage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<CooperativeBloc>().add(const CooperativeLoadRequested());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<CooperativeBloc>().add(const CooperativeLoadMoreRequested());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Custom Brand Colors matching Stitch HTML Design
    const Color brandPrimary = Color(0xFFE14242);
    const Color brandSecondary = Color(0xFF1A2E44);
    const Color brandBg = Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: brandBg,
      appBar: AppBar(
        title: const Text(
          'Daftar Koperasi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: brandSecondary,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: brandSecondary, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: BlocBuilder<CooperativeBloc, CooperativeState>(
        builder: (context, state) {
          if (state is CooperativeLoading || state is CooperativeInitial) {
            return const Center(child: CircularProgressIndicator(color: brandPrimary));
          }
          if (state is CooperativeError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: brandPrimary),
                  const SizedBox(height: 8),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context
                        .read<CooperativeBloc>()
                        .add(const CooperativeLoadRequested()),
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            );
          }
          if (state is CooperativeLoaded) {
            return Stack(
              children: [
                // Scrollable Content
                SafeArea(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: 8.0,
                      bottom: 120.0, // Space for floating bottom navigation bar
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Location permission banner — auto-hides saat granted.
                        const LocationPermissionBanner(),
                        // Search Bar
                        _buildSearchBar(context, state.searchQuery),
                        const SizedBox(height: 24),
                        // Section Header
                        _buildSectionHeader(context),
                        const SizedBox(height: 16),
                        // Cooperative List
                        if (state.filteredCooperatives.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40.0),
                              child: Text(
                                'Tidak ada koperasi yang cocok.',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.filteredCooperatives.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 24),
                            itemBuilder: (context, index) {
                              return _buildCooperativeCard(
                                context,
                                state.filteredCooperatives[index],
                              );
                            },
                          ),
                        if (state.filteredCooperatives.isNotEmpty && !state.hasReachedMax)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.0),
                            child: Center(child: CircularProgressIndicator(color: brandPrimary)),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, String currentQuery) {
    if (_searchController.text != currentQuery) {
      _searchController.text = currentQuery;
      // Position cursor at the end
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: currentQuery.length),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          context.read<CooperativeBloc>().add(CooperativeSearchQueryChanged(val));
        },
        decoration: InputDecoration(
          hintText: 'Cari nama koperasi...',
          hintStyle: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 14,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 16.0, right: 12.0),
            child: Icon(Icons.search, color: Color(0xFF9CA3AF), size: 22),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }


  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Paling Dekat',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A2E44),
          ),
        ),
        TextButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Atur Lokasi Anda')),
            );
          },
          icon: const Icon(Icons.my_location, color: Color(0xFFE14242), size: 16),
          label: const Text(
            'Atur Lokasi',
            style: TextStyle(
              color: Color(0xFFE14242),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  Widget _buildCooperativeCard(BuildContext context, CooperativeItem item) {
    const Color brandSecondary = Color(0xFF1A2E44);
    const Color brandPrimary = Color(0xFFE14242);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Image
          SizedBox(
            height: 180,
            width: double.infinity,
            child: Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFF2F3FF),
                  child: const Icon(Icons.storefront, color: Color(0xFF9CA3AF), size: 48),
                );
              },
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: brandSecondary,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Open/Closed Status Chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF), // blue-50
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: const Color(0xFFDBEAFE)), // blue-100
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: item.isOpen ? const Color(0xFF2563EB) : const Color(0xFF9CA3AF), // blue-600 or gray-400
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.isOpen ? 'Buka' : 'Tutup',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: brandSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Address Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, color: Color(0xFF9CA3AF), size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.address,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Bottom Details Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F3FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.near_me_outlined, color: brandSecondary, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Jarak',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                                Text(
                                  item.distance,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: brandSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/cooperative-detail',
                          arguments: item.id,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Lihat Detail',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
