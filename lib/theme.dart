import 'package:flutter/material.dart';

class AppColors {
  static const Color ink = Color(0xFF151515);
  static const Color cream = Color(0xFFF5F0E7);
  static const Color paper = Color(0xFFFFFCF7);
  static const Color coral = Color(0xFFF04D3A);
  static const Color sunshine = Color(0xFFF7C948);
  static const Color mint = Color(0xFF92C9A9);
  static const Color sky = Color(0xFF82C5D8);
  static const Color muted = Color(0xFF706D67);

  // Existing names are kept so older screens inherit the refreshed palette.
  static const Color primary1 = ink;
  static const Color primary2 = coral;
  static const Color primary3 = sky;
  static const Color primary4 = Color(0xFFFFE8A8);
  static const Color errorRed = Color(0xFFC93E32);
  static const Color successGreen = Color(0xFF4F9368);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = ink;
  static const Color darkGray = muted;
  static const Color lightGray = cream;
  static const Color borderGray = Color(0xFFD8D1C5);
}

class AppTheme {
  static ThemeData get lightTheme {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.ink,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.coral,
      onPrimaryContainer: AppColors.white,
      secondary: AppColors.coral,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.primary4,
      onSecondaryContainer: AppColors.ink,
      tertiary: AppColors.mint,
      onTertiary: AppColors.ink,
      tertiaryContainer: Color(0xFFDDEFE3),
      onTertiaryContainer: AppColors.ink,
      error: AppColors.errorRed,
      onError: AppColors.white,
      errorContainer: Color(0xFFF8DCD8),
      onErrorContainer: AppColors.errorRed,
      outline: AppColors.borderGray,
      surface: AppColors.paper,
      onSurface: AppColors.ink,
      surfaceContainerHighest: AppColors.cream,
      onSurfaceVariant: AppColors.muted,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.cream,
      fontFamily: 'Arial',
      splashColor: AppColors.sunshine.withAlpha(60),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.ink,
          fontSize: 19,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 14),
        color: AppColors.paper,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.borderGray),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.paper,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.borderGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.borderGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.ink, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
        labelStyle: const TextStyle(
          color: AppColors.muted,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: const TextStyle(color: AppColors.muted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.white,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          minimumSize: const Size(0, 50),
          side: const BorderSide(color: AppColors.ink, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.ink,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primary4,
        side: BorderSide.none,
        shape: const StadiumBorder(),
        labelStyle: const TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 52,
          height: 0.95,
          fontWeight: FontWeight.w900,
          letterSpacing: -2.5,
          color: AppColors.ink,
        ),
        displayMedium: TextStyle(
          fontSize: 40,
          height: 1,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.8,
          color: AppColors.ink,
        ),
        displaySmall: TextStyle(
          fontSize: 30,
          height: 1.05,
          fontWeight: FontWeight.w900,
          letterSpacing: -1,
          color: AppColors.ink,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.8,
          color: AppColors.ink,
        ),
        headlineSmall: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.6,
          color: AppColors.ink,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.4,
          color: AppColors.ink,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.45,
          fontWeight: FontWeight.w500,
          color: AppColors.muted,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.45,
          fontWeight: FontWeight.w500,
          color: AppColors.muted,
        ),
        labelLarge: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.ink, size: 24),
      dividerColor: AppColors.borderGray,
      dividerTheme: const DividerThemeData(
        color: AppColors.borderGray,
        thickness: 1,
      ),
    );
  }
}
