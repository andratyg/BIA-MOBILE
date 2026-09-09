import 'package:flutter/material.dart';

class VerdaticaTheme {
  // Brand Colors (Organic Botanical & Modern Agriculture)
  static const Color primary = Color(0xFF15803D);       // Rich Forest Emerald
  static const Color primaryDark = Color(0xFF0D472B);   // Deep Pine
  static const Color primaryLight = Color(0xFFE8F5E9);  // Fresh Mint Light
  static const Color primarySurface = Color(0xFFF0FDF4);// Ultra-light Green tint
  static const Color accent = Color(0xFF22C55E);        // Leaf Green Accent

  // Backgrounds
  static const Color bgLight = Color(0xFFF8FAF9);       // Natural Mist
  static const Color bgStone = Color(0xFFF3F5F4);       // Soft Soil Neutral

  // Card & Surfaces
  static const Color cardBg = Colors.white;
  static const Color cardBorder = Color(0xFFE5EBE7);
  static const Color cardBorderSubtle = Color(0xFFF0F4F2);

  // Status Colors (Balanced natural tones)
  static const Color statusRed = Color(0xFFEF4444);
  static const Color statusBlue = Color(0xFF2563EB);
  static const Color statusYellow = Color(0xFFD97706);
  static const Color statusGreen = Color(0xFF16A34A);
  static const Color statusOrange = Color(0xFFEA580C);

  // Typography Colors
  static const Color textPrimary = Color(0xFF0F172A);   // Deep Slate
  static const Color textSecondary = Color(0xFF475569); // Slate Grey
  static const Color textMuted = Color(0xFF94A3B8);     // Muted Slate

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF16A34A), Color(0xFF059669)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF0D3823), Color(0xFF14532D), Color(0xFF166534)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradientWarm = LinearGradient(
    colors: [Color(0xFF0F3E26), Color(0xFF047857)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Common Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF0F3E26).withValues(alpha: 0.05),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get cardShadowHover => [
    BoxShadow(
      color: const Color(0xFF0F3E26).withValues(alpha: 0.09),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accent,
        surface: cardBg,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: bgLight,
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: const CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(color: cardBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: statusRed),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
