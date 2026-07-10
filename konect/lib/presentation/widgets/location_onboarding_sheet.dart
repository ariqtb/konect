import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/services/location_service.dart';
import '../../data/services/preferences_service.dart';
import '../blocs/location/location_bloc.dart';

/// Modal sheet yang muncul SEKALI saat first launch (atau setelah user
/// logout / reset) untuk menjelaskan kenapa Konect butuh izin lokasi,
/// SEBELUM menampilkan system dialog.
///
/// Alasan pakai custom sheet dulu (bukan langsung system dialog):
/// - System dialog tanpa context = user bingung → high deny rate
/// - User yang informed biasanya lebih mau kasih izin
/// - Bisa track "Nanti" di SharedPreferences supaya tidak ganggu
///
/// Flow:
/// ```
/// First launch
///   → showModalBottomSheet(this)
///   → User tap "Izinkan Lokasi"
///   → pop(sheet)
///   → dispatch LocationPermissionRequested
///   → system dialog muncul
///   → kalau granted: LocationReady
///   → kalau denied: LocationPermissionDenied (banner di Home)
///
///   → User tap "Nanti Saja"
///   → pop(sheet)
///   → PreferencesService.markLocationPromptDismissed()
///   → 24 jam throttle
/// ```
class LocationOnboardingSheet extends StatelessWidget {
  const LocationOnboardingSheet({super.key});

  /// Helper untuk show dari mana saja.
  /// [context] harus punya [LocationBloc] di tree.
  static Future<void> show(BuildContext context) {
    final bloc = context.read<LocationBloc>();
    final prefs = PreferencesService.instance;

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false, // user harus pilih salah satu tombol
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: bloc,
          child: const LocationOnboardingSheet(),
        );
      },
    ).then((_) {
      // Mark sebagai sudah ditampilkan SETELAH sheet ditutup (baik karena
      // tombol mana pun).
      prefs.markLocationOnboardingShown();
    });
  }

  /// Cek apakah perlu show sheet (first launch + izin belum granted).
  /// Dipanggil dari main entry point.
  static bool shouldShow({required LocationPermissionStatus? permission}) {
    if (permission == null) return false; // belum cek, jangan ganggu
    if (permission == LocationPermissionStatus.granted) return false;
    final prefs = PreferencesService.instance;
    if (prefs.hasShownLocationOnboarding) return false;
    if (prefs.isLocationPromptDismissedRecently) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bloc = context.read<LocationBloc>();

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Icon header
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.location_on_rounded,
              size: 44,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            'Temukan Koperasi di Sekitar Anda',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          // Subtitle
          Text(
            'Konect butuh akses lokasi untuk fitur-fitur berikut:',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Benefits list
          _BenefitItem(
            icon: Icons.store_mall_directory_rounded,
            color: colorScheme.primary,
            title: 'Koperasi Desa Terdekat',
            subtitle: 'Lihat koperasi yang paling dekat dengan lokasi Anda',
          ),
          const SizedBox(height: 12),
          _BenefitItem(
            icon: Icons.forum_rounded,
            color: colorScheme.secondary,
            title: 'Ruang Diskusi Aktif',
            subtitle: 'Topik diskusi yang lagi berjalan di sekitar Anda',
          ),
          const SizedBox(height: 12),
          _BenefitItem(
            icon: Icons.verified_user_rounded,
            color: colorScheme.tertiary,
            title: 'Verifikasi Otomatis',
            subtitle: 'Saat posting, sistem akan cek Anda di area koperasi',
          ),
          const SizedBox(height: 32),

          // Primary CTA
          FilledButton(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              bloc.add(const LocationPermissionRequested());
            },
            child: const Text(
              'Izinkan Lokasi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 8),

          // Secondary CTA
          TextButton(
            onPressed: () {
              PreferencesService.instance.markLocationPromptDismissed();
              Navigator.of(context).pop();
            },
            child: Text(
              'Nanti Saja',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ),

          // Privacy note
          const SizedBox(height: 8),
          Text(
            'Lokasi Anda hanya dipakai saat app dibuka dan tidak disimpan '
            'ke server selain untuk verifikasi posting.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.outline,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _BenefitItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
