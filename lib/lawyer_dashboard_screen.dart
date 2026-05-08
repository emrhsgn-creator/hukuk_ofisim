import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_theme.dart';
import 'common_widgets.dart';
import 'models.dart';

class LawyerDashboardScreen extends StatelessWidget {
  const LawyerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: const Text('Hukuk Ofisi Özet',
            style: TextStyle(color: AppColors.gold)),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hoş Geldiniz',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ofisinizin güncel anlık durumu aşağıdadır.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 30),

            // 🌟 İSTATİSTİK KARTLARI (Artık Canlı Veri Çekiyor!)
            Row(
              children: [
                Expanded(
                  child: _buildDynamicCaseCount(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDynamicClientCount(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const SectionHeader(title: 'Sistemdeki Dosyalar'),
            const SizedBox(height: 12),

            // 🌟 DİNAMİK DAVA LİSTESİ (Son eklenen dosyaları listeler)
            _buildRecentCases(),
          ],
        ),
      ),
    );
  }

  // 🌟 CANLI DOSYA SAYACI
  Widget _buildDynamicCaseCount() {
    return StreamBuilder<QuerySnapshot>(
      // Firestore'daki 'cases' (davalar) koleksiyonunu anlık dinler
      stream: FirebaseFirestore.instance.collection('cases').snapshots(),
      builder: (context, snapshot) {
        String count = "0";
        if (snapshot.hasData) {
          count = snapshot.data!.docs.length.toString();
        }
        return _buildStatCard('Kayıtlı Dosya', count, Icons.folder_open);
      },
    );
  }

  // 🌟 CANLI MÜVEKKİL SAYACI
  Widget _buildDynamicClientCount() {
    return StreamBuilder<QuerySnapshot>(
      // Sadece rolü 'client' olan kullanıcıları anlık dinler
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'client')
          .snapshots(),
      builder: (context, snapshot) {
        String count = "0";
        if (snapshot.hasData) {
          count = snapshot.data!.docs.length.toString();
        }
        return _buildStatCard('Müvekkil', count, Icons.people);
      },
    );
  }

  // 🌟 CANLI LİSTE: Alt kısımdaki sabit dava kartını gerçeğiyle değiştirdik
  Widget _buildRecentCases() {
    return StreamBuilder<QuerySnapshot>(
      // Ekranda çok kalabalık olmasın diye sadece en üstteki 3-4 dosyayı çeker
      stream:
          FirebaseFirestore.instance.collection('cases').limit(4).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.gold));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('Henüz dosya bulunmuyor.',
                style: TextStyle(color: AppColors.textMuted)),
          );
        }

        final cases =
            snapshot.data!.docs.map((d) => CaseFile.fromFirestore(d)).toList();

        // Çekilen dosyaları sırayla LuxuryCard içinde gösterir
        return Column(
          children: cases
              .map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: LuxuryCard(
                      child: ListTile(
                        leading: const Icon(Icons.gavel, color: AppColors.gold),
                        title: Text(c.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        subtitle: Text('${c.court}\nEsas: ${c.caseNumber}',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 13)),
                      ),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }

  // 🌟 Kutu Tasarımı (Sabit kalır, içindeki sayı dinamik değişir)
  Widget _buildStatCard(String title, String count, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navyLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.gold, size: 30),
          const SizedBox(height: 12),
          Text(count,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
        ],
      ),
    );
  }
}
