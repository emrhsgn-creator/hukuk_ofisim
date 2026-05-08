import 'package:flutter/material.dart';
import 'app_theme.dart';

/// 🌟 LOGIN EKRANINDAKİ HATAYI ÇÖZEN LOGO WIDGET'I
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      'https://i.ibb.co/07PH08Q/logo.png', // Senin yüklediğin logo linki
      width: size,
      height: size,
      fit: BoxFit.contain,
      // İnternet gitse bile uygulama çökmesin diye yedek ikon:
      errorBuilder: (context, error, stackTrace) => 
          Icon(Icons.balance, size: size, color: AppColors.gold),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return SizedBox(
          width: size,
          height: size,
          child: const Center(child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2)),
        );
      },
    );
  }
}

/// Durum Rozetleri (Aktif, İşlemde, Kapalı)
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    switch (status) {
      case 'active': color = AppColors.success; text = "Aktif"; break;
      case 'pending': color = Colors.orange; text = "İşlemde"; break;
      case 'closed': color = AppColors.textMuted; text = "Kapalı"; break;
      case 'approved': color = AppColors.success; text = "Onaylandı"; break;
      case 'rejected': color = AppColors.error; text = "Reddedildi"; break;
      default: color = AppColors.gold; text = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), 
        borderRadius: BorderRadius.circular(6), 
        border: Border.all(color: color.withOpacity(0.5))
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

/// Ortak Buton Tasarımı
class GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;

  const GoldButton({super.key, required this.label, required this.onPressed, this.isLoading = false, this.icon});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      child: isLoading 
        ? const CircularProgressIndicator(color: AppColors.navy)
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, color: AppColors.navy, size: 20), const SizedBox(width: 8)],
              Text(label, style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
    );
  }
}

/// Lüks Kart Tasarımı
class LuxuryCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool showGoldAccent;
  const LuxuryCard({super.key, required this.child, this.onTap, this.showGoldAccent = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.navyLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: showGoldAccent ? AppColors.gold.withOpacity(0.5) : AppColors.navyMedium),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// Bölüm Başlıkları
class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(title, style: const TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Playfair Display')),
    );
  }
}