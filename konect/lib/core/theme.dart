import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFa53c00);
  static const Color primaryContainerColor = Color(0xFFff7a3d);
  static const Color secondaryColor = Color(0xFFba0035);
  static const Color secondaryContainerColor = Color(0xFFe21e49); // Rose-colored primary buttons
  static const Color tertiaryColor = Color(0xFF494bd6); // Indigo
  static const Color backgroundColor = Color(0xFFf9f9ff);
  static const Color surfaceColor = Color(0xFFfaf8ff);
  static const Color containerColor = Color(0xFFf2f3ff);
  static const Color onSurfaceColor = Color(0xFF111c2d);
  static const Color outlineColor = Color(0xFF8c7167);

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        primaryContainer: primaryContainerColor,
        secondary: secondaryColor,
        secondaryContainer: secondaryContainerColor,
        tertiary: tertiaryColor,
        background: backgroundColor,
        surface: surfaceColor,
        surfaceVariant: containerColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: onSurfaceColor,
        onSurface: onSurfaceColor,
        outline: outlineColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          height: 36 / 30,
          letterSpacing: -0.025 * 30,
          color: onSurfaceColor,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 32 / 24,
          color: onSurfaceColor,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          height: 24 / 18,
          color: onSurfaceColor,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 24 / 16,
          color: onSurfaceColor,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 20 / 14,
          color: onSurfaceColor,
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          height: 12 / 10,
          letterSpacing: 0.05 * 10,
          color: onSurfaceColor,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: onSurfaceColor,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: onSurfaceColor,
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32), // large components rounded-4xl = 32px
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryContainerColor, // Rose-colored primary buttons
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // standard components = 24px
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24), // 24px rounded corners
          borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1), // Slate-300
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: primaryContainerColor, width: 2),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData.dark(useMaterial3: true).copyWith(
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
      ),
    );
  }
}
