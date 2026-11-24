import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.ivory,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.burgundy,
        primary: AppColors.burgundy,
        secondary: AppColors.dustyRose,
        surface: AppColors.porcelain,
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'serif',
          fontSize: 42,
          fontWeight: FontWeight.w600,
          color: AppColors.chocolate,
        ),

        headlineLarge: TextStyle(
          fontFamily: 'serif',
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: AppColors.chocolate,
        ),

        headlineMedium: TextStyle(
          fontFamily: 'serif',
          fontSize: 26,
          color: AppColors.chocolate,
        ),

        titleLarge: TextStyle(
          fontFamily: 'serif',
          fontSize: 22,
          color: AppColors.chocolate,
        ),

        bodyMedium: TextStyle(fontSize: 14, color: AppColors.chocolate),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.ivory,
        foregroundColor: AppColors.chocolate,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.burgundy,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.porcelain,
        contentPadding: const EdgeInsets.all(16),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.burgundy),
        ),
      ),
    );
  }
}
