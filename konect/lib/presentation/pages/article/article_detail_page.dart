import 'dart:ui';
import 'package:flutter/material.dart';

class ArticleDetailPage extends StatelessWidget {
  const ArticleDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section with Image and Overlay
            Stack(
              children: [
                Container(
                  height: 400,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuCKj0KyglLbOn2DNZtnYMsq9ynlR1zolGnlJFH_Wi5WD4UFDg61Ko5G0p_9-k8CGSHESAEm6ruFwuqZ_FeYobQJ8ZByPooIyVDKFdMzvvtBo6LWVoBA-Zg-Zh2dCoTOPIiFAuUIms3rKcoYv_fDc_O3VNQsX5BL_SieaMawl9qyZFkmKNXcN2N3EMXBEktJ3UskUHFo055njg4PkXRI3WfbsTcqT4hRBJrIKFnrdk4h6cxtTGMKTL4PS_C8XOFCMztcx00',
                      ),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
                // Back Button (Frosted Glass Effect)
                Positioned(
                  top: 50,
                  left: 20,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        color: Colors.white.withOpacity(0.9),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF111C2D)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  ),
                ),
                // Text Overlay
                Positioned(
                  bottom: 30,
                  left: 24,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF059669).withOpacity(0.85),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Text(
                          'Energi Terbarukan',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Title
                      const Text(
                        'Penyelesaian Fondasi Tiang Surya Tahap I',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Metadata (Date & Author)
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.white70),
                          const SizedBox(width: 6),
                          Text(
                            '24 Oktober 2023',
                            style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9)),
                          ),
                          const SizedBox(width: 20),
                          const Icon(Icons.person_outline, size: 14, color: Colors.white70),
                          const SizedBox(width: 6),
                          Text(
                            'Tim Infrastruktur Desa',
                            style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Article Body Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First paragraph — normal, no drop cap
                  const Text(
                    'Kemajuan signifikan telah dicapai dalam inisiatif VoxSilent Desa untuk kemandirian energi. Pekan ini, tim konstruksi kami secara resmi menyelesaikan penanaman 45 fondasi utama untuk rangkaian panel surya tahap pertama di area perbukitan selatan.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Proyek ini merupakan tulang punggung dari visi "Desa Mandiri Energi" yang kita cita-citakan bersama. Fondasi yang telah terpasang menggunakan spesifikasi beton bertulang tahan gempa, memastikan instalasi panel surya akan bertahan selama puluhan tahun mendatang di tengah kondisi cuaca ekstrem sekalipun.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 28),
                  
                  // Subheading
                  const Text(
                    'Tantangan Geografis & Solusi Lokal',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111C2D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Medan yang cukup terjal di area Bukit Hijau menuntut ketelitian ekstra. Namun, berkat kolaborasi antara tenaga ahli dan warga lokal, kita berhasil mengoptimalkan distribusi material tanpa merusak ekosistem hutan sekitarnya. Penggunaan teknik manual terkontrol di beberapa titik kritis membuktikan bahwa pembangunan modern bisa selaras dengan alam.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Next Steps Box — simplified, neutral warm
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F0),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Langkah selanjutnya',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Dengan selesainya Tahap I, tim akan segera melakukan mobilisasi untuk pemasangan rangka penyangga baja pada awal bulan depan. Kami mengundang seluruh anggota koperasi untuk menghadiri sesi pemaparan teknis Tahap II yang akan diadakan di Balai Desa pada hari Sabtu mendatang.',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
