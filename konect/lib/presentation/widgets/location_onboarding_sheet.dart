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
    final bloc = context.read<LocationBloc>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 28,
        right: 28,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0), // Slate-200
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Icon header (brand colored / active)
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2), // Very soft red-50
                borderRadius: BorderRadius.circular(36),
                border: Border.all(
                  color: const Color(0xFFFEE2E2), // Red-100
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.location_on_rounded,
                size: 38,
                color: Color(0xFFDC2626), // Premium brand red
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          const Text(
            'Akses Lokasi Diperlukan',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A), // Slate-900
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          const Text(
            'Konect membutuhkan akses lokasi perangkat Anda untuk menjalankan fitur-fitur utama berikut:',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B), // Slate-500
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Benefits list
          const _BenefitItem(
            icon: Icons.store_mall_directory_rounded,
            title: 'Koperasi Desa Terdekat',
            subtitle: 'Menampilkan profil koperasi aktif yang paling dekat dengan lokasi Anda.',
          ),
          const SizedBox(height: 16),
          const _BenefitItem(
            icon: Icons.forum_rounded,
            title: 'Ruang Diskusi Aktif',
            subtitle: 'Mengikuti musyawarah dan topik rapat koordinasi warga di sekitar Anda.',
          ),
          const SizedBox(height: 16),
          const _BenefitItem(
            icon: Icons.verified_user_rounded,
            title: 'Verifikasi Kehadiran',
            subtitle: 'Validasi otomatis bahwa Anda berada di area cakupan koperasi saat berpendapat.',
          ),
          const SizedBox(height: 28),

          // Primary CTA
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626), // brand red
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              bloc.add(const LocationPermissionRequested());
            },
            child: const Text(
              'Izinkan Akses Lokasi',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 6),

          // Secondary CTA
          TextButton(
            onPressed: () {
              PreferencesService.instance.markLocationPromptDismissed();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Nanti Saja',
              style: TextStyle(
                color: Color(0xFF64748B), // Slate-500
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Privacy note
          const SizedBox(height: 8),
          const Text(
            'Lokasi Anda hanya diproses secara lokal saat aplikasi dibuka untuk verifikasi jarak rapat, dan tidak disimpan secara permanen di server.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF94A3B8), // Slate-400
              fontSize: 11,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Monochrome icon container
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9), // Slate-100
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF475569), // Slate-600 (Monochrome)
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF0F172A), // Slate-900
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B), // Slate-500
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
