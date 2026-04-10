import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// SB Legal — Luxury Tema Tanımlamaları
/// ─────────────────────────────────────────────────────────────────────────────
/// Koyu lacivert (#0A192F) zemin üzerinde altın sarısı (#D4AF37) aksanlarla
/// prestijli ve güven veren bir görünüm hedeflenir.
/// ─────────────────────────────────────────────────────────────────────────────

class AppColors {
  AppColors._(); // instance oluşturmayı engelle

  // ── Ana Renkler ──
  static const Color navy         = Color(0xFF0A192F);
  static const Color navyLight    = Color(0xFF112240);
  static const Color navyMedium   = Color(0xFF1D3557);
  static const Color gold         = Color(0xFFD4AF37);
  static const Color goldLight    = Color(0xFFE8D48B);
  static const Color goldDark     = Color(0xFFB8960C);

  // ── Yüzey ve Arka Plan ──
  static const Color surface      = Color(0xFF0F2137);
  static const Color card         = Color(0xFF152A45);
  static const Color cardHover    = Color(0xFF1A3352);

  // ── Metin Renkleri ──
  static const Color textPrimary  = Color(0xFFF0F0F0);
  static const Color textSecondary= Color(0xFF8892B0);
  static const Color textMuted    = Color(0xFF5A6785);

  // ── Durum Renkleri ──
  static const Color success      = Color(0xFF2ECC71);
  static const Color warning      = Color(0xFFF39C12);
  static const Color error        = Color(0xFFE74C3C);
  static const Color info         = Color(0xFF3498DB);

  // ── Gradient ──
  static const LinearGradient goldGradient = LinearGradient(
    colors: [gold, goldLight, gold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient navyGradient = LinearGradient(
    colors: [navy, navyLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppTheme {
  AppTheme._();

  /// Material 3 teması — koyu luxury mod
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.navy,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        onPrimary: AppColors.navy,
        secondary: AppColors.goldLight,
        onSecondary: AppColors.navy,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),

      // ── AppBar ──
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontFamily: 'Playfair Display',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.gold,
          letterSpacing: 1.2,
        ),
        iconTheme: IconThemeData(color: AppColors.gold),
      ),

      // ── Kartlar ──
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.navyMedium, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      ),

      // ── Metin Temaları ──
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Playfair Display',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Playfair Display',
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Playfair Display',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0.3,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.gold,
          letterSpacing: 1.0,
        ),
      ),

      // ── Input Alanları ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.navyLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.navyMedium),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.navyMedium, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        labelStyle: const TextStyle(color: AppColors.textMuted),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        prefixIconColor: AppColors.gold,
      ),

      // ── Elevated Button ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.navy,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ),

      // ── Divider ──
      dividerTheme: const DividerThemeData(
        color: AppColors.navyMedium,
        thickness: 0.5,
      ),

      // ── Bottom Navigation ──
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.navyLight,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),
    );
  }
}
