import 'package:flutter/material.dart';
import 'app_theme.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Ortak UI Bileşenleri — Luxury tasarım diline uygun widget'lar
/// ─────────────────────────────────────────────────────────────────────────────

/// Altın kenarlıklı lüks kart bileşeni.
class LuxuryCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool showGoldAccent;

  const LuxuryCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.showGoldAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: showGoldAccent
                ? AppColors.gold.withOpacity(0.3)
                : AppColors.navyMedium.withOpacity(0.5),
            width: showGoldAccent ? 1 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }
}

/// Altın çizgili bölüm başlığı.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Sol altın çizgi aksanı
          Container(
            width: 3,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),
          if (actionText != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                actionText!,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Altın degradeli şık buton.
class GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool expanded;

  const GoldButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final button = Container(
      height: 54,
      decoration: BoxDecoration(
        gradient: onPressed != null
            ? AppColors.goldGradient
            : null,
        color: onPressed == null ? AppColors.textMuted.withOpacity(0.3) : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.navy,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: AppColors.navy, size: 20),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        label,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );

    return expanded
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}

/// Duruma göre renk ve ikon gösteren durum rozeti.
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 12, color: config.color),
          const SizedBox(width: 6),
          Text(
            config.label,
            style: TextStyle(
              color: config.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  ({Color color, IconData icon, String label}) get _statusConfig {
    switch (status) {
      case 'active':
        return (color: AppColors.success, icon: Icons.play_circle_outline, label: 'Aktif');
      case 'pending':
        return (color: AppColors.warning, icon: Icons.schedule, label: 'Beklemede');
      case 'closed':
        return (color: AppColors.textMuted, icon: Icons.check_circle_outline, label: 'Kapalı');
      case 'confirmed':
        return (color: AppColors.success, icon: Icons.check_circle, label: 'Onaylandı');
      case 'cancelled':
        return (color: AppColors.error, icon: Icons.cancel_outlined, label: 'İptal');
      default:
        return (color: AppColors.info, icon: Icons.info_outline, label: status);
    }
  }
}

/// Logo ve marka adı bileşeni.
class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Terazi ikonu — hukuk sembolü
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.gold, width: 2),
            borderRadius: BorderRadius.circular(size * 0.25),
          ),
          child: Icon(
            Icons.balance,
            color: AppColors.gold,
            size: size * 0.55,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'SB LEGAL',
          style: TextStyle(
            fontFamily: 'Playfair Display',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.gold,
            letterSpacing: 6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'HUKUK & DANIŞMANLIK',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }
}
