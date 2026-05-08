import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'profile_screen.dart';
import 'client_cases_screen.dart'; // 🌟 Yeni dosyamızı buraya çağırdık
import 'client_dashboard_screen.dart';

class ClientMainShell extends StatefulWidget {
  const ClientMainShell({super.key});

  @override
  State<ClientMainShell> createState() => _ClientMainShellState();
}

class _ClientMainShellState extends State<ClientMainShell> {
  int _currentIndex = 0;

  // 🌟 MÜVEKKİL SEKMELERİ GÜNCELLENDİ
  final List<Widget> _pages = [
    const ClientDashboardScreen(), // 🌟 Artık boş değil, canavar gibi bir özet ekranı!
    const ClientCasesScreen(),
    const ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
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
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navItem(0, Icons.dashboard_outlined, Icons.dashboard, 'Özet'),
              _navItem(1, Icons.folder_shared_outlined, Icons.folder_shared,
                  'Dosyalarım'),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
