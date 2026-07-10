import 'package:flutter/material.dart';

class AppColors {
  static const Color brandRed = Color(0xFFDC2626);
  static const Color brandNavy = Color(0xFF1E293B);
  static const Color brandBg = Color(0xFFF8FAFC);
  static const Color containerBg = Color(0xFFF2F3FF);
  
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
}

class AppTheme {
  // SF Pro is the default system font on iOS — no need to specify fontFamily
  static const String fontFamily = '.AppleSystemUIFont';

  static const Color primaryColor = AppColors.brandRed; // Red-600
  static const Color primaryContainerColor = Color(0xFFFEE2E2); // Red-100
  static const Color secondaryColor = AppColors.brandNavy;
  static const Color secondaryContainerColor = Color(0xFFE2E8F0); // Slate-200
  static const Color tertiaryColor = Color(0xFF494bd6); // Indigo
  static const Color backgroundColor = AppColors.brandBg;
  static const Color surfaceColor = AppColors.brandBg;
  static const Color containerColor = AppColors.containerBg;
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
      textTheme: base.textTheme.copyWith(
        displayLarge: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          height: 36 / 30,
          letterSpacing: -0.75,
          color: onSurfaceColor,
        ),
        headlineMedium: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 32 / 24,
          color: onSurfaceColor,
        ),
        titleLarge: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          height: 24 / 18,
          color: onSurfaceColor,
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 24 / 16,
          color: onSurfaceColor,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 20 / 14,
          color: onSurfaceColor,
        ),
        labelLarge: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          height: 12 / 10,
          letterSpacing: 0.5,
          color: onSurfaceColor,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: onSurfaceColor,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: onSurfaceColor,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32), // large components rounded-4xl = 32px
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryContainerColor, // Red brand primary buttons
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // standard components = 24px
          ),
          textStyle: const TextStyle(
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
          borderSide: const BorderSide(color: secondaryContainerColor, width: 2),
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

