import 'package:flutter/material.dart';
import 'app_theme.dart'; // Klasör yolu farklıysa başındaki core/ kısmını silebilirsin
import 'profile_screen.dart'; // Ortak profil ekranını kullanıyoruz

class LawyerMainShell extends StatefulWidget {
  const LawyerMainShell({super.key});

  @override
  State<LawyerMainShell> createState() => _LawyerMainShellState();
}

class _LawyerMainShellState extends State<LawyerMainShell> {
  int _currentIndex = 0;

  // Avukatın göreceği sayfalar (Şimdilik yer tutucu metinler koyduk)
  final _pages = const [
    Center(child: Text('Tüm Müvekkil Dosyaları Burada Olacak', style: TextStyle(color: AppColors.gold, fontSize: 18))),
    Center(child: Text('Gelen Randevu Talepleri Burada Olacak', style: TextStyle(color: AppColors.gold, fontSize: 18))),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yönetim Paneli'),
      ),
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
        border: Border(top: BorderSide(color: AppColors.navyMedium.withOpacity(0.3))),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.folder_shared_outlined, Icons.folder_shared, 'Dosyalar'),
              _navItem(1, Icons.event_available_outlined, Icons.event_available, 'Talepler'),
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
          color: isActive ? AppColors.gold.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : icon, color: isActive ? AppColors.gold : AppColors.textMuted, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isActive ? AppColors.gold : AppColors.textMuted, fontSize: 11, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}