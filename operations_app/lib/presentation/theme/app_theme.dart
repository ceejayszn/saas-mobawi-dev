import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: 'Helvetica',
      primaryColor: AppColors.primaryGreen,
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryGreen,
        secondary: AppColors.primaryGreen,
        surface: AppColors.surfaceWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black, // Dark/pure header background for premium contrast
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: 'Helvetica',
          fontWeight: FontWeight.bold,
          fontSize: 20,
          letterSpacing: 0.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceWhite,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(color: AppColors.textPrimary, fontFamily: 'Helvetica', fontWeight: FontWeight.bold, letterSpacing: -0.5),
        titleLarge: TextStyle(color: AppColors.textPrimary, fontFamily: 'Helvetica', fontWeight: FontWeight.bold, letterSpacing: -0.5),
        bodyLarge: TextStyle(color: AppColors.textPrimary, fontFamily: 'Helvetica', letterSpacing: 0.1),
        bodyMedium: TextStyle(color: AppColors.textSecondary, fontFamily: 'Helvetica', letterSpacing: 0.1),
        labelLarge: TextStyle(color: Colors.white, fontFamily: 'Helvetica', fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontFamily: 'Helvetica',
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceWhite,
        elevation: 4,
        shadowColor: AppColors.shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
