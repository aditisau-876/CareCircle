import 'package:flutter/material.dart';

class CareCircleColors {
  static const primary = Color(0xFF2F7D73);
  static const primaryDark = Color(0xFF215B54);
  static const primaryLight = Color(0xFFE5F3F0);

  static const secondary = Color(0xFFF3A86B);
  static const secondaryLight = Color(0xFFFFF0E4);

  static const background = Color(0xFFF8FAF9);
  static const surface = Colors.white;

  static const textPrimary = Color(0xFF18302D);
  static const textSecondary = Color(0xFF6B7C79);
  static const border = Color(0xFFE3EAE8);

  static const success = Color(0xFF4D9A72);
  static const danger = Color(0xFFD95C5C);
}

class CareCircleTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      scaffoldBackgroundColor: CareCircleColors.background,

      colorScheme: ColorScheme.fromSeed(
        seedColor: CareCircleColors.primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: CareCircleColors.primary,
        secondary: CareCircleColors.secondary,
        surface: CareCircleColors.surface,
      ),

      fontFamily: 'sans',

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: CareCircleColors.textPrimary,
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 38,
          fontWeight: FontWeight.w700,
          color: CareCircleColors.textPrimary,
          height: 1.1,
        ),
        displayMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: CareCircleColors.textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: CareCircleColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: CareCircleColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: CareCircleColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: CareCircleColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: CareCircleColors.textSecondary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: CareCircleColors.textSecondary,
          height: 1.45,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: CareCircleColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: CareCircleColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: CareCircleColors.primary,
            width: 1.5,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CareCircleColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}