import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// SB Legal — Aydınlık / Ferah Tema
/// ─────────────────────────────────────────────────────────────────────────────
/// Açık, havadar bir zemin (#F4F6FB) üzerinde beyaz kartlar; altın (#C9A227)
/// marka vurgusu ve koyu lacivort "mürekkep" (ink) ile prestijli ama ferah bir
/// görünüm hedeflenir.
///
/// NOT: Token isimleri eski (koyu) temadan korunmuştur ama DEĞERLERİ artık
/// AÇIK temayı temsil eder. Böylece ekranlardaki mevcut `AppColors.navy` /
/// `AppColors.navyLight` referansları otomatik olarak açık temaya uyar.
///   • navy        → sayfa zemini (açık)
///   • navyLight   → kart/yüzey (beyaz)
///   • navyMedium  → kenarlık/ayraç (açık gri)
///   • ink         → altın/renkli yüzey üstündeki KOYU yazı-ikon
/// ─────────────────────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  // ── Zemin & Yüzeyler (açık) ──
  static const Color navy       = Color(0xFFF4F6FB); // sayfa zemini
  static const Color navyLight  = Color(0xFFFFFFFF); // kart / yüzey
  static const Color navyMedium = Color(0xFFE3E8F0); // kenarlık / ayraç
  static const Color surface    = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFEDF1F7); // input dolgusu / hafif vurgu
  static const Color card       = Color(0xFFFFFFFF);
  static const Color cardHover  = Color(0xFFF0F4FA);

  // ── Marka ──
  static const Color ink        = Color(0xFF0A192F); // koyu mürekkep (altın üstü yazı)
  static const Color navyDeep   = Color(0xFF112240); // koyu aksan (başlık/ikon gerektiğinde)
  static const Color gold       = Color(0xFFC9A227);
  static const Color goldLight  = Color(0xFFE8D48B);
  static const Color goldDark   = Color(0xFF9A7B17);

  // ── Metin (açık zeminde koyu) ──
  static const Color textPrimary   = Color(0xFF15233B);
  static const Color textSecondary = Color(0xFF5B6B86);
  static const Color textMuted     = Color(0xFF93A0B6);

  // ── Durum ──
  static const Color success = Color(0xFF1FA971);
  static const Color warning = Color(0xFFE0921A);
  static const Color error   = Color(0xFFE05656);
  static const Color info    = Color(0xFF2E86DE);

  // ── Gradient ──
  static const LinearGradient goldGradient = LinearGradient(
    colors: [gold, goldLight, gold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Açık, ferah arka plan geçişi
  static const LinearGradient navyGradient = LinearGradient(
    colors: [Color(0xFFF7F9FC), Color(0xFFEAF0F8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Yumuşak kart gölgesi
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFF1B2A4A).withOpacity(0.06),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];
}

class AppTheme {
  AppTheme._();

  /// Material 3 — aydınlık ferah tema
  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.navy,
      colorScheme: const ColorScheme.light(
        primary: AppColors.gold,
        onPrimary: AppColors.ink,
        secondary: AppColors.goldDark,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.navy,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 21,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: AppColors.goldDark),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.navyMedium, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceAlt,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.navyMedium),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.navyMedium, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.2),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        prefixIconColor: AppColors.goldDark,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.ink,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.navyMedium,
        thickness: 1,
        space: 24,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.goldDark,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle:
            TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),

      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );

    // Gerçek tipografi: başlıklar Playfair Display, gövde Inter
    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary),
        headlineLarge: GoogleFonts.playfairDisplay(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary),
        headlineMedium: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary),
        titleLarge: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary),
        bodyLarge: GoogleFonts.inter(
            fontSize: 16, color: AppColors.textSecondary, height: 1.6),
        bodyMedium: GoogleFonts.inter(
            fontSize: 14, color: AppColors.textSecondary, height: 1.5),
      ),
    );
  }

  // Geriye dönük uyumluluk: eski kod AppTheme.darkTheme çağırıyorsa açık tema döner.
  static ThemeData get darkTheme => lightTheme;
}
