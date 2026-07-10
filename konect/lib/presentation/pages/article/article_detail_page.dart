import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF059669).withOpacity(0.8), // Emerald-600/80
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'ENERGI TERBARUKAN',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Title
                      Text(
                        'Penyelesaian Fondasi Tiang Surya Tahap I',
                        style: GoogleFonts.outfit(
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
                            style: GoogleFonts.outfit(fontSize: 13, color: Colors.white.withOpacity(0.9)),
                          ),
                          const SizedBox(width: 20),
                          const Icon(Icons.person_outline, size: 14, color: Colors.white70),
                          const SizedBox(width: 6),
                          Text(
                            'Tim Infrastruktur Desa',
                            style: GoogleFonts.outfit(fontSize: 13, color: Colors.white.withOpacity(0.9)),
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
                  // Drop cap sentence
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'K',
                          style: GoogleFonts.outfit(
                            fontSize: 48,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF111C2D),
                            height: 0.9,
                          ),
                        ),
                        TextSpan(
                          text: 'emajuan signifikan telah dicapai dalam inisiatif VoxSilent Desa untuk kemandirian energi. Pekan ini, tim konstruksi kami secara resmi menyelesaikan penanaman 45 fondasi utama untuk rangkaian panel surya tahap pertama di area perbukitan selatan.',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            height: 1.6,
                            fontWeight: FontWeight.normal,
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Proyek ini merupakan tulang punggung dari visi "Desa Mandiri Energi" yang kita cita-citakan bersama. Fondasi yang telah terpasang menggunakan spesifikasi beton bertulang tahan gempa, memastikan instalasi panel surya akan bertahan selama puluhan tahun mendatang di tengah kondisi cuaca ekstrem sekalipun.',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      height: 1.6,
                      color: const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 28),
                  
                  // Subheading
                  Text(
                    'Tantangan Geografis & Solusi Lokal',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF111C2D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Medan yang cukup terjal di area Bukit Hijau menuntut ketelitian ekstra. Namun, berkat kolaborasi antara tenaga ahli dan warga lokal, kita berhasil mengoptimalkan distribusi material tanpa merusak ekosistem hutan sekitarnya. Penggunaan teknik manual terkontrol di beberapa titik kritis membuktikan bahwa pembangunan modern bisa selaras dengan alam.',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      height: 1.6,
                      color: const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Next Steps Box (Amber box)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB), // light amber background
                      borderRadius: BorderRadius.circular(16),
                      border: const Border(
                        top: BorderSide(color: Color(0xFFF59E0B), width: 4), // border amber
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LANGKAH SELANJUTNYA',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: const Color(0xFFB45309), // dark amber
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Dengan selesainya Tahap I, tim akan segera melakukan mobilisasi untuk pemasangan rangka penyangga baja pada awal bulan depan. Kami mengundang seluruh anggota koperasi untuk menghadiri sesi pemaparan teknis Tahap II yang akan diadakan di Balai Desa pada hari Sabtu mendatang.',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            height: 1.6,
                            color: const Color(0xFF78350F), // amber brown
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
