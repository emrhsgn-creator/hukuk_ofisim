import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';

/// Geniş ekranlarda içeriği ortalayıp maksimum genişlikle sınırlar — ferah,
/// nefes alan bir düzen sağlar (web/masaüstünde içeriğin gerilmesini önler).
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const ResponsiveCenter({super.key, required this.child, this.maxWidth = 1080});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= maxWidth) return child;
        // Geniş ekranda içeriği ortala; yüksekliği tam tut (Scaffold için).
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            SizedBox(width: maxWidth, child: child),
            const Spacer(),
          ],
        );
      },
    );
  }
}

/// Logo widget'ı
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      'https://i.ibb.co/07PH08Q/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          Icon(Icons.balance, size: size, color: AppColors.gold),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return SizedBox(
          width: size,
          height: size,
          child: const Center(
              child: CircularProgressIndicator(
                  color: AppColors.gold, strokeWidth: 2)),
        );
      },
    );
  }
}

/// Durum Rozetleri
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    switch (status) {
      case 'active': color = AppColors.success; text = "Aktif"; break;
      case 'pending': color = AppColors.warning; text = "İşlemde"; break;
      case 'closed': color = AppColors.textMuted; text = "Kapalı"; break;
      case 'approved': color = AppColors.success; text = "Onaylandı"; break;
      case 'rejected': color = AppColors.error; text = "Reddedildi"; break;
      default: color = AppColors.goldDark; text = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 11.5, fontWeight: FontWeight.w700)),
    );
  }
}

/// Ortak altın buton
class GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;

  const GoldButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.isLoading = false,
      this.icon});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.ink,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        shadowColor: AppColors.gold.withOpacity(0.4),
      ),
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child:
                  CircularProgressIndicator(color: AppColors.ink, strokeWidth: 2.5))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppColors.ink, size: 20),
                  const SizedBox(width: 8)
                ],
                Text(label,
                    style: const TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
              ],
            ),
    );
  }
}

/// Ferah, yumuşak kart
class LuxuryCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool showGoldAccent;
  const LuxuryCard(
      {super.key,
      required this.child,
      this.onTap,
      this.showGoldAccent = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: showGoldAccent
                ? AppColors.gold.withOpacity(0.55)
                : AppColors.navyMedium),
        boxShadow: AppColors.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Bölüm başlıkları
class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(title,
              style: GoogleFonts.playfairDisplay(
                  color: AppColors.textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
