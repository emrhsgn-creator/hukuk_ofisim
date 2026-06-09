import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_theme.dart';
import 'models.dart';
import 'firebase_service.dart';
import 'common_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static String _tarih(DateTime? d) {
    if (d == null) return '';
    String iki(int n) => n.toString().padLeft(2, '0');
    return '${iki(d.day)}.${iki(d.month)}.${d.year} ${iki(d.hour)}:${iki(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email;
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: const Text('Bildirimler', style: TextStyle(color: AppColors.gold)),
        automaticallyImplyLeading: false,
      ),
      body: email == null
          ? const Center(
              child: Text('Oturum hatası.',
                  style: TextStyle(color: AppColors.error)))
          : StreamBuilder<List<AppNotification>>(
              stream: FirestoreService().getClientNotifications(email),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.gold));
                }
                final items = snap.data ?? [];
                if (items.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_none,
                              size: 56, color: AppColors.textMuted),
                          SizedBox(height: 12),
                          Text('Henüz bildiriminiz yok.',
                              style: TextStyle(color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: items.length,
                  itemBuilder: (context, i) => _NotifCard(notif: items[i]),
                );
              },
            ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final AppNotification notif;
  const _NotifCard({required this.notif});

  void _ac(BuildContext context) {
    if (!notif.read) {
      FirestoreService().markNotificationRead(notif.id);
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(notif.title,
            style: const TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notif.caseTitle.isNotEmpty) ...[
              Text(notif.caseTitle,
                  style: const TextStyle(
                      color: AppColors.goldDark,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
            ],
            Text(notif.body,
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Text(NotificationsScreen._tarih(notif.createdAt),
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kapat',
                style: TextStyle(color: AppColors.goldDark)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unread = !notif.read;
    return LuxuryCard(
      showGoldAccent: unread,
      onTap: () => _ac(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              notif.type == 'hearing'
                  ? Icons.gavel
                  : Icons.notifications_active,
              color: AppColors.goldDark,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(notif.title,
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight:
                                  unread ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 15)),
                    ),
                    if (unread)
                      Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                            color: AppColors.gold, shape: BoxShape.circle),
                      ),
                  ],
                ),
                if (notif.caseTitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(notif.caseTitle,
                      style: const TextStyle(
                          color: AppColors.goldDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
                const SizedBox(height: 6),
                Text(notif.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 6),
                Text(NotificationsScreen._tarih(notif.createdAt),
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
