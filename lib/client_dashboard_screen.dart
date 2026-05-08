import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_theme.dart';
import 'models.dart';
import 'common_widgets.dart';

class ClientDashboardScreen extends StatelessWidget {
  const ClientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: const Text('SB Legal Özet',
            style: TextStyle(color: AppColors.gold)),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<QuerySnapshot>(
        // 1. Müvekkilin profilini e-posta ile buluyoruz
        future: FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUser?.email)
            .limit(1)
            .get(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.gold));
          }

          if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('Profil yüklenemedi.',
                    style: TextStyle(color: Colors.white)));
          }

          final userDoc = userSnapshot.data!.docs.first;
          final userData = userDoc.data() as Map<String, dynamic>;

          // Kimlik bilgilerini al (id veya uid fark etmeksizin)
          final String firestoreUid =
              userData['uid'] ?? userData['id'] ?? userDoc.id;
          final String fullName = userData['fullName'] ?? 'Müvekkilimiz';

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            // 2. Müvekkile ait dosyaları canlı dinle
            stream: FirebaseFirestore.instance
                .collection('cases')
                .where('clientId', isEqualTo: firestoreUid)
                .snapshots(),
            builder: (context, caseSnapshot) {
              if (caseSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: AppColors.gold));
              }

              final docs = caseSnapshot.data?.docs ?? [];
              final cases = docs.map((d) => CaseFile.fromFirestore(d)).toList();

              // Yaklaşan duruşmaları ayıkla (tarihi olanlar)
              final hearings = cases
                  .where((c) =>
                      c.nextHearingDate != null &&
                      c.nextHearingDate!.isNotEmpty)
                  .toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hoş Geldiniz,',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 16)),
                    Text(fullName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 30),

                    // ÜST DURUM KARTLARI
                    Row(
                      children: [
                        Expanded(
                            child: _buildStatCard('Dosya Sayısı',
                                cases.length.toString(), Icons.folder_shared)),
                        const SizedBox(width: 16),
                        Expanded(
                            child: _buildStatCard('Bekleyen Duruşma',
                                hearings.length.toString(), Icons.gavel)),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // YAKLAŞAN DURUŞMALAR (Varsa görünür)
                    if (hearings.isNotEmpty) ...[
                      const SectionHeader(title: 'Yaklaşan Duruşmalarınız'),
                      const SizedBox(height: 12),
                      ...hearings
                          .map((h) => LuxuryCard(
                                child: ListTile(
                                  leading: const Icon(Icons.event_available,
                                      color: AppColors.gold),
                                  title: Text(h.title,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                      'Tarih: ${h.nextHearingDate} - Saat: ${h.nextHearingTime ?? '--:--'}',
                                      style: const TextStyle(
                                          color: AppColors.textSecondary)),
                                ),
                              ))
                          ,
                      const SizedBox(height: 24),
                    ],

                    // SON SÜREÇLER (Tüm dosyalardaki son olaylar)
                    const SectionHeader(title: 'Son Süreçler'),
                    const SizedBox(height: 12),
                    if (cases.isEmpty)
                      const Text('Henüz bir dosyanız bulunmuyor.',
                          style: TextStyle(color: AppColors.textMuted))
                    else
                      _buildRecentEvents(
                          cases), // 🌟 Detaylı süreçleri listeleyen fonksiyon
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 🌟 TÜM DOSYALARDAKİ EN SON 3 OLAYI LİSTELEYEN FONKSİYON
  Widget _buildRecentEvents(List<CaseFile> cases) {
    List<Map<String, dynamic>> allEvents = [];

    // Tüm dosyalardaki timeline verilerini tek bir havuzda topla
    for (var c in cases) {
      for (var event in c.timeline) {
        allEvents.add({
          'caseTitle': c.title,
          'event': event,
        });
      }
    }

    // Tarihe göre sırala (en yeni en üstte)
    allEvents.sort((a, b) {
      return b['event']
          .date
          .split('/')
          .reversed
          .join()
          .compareTo(a['event'].date.split('/').reversed.join());
    });

    if (allEvents.isEmpty) {
      return const Text('Henüz kaydedilmiş bir süreç bulunmuyor.',
          style: TextStyle(color: AppColors.textMuted));
    }

    return Column(
      children: allEvents.take(3).map((item) {
        final CaseEvent event = item['event'];
        final String caseTitle = item['caseTitle'];

        return LuxuryCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(caseTitle.toUpperCase(),
                        style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                  Text(event.date,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 10),
              Text(event.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              if (event.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(event.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4)),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navyLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.gold, size: 28),
          const SizedBox(height: 12),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          Text(title,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
}
