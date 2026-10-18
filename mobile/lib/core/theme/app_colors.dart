import 'package:flutter/material.dart';

class AppColors {
  // GL Bajaj Identity & Primary Shades
  static const Color primaryDark = Color(0xFF091428);      // Midnight Sapphire
  static const Color primary = Color(0xFF0E2A47);          // GL Bajaj Deep Navy
  static const Color primaryLight = Color(0xFF1E3A8A);     // Royal Blue
  static const Color accentIndigo = Color(0xFF4361EE);     // Vibrant Tech Blue
  static const Color accentGold = Color(0xFFFFB703);       // College Gold / Amber
  static const Color accentCyan = Color(0xFF06D6A0);       // Success Emerald

  // Backgrounds & Surfaces
  static const Color bgDark = Color(0xFF050B14);           // Ultra Dark Background
  static const Color surfaceDark = Color(0xFF0D1B2A);       // Elevated Card Dark
  static const Color surfaceCard = Color(0xFF132238);       // Card Background
  static const Color surfaceBorder = Color(0xFF1F3554);     // Border outline

  // Light Mode Surfaces (if needed)
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Status & Feedback
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Gradients
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0x99050B14),
      Color(0xFF050B14),
    ],
    stops: [0.3, 0.7, 1.0],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF4361EE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFB703), Color(0xFFFB8500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
