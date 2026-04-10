import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'dashboard_screen.dart';
import 'appointment_screen.dart';
import 'profile_screen.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Ana Kabuk (Main Shell) — Alt navigasyon barı ile sayfa yönetimi
/// ─────────────────────────────────────────────────────────────────────────────
/// IndexedStack kullanarak sayfa durumlarını korur (state preservation).
/// ─────────────────────────────────────────────────────────────────────────────
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  /// Navigasyon sayfaları.
  final _pages = const [
    DashboardScreen(),
    AppointmentScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack: Sayfa geçişlerinde durumu korur
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // ── Özelleştirilmiş Alt Navigasyon ──
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  /// Luxury tasarım dilinde alt navigasyon barı.
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navyLight,
        border: Border(
          top: BorderSide(color: AppColors.navyMedium.withOpacity(0.3)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.dashboard_outlined, Icons.dashboard, 'Ana Sayfa'),
              _navItem(1, Icons.event_outlined, Icons.event, 'Randevu'),
              _navItem(2, Icons.person_outline, Icons.person, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  /// Tek bir navigasyon öğesi.
  Widget _navItem(int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.gold.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.gold : AppColors.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.gold : AppColors.textMuted,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
