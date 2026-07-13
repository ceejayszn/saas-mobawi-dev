import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NexusTheme {
  // Brand Color Palette
  static const Color primary = Color(0xFF10B981);       // Mobawi Green
  static const Color accent = Color(0xFF10B981);        // Mobawi Green (primary fallback)
  static const Color accentSecondary = Color(0xFF2563EB);  // Professional Blue
  
  // Theme-independent Semantic Status Colors
  static const Color success = Color(0xFF10B981);        // Green
  static const Color warning = Color(0xFFF59E0B);        // Amber
  static const Color error = Color(0xFFEF4444);          // Red
  static const Color info = Color(0xFF3B82F6);           // Blue

  // Dark Mode Neutrals (Default Static Constants for Const Contexts)
  static const Color background = Color(0xFF0F172A);     // Slate 900
  static const Color surface = Color(0xFF1E293B);        // Slate 800
  static const Color surfaceElevated = Color(0xFF334155); // Slate 700
  static const Color border = Color(0xFF334155);         // Slate 700
  static const Color borderGlow = Color(0xFF475569);     // Slate 600
  static const Color textPrimary = Color(0xFFF8FAFC);    // Slate 50
  static const Color textSecondary = Color(0xFF94A3B8);  // Slate 400
  static const Color textMuted = Color(0xFF64748B);      // Slate 500

  // Light Mode Neutrals
  static const Color lightBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color lightSurface = Color(0xFFFFFFFF);    // White
  static const Color lightBorder = Color(0xFFE2E8F0);     // Slate 200
  static const Color lightTextPrimary = Color(0xFF0F172A);  // Slate 900
  static const Color lightTextSecondary = Color(0xFF64748B);// Slate 500

  static ThemeData get darkTheme {
    final baseFont = GoogleFonts.plusJakartaSans();
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      cardColor: surface,
      dividerColor: border,
      fontFamily: baseFont.fontFamily,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 32),
        displayMedium: GoogleFonts.plusJakartaSans(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 28),
        headlineLarge: GoogleFonts.plusJakartaSans(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 24),
        headlineMedium: GoogleFonts.plusJakartaSans(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 20),
        titleLarge: GoogleFonts.plusJakartaSans(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
        titleMedium: GoogleFonts.plusJakartaSans(color: textSecondary, fontWeight: FontWeight.w500, fontSize: 14),
        bodyLarge: GoogleFonts.plusJakartaSans(color: textPrimary, fontSize: 14, height: 1.5),
        bodyMedium: GoogleFonts.plusJakartaSans(color: textSecondary, fontSize: 13, height: 1.4),
        labelLarge: GoogleFonts.jetBrainsMono(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
      ),
      colorScheme: const ColorScheme.dark(
        surface: surface,
        primary: primary,
        secondary: accentSecondary,
        error: error,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        space: 1,
        thickness: 1,
      ),
    );
  }

  static ThemeData get lightTheme {
    final baseFont = GoogleFonts.plusJakartaSans();
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      primaryColor: primary,
      cardColor: lightSurface,
      dividerColor: lightBorder,
      fontFamily: baseFont.fontFamily,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(color: lightTextPrimary, fontWeight: FontWeight.w700, fontSize: 32),
        displayMedium: GoogleFonts.plusJakartaSans(color: lightTextPrimary, fontWeight: FontWeight.w700, fontSize: 28),
        headlineLarge: GoogleFonts.plusJakartaSans(color: lightTextPrimary, fontWeight: FontWeight.w600, fontSize: 24),
        headlineMedium: GoogleFonts.plusJakartaSans(color: lightTextPrimary, fontWeight: FontWeight.w600, fontSize: 20),
        titleLarge: GoogleFonts.plusJakartaSans(color: lightTextPrimary, fontWeight: FontWeight.w600, fontSize: 16),
        titleMedium: GoogleFonts.plusJakartaSans(color: lightTextSecondary, fontWeight: FontWeight.w500, fontSize: 14),
        bodyLarge: GoogleFonts.plusJakartaSans(color: lightTextPrimary, fontSize: 14, height: 1.5),
        bodyMedium: GoogleFonts.plusJakartaSans(color: lightTextSecondary, fontSize: 13, height: 1.4),
        labelLarge: GoogleFonts.jetBrainsMono(color: lightTextSecondary, fontSize: 12, fontWeight: FontWeight.w500),
      ),
      colorScheme: const ColorScheme.light(
        surface: lightSurface,
        primary: primary,
        secondary: accentSecondary,
        error: error,
        onPrimary: Colors.white,
        onSurface: lightTextPrimary,
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: lightBorder,
        space: 1,
        thickness: 1,
      ),
    );
  }
}
