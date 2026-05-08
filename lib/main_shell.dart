import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'profile_screen.dart';
import 'dashboard_screen.dart'; // 🌟 YENİ: Dosyalar listesi yerine Ana Sayfa (Dashboard) geldi
import 'appointment_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // 🌟 Müvekkilin göreceği sayfalar güncellendi
  final _pages = const [
    DashboardScreen(), // 1. Sekme: Altın duruşma kartının olduğu Ana Sayfa
    AppointmentScreen(), // 2. Sekme: Randevular
    ProfileScreen(), // 3. Sekme: Profil
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy, // Ana arka planı lacivert yaptık
      // 🌟 AppBar'ı sildik çünkü DashboardScreen kendi özel başlığıyla geliyor, çok daha şık duracak!
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navyLight,
        border: Border(
            top: BorderSide(color: AppColors.navyMedium.withOpacity(0.3))),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 🌟 İkonu (Ev) ve Metni (Ana Sayfa) olarak değiştirdik
              _navItem(0, Icons.home_outlined, Icons.home, 'Ana Sayfa'),
              _navItem(1, Icons.calendar_month_outlined, Icons.calendar_month,
                  'Randevu'),
              _navItem(2, Icons.person_outline, Icons.person, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color:
              isActive ? AppColors.gold.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : icon,
                color: isActive ? AppColors.gold : AppColors.textMuted,
                size: 24),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: isActive ? AppColors.gold : AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}
