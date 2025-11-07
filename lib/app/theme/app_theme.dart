import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.background,
        onSurface: AppColors.foreground,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.foreground, fontSize: 16),
        bodyMedium: TextStyle(color: AppColors.foreground, fontSize: 14),
        titleLarge: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
        // Estilos adicionales para onboarding
        displayMedium: TextStyle(
          color: AppColors.primary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        bodySmall: TextStyle(
          color: AppColors.foreground,
          fontSize: 16,
          height: 1.5,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
