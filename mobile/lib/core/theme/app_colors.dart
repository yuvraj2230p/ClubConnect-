import 'package:flutter/material.dart';

class AppColors {
  // Rich Brown & Beige Identity Palette
  static const Color espressoDark = Color(0xFF140D08);     // Deep Roasted Espresso (Background)
  static const Color espresso = Color(0xFF1C130D);         // Dark Coffee
  static const Color warmBrown = Color(0xFF2C1E16);        // Warm Mocha
  static const Color chestnut = Color(0xFF432F23);         // Chestnut Brown
  static const Color caramel = Color(0xFFB87D4B);          // Rich Caramel Accent
  static const Color lightCaramel = Color(0xFFC99365);     // Golden Caramel

  // Warm Beige & Cream Shades
  static const Color beige = Color(0xFFDDB892);            // Classic Warm Beige
  static const Color softBeige = Color(0xFFE6CCB2);        // Soft Almond Beige
  static const Color cream = Color(0xFFF5EBE0);            // Vanilla Cream Text
  static const Color ivory = Color(0xFFFAF6F0);            // Bright Ivory
  static const Color amberHoney = Color(0xFFE5A962);       // Honey Accent
  static const Color accentCyan = Color(0xFF52B788);       // Sage Emerald Verified Badge

  // Aliases for compatibility
  static const Color primaryDark = espressoDark;
  static const Color primary = warmBrown;
  static const Color primaryLight = chestnut;
  static const Color accentIndigo = caramel;               // Replaced with Caramel
  static const Color accentGold = beige;                   // Replaced with Beige
  
  // Backgrounds & Surfaces
  static const Color bgDark = espressoDark;
  static const Color surfaceDark = Color(0xFF1E140E);
  static const Color surfaceCard = Color(0xFF2A1C14);
  static const Color surfaceBorder = Color(0xFF4A3425);

  // Translucent / Glassmorphism Surfaces for photo show-through
  static const Color glassCard = Color(0xCC261912);       // 80% opacity warm mocha
  static const Color glassCardSubtle = Color(0xAA1F140D); // 66% opacity for deep blur
  static const Color glassBorder = Color(0x40DDB892);     // 25% opacity beige border

  // Text Colors
  static const Color textPrimary = ivory;
  static const Color textSecondary = softBeige;
  static const Color textMuted = Color(0xFFA89687);

  // Status & Feedback
  static const Color success = Color(0xFF52B788);
  static const Color warning = Color(0xFFE09F3E);
  static const Color error = Color(0xFFD64545);

  // Warm Collegiate Gradients
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0x66140D08),
      Color(0xCC140D08),
      Color(0xFF140D08),
    ],
    stops: [0.0, 0.4, 0.75, 1.0],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8F5E36), Color(0xFFC99365)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient caramelGradient = LinearGradient(
    colors: [Color(0xFFB87D4B), Color(0xFFDDB892)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFDDB892), Color(0xFFE5A962)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0xDD2D1E16), Color(0xBB1F140D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
