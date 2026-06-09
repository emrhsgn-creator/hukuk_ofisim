import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_theme.dart';
import 'profile_screen.dart';
import 'client_cases_screen.dart';
import 'client_dashboard_screen.dart';
import 'notifications_screen.dart';
import 'common_widgets.dart';
import 'models.dart';
import 'firebase_service.dart';

class ClientMainShell extends StatefulWidget {
  const ClientMainShell({super.key});

  @override
  State<ClientMainShell> createState() => _ClientMainShellState();
}

class _ClientMainShellState extends State<ClientMainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ClientDashboardScreen(),
    ClientCasesScreen(),
    NotificationsScreen(),
    ProfileScreen(),
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
            top: BorderSide(color: AppColors.navyMedium.withOpacity(0.6))),
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
              _navItem(2, Icons.notifications_none, Icons.notifications,
                  'Bildirimler',
                  withBadge: true),
              _navItem(3, Icons.person_outline, Icons.person, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label,
      {bool withBadge = false}) {
    final isActive = _currentIndex == index;
    Widget iconWidget = Icon(isActive ? activeIcon : icon,
        color: isActive ? AppColors.goldDark : AppColors.textMuted, size: 24);

    if (withBadge) {
      iconWidget = _UnreadBadge(child: iconWidget);
    }

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color:
              isActive ? AppColors.gold.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: isActive ? AppColors.goldDark : AppColors.textMuted,
                    fontSize: 11,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}

/// Okunmamış bildirim sayısını canlı dinleyip ikonun üstüne rozet koyar.
class _UnreadBadge extends StatelessWidget {
  final Widget child;
  const _UnreadBadge({required this.child});

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return child;
    return StreamBuilder<List<AppNotification>>(
      stream: FirestoreService().getClientNotifications(email),
      builder: (context, snap) {
        final unread = (snap.data ?? []).where((n) => !n.read).length;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            if (unread > 0)
              Positioned(
                right: -6,
                top: -4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  constraints: const BoxConstraints(minWidth: 16),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.surface, width: 1.5),
                  ),
                  child: Text(
                    unread > 9 ? '9+' : '$unread',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
