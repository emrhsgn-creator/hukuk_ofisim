import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'lawyer_dashboard_screen.dart'; // 🌟 Turuncu çizgi buradaysa, aşağıda kullanınca gidecek
import 'lawyer_cases_screen.dart';
import 'lawyer_appointments_screen.dart';
import 'lawyer_clients_screen.dart';
import 'profile_screen.dart';
import 'common_widgets.dart';

class LawyerMainShell extends StatefulWidget {
  const LawyerMainShell({super.key});

  @override
  State<LawyerMainShell> createState() => _LawyerMainShellState();
}

class _LawyerMainShellState extends State<LawyerMainShell> {
  int _currentIndex = 0;

  // 🌟 BURAYI DİKKATLİCE KONTROL ET: 5 SEKME DE BURADA OLMALI
  final _pages = const [
    LawyerDashboardScreen(), // 0: Özet (Turuncu çizgiyi bu satır yok eder)
    LawyerCasesScreen(), // 1: Dosyalar
    LawyerClientsScreen(), // 2: Müvekkiller (Excel Yükleme Burada)
    LawyerAppointmentsScreen(), // 3: Talepler
    ProfileScreen(), // 4: Profil
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: ResponsiveCenter(
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.dashboard_outlined, Icons.dashboard, 'Özet'),
              _navItem(
                  1, Icons.folder_copy_outlined, Icons.folder_copy, 'Dosyalar'),
              _navItem(2, Icons.people_outline, Icons.people,
                  'Müvekkiller'), // 🌟 Müvekkil Sekmesi
              _navItem(
                  3, Icons.event_note_outlined, Icons.event_note, 'Talepler'),
              _navItem(4, Icons.person_outline, Icons.person, 'Profil'),
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}
