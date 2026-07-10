import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/location/location_bloc.dart';

/// Banner yang tampil di Home / Cooperative page selama user belum grant
/// izin lokasi. Reaktif terhadap [LocationBloc] state — otomatis hilang
/// saat user kasih izin, ganti CTA saat `deniedForever`.
///
/// Reusable: tinggal taruh di paling atas body ListView/Column, dia akan
/// hide dirinya sendiri kalau tidak relevan.
///
/// Contoh:
/// ```dart
/// Column(
///   children: [
///     const LocationPermissionBanner(), // auto-hide kalau ready
///     Expanded(child: ...konten utama...),
///   ],
/// )
/// ```
class LocationPermissionBanner extends StatelessWidget {
  const LocationPermissionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        // Hide untuk state yang tidak butuh banner.
        if (state is LocationReady ||
            state is LocationInitial ||
            state is LocationChecking) {
          return const SizedBox.shrink();
        }

        final colorScheme = Theme.of(context).colorScheme;
        final bloc = context.read<LocationBloc>();

        // Tentukan copy + CTA berdasarkan state.
        final BannerConfig config = switch (state) {
          LocationPermissionDenied() => BannerConfig(
              icon: Icons.location_off_rounded,
              iconColor: colorScheme.primary,
              bgColor: colorScheme.primaryContainer.withValues(alpha: 0.15),
              title: 'Aktifkan Lokasi',
              subtitle:
                  'Lihat koperasi & ruang diskusi di sekitar Anda',
              ctaLabel: 'Izinkan',
              onCta: () => bloc.add(const LocationPermissionRequested()),
            ),
          LocationPermissionPermanentlyDenied() => BannerConfig(
              icon: Icons.location_disabled_rounded,
              iconColor: colorScheme.error,
              bgColor: colorScheme.errorContainer.withValues(alpha: 0.4),
              title: 'Lokasi Dinonaktifkan',
              subtitle:
                  'Aktifkan di pengaturan untuk fitur koperasi terdekat',
              ctaLabel: 'Buka Pengaturan',
              onCta: () => bloc.add(const LocationOpenAppSettings()),
            ),
          LocationServiceDisabled() => BannerConfig(
              icon: Icons.gps_off_rounded,
              iconColor: colorScheme.error,
              bgColor: colorScheme.errorContainer.withValues(alpha: 0.4),
              title: 'GPS Nonaktif',
              subtitle: 'Aktifkan GPS untuk fitur lokasi',
              ctaLabel: 'Aktifkan GPS',
              onCta: () => bloc.add(const LocationOpenLocationSettings()),
            ),
          LocationError() => BannerConfig(
              icon: Icons.error_outline_rounded,
              iconColor: colorScheme.error,
              bgColor: colorScheme.errorContainer.withValues(alpha: 0.4),
              title: 'Gagal Mendapatkan Lokasi',
              subtitle: state.message,
              ctaLabel: 'Coba Lagi',
              onCta: () => bloc.add(const LocationInitialized()),
            ),
          // Catch-all untuk safety (seharusnya tidak pernah masuk sini
          // karena state di atas sudah di-return SizedBox.shrink()).
          _ => BannerConfig(
              icon: Icons.location_on_rounded,
              iconColor: colorScheme.primary,
              bgColor: colorScheme.primaryContainer.withValues(alpha: 0.15),
              title: 'Aktifkan Lokasi',
              subtitle: 'Untuk fitur koperasi & ruang diskusi terdekat',
              ctaLabel: 'Izinkan',
              onCta: () => bloc.add(const LocationPermissionRequested()),
            ),
        };

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: config.bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: config.iconColor.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(config.icon, color: config.iconColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      config.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  minimumSize: const Size(0, 36),
                ),
                onPressed: config.onCta,
                child: Text(
                  config.ctaLabel,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class BannerConfig {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final VoidCallback onCta;

  BannerConfig({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.onCta,
  });
}
