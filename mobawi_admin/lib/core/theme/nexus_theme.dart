import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NexusTheme {
  // Brand Color Palette (Stovest inspired)
  static const Color primary = Color(0xFF1B7DFF);       // Neon Blue Accent
  static const Color accent = Color(0xFF1B7DFF);        
  static const Color accentSecondary = Color(0xFF00C2FF);  // Lighter cyan
  
  // Theme-independent Semantic Status Colors
  static const Color success = Color(0xFF10B981);        // Green
  static const Color warning = Color(0xFFF59E0B);        // Amber
  static const Color error = Color(0xFFEF4444);          // Red
  static const Color info = Color(0xFF3B82F6);           // Blue

  // Dark Mode Neutrals (Deep Space Blue)
  static const Color background = Color(0xFF050B14);     // Deep Space Blue
  static const Color surface = Color(0xFF111621);        // Darker blue-grey cards
  static const Color surfaceElevated = Color(0xFF161C2A); 
  static const Color border = Color(0xFF1C2436);         // Subtle borders
  static const Color borderGlow = Color(0xFF1B7DFF);     
  static const Color textPrimary = Color(0xFFFFFFFF);    // Bright white
  static const Color textSecondary = Color(0xFF8C9AB0);  // Muted blue-grey
  static const Color textMuted = Color(0xFF566782);      

  // Light Mode Neutrals (Kept for compatibility, but optimized for Dark)
  static const Color lightBackground = Color(0xFFF8FAFC); 
  static const Color lightSurface = Color(0xFFFFFFFF);    
  static const Color lightBorder = Color(0xFFE2E8F0);     
  static const Color lightTextPrimary = Color(0xFF0F172A);  
  static const Color lightTextSecondary = Color(0xFF64748B);

  static ThemeData get darkTheme {
    final baseFont = GoogleFonts.inter(); // Switching to Inter for clean tech UI
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      cardColor: surface,
      dividerColor: border,
      fontFamily: baseFont.fontFamily,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 32),
        displayMedium: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 28),
        headlineLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 24),
        headlineMedium: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 20),
        titleLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
        titleMedium: GoogleFonts.inter(color: textSecondary, fontWeight: FontWeight.w500, fontSize: 14),
        bodyLarge: GoogleFonts.inter(color: textPrimary, fontSize: 14, height: 1.5),
        bodyMedium: GoogleFonts.inter(color: textSecondary, fontSize: 13, height: 1.4),
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
          borderRadius: BorderRadius.circular(20), // More rounded
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
    final baseFont = GoogleFonts.inter();
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      primaryColor: primary,
      cardColor: lightSurface,
      dividerColor: lightBorder,
      fontFamily: baseFont.fontFamily,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(color: lightTextPrimary, fontWeight: FontWeight.w700, fontSize: 32),
        displayMedium: GoogleFonts.inter(color: lightTextPrimary, fontWeight: FontWeight.w700, fontSize: 28),
        headlineLarge: GoogleFonts.inter(color: lightTextPrimary, fontWeight: FontWeight.w600, fontSize: 24),
        headlineMedium: GoogleFonts.inter(color: lightTextPrimary, fontWeight: FontWeight.w600, fontSize: 20),
        titleLarge: GoogleFonts.inter(color: lightTextPrimary, fontWeight: FontWeight.w600, fontSize: 16),
        titleMedium: GoogleFonts.inter(color: lightTextSecondary, fontWeight: FontWeight.w500, fontSize: 14),
        bodyLarge: GoogleFonts.inter(color: lightTextPrimary, fontSize: 14, height: 1.5),
        bodyMedium: GoogleFonts.inter(color: lightTextSecondary, fontSize: 13, height: 1.4),
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
          borderRadius: BorderRadius.circular(20),
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
