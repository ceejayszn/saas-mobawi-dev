import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand Colors ──────────────────────────────────────────────────────────
  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color primaryGreenLight = Color(0xFF2E7D32);
  static const Color primaryGreenAccent = Color(0xFF43A047);
  static const Color gold = Color(0xFFD4AF37);

  // ── Light Mode ────────────────────────────────────────────────────────────
  static const Color scaffoldBackground = Color(0xFFE2E5EA); // Darkened from F5F6FA to reduce eye strain
  static const Color surfaceWhite = Colors.white;
  static const Color cardBackground = Colors.white;
  static const Color dividerLight = Color(0xFFE8ECF0);

  static const Color textPrimary = Color(0xFF1A1D23);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textHint = Color(0xFFADB5BD);
  static const Color textGreen = Color(0xFF2E7D32);

  // ── Dark Mode ─────────────────────────────────────────────────────────────
  static const Color darkScaffold = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF161B22);
  static const Color darkCard = Color(0xFF1C2128);
  static const Color darkBorder = Color(0xFF30363D);

  static const Color darkTextPrimary = Color(0xFFE6EDF3);
  static const Color darkTextSecondary = Color(0xFF8B949E);
  static const Color darkTextHint = Color(0xFF484F58);

  // ── Semantic Colors ───────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDEF0FF);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0xFFEDE9FE);
  static const Color teal = Color(0xFF14B8A6);
  static const Color tealLight = Color(0xFFCCFBF1);
  static const Color orange = Color(0xFFF97316);
  static const Color orangeLight = Color(0xFFFFEDD5);
  static const Color pink = Color(0xFFEC4899);
  static const Color pinkLight = Color(0xFFFCE7F3);

  // ── Shadows ───────────────────────────────────────────────────────────────
  static const Color shadowColor = Color(0x12000000);
  static const Color shadowColorDark = Color(0x40000000);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, primaryGreenAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkHeaderGradient = LinearGradient(
    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
