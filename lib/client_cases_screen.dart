import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_theme.dart';
import 'models.dart';
import 'common_widgets.dart';

class ClientCasesScreen extends StatelessWidget {
  const ClientCasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null || currentUser.email == null) {
      return const Scaffold(
        backgroundColor: AppColors.navy,
        body: Center(child: Text('Oturum hatası.', style: TextStyle(color: AppColors.error))),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: const Text('Dosyalarım', style: TextStyle(color: AppColors.gold)),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        // 🔐 Davaları müvekkilin e-postası ile sorguluyoruz. Güvenlik kuralları
        // ancak sorgu, kuralın denetlediği alanla (clientEmail) eşleştiğinde
        // izin verir; bu yüzden clientId yerine clientEmail kullanıyoruz.
        stream: FirebaseFirestore.instance
            .collection('cases')
            .where('clientEmail', isEqualTo: currentUser.email)
            .snapshots(),
        builder: (context, caseSnapshot) {
          if (caseSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold));
          }

          if (!caseSnapshot.hasData || caseSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Henüz adınıza kayıtlı dosya bulunmuyor.',
                  style: TextStyle(color: AppColors.textMuted)),
            );
          }

          // Verileri CaseFile modeline dönüştür
          final cases = caseSnapshot.data!.docs.map((d) => CaseFile.fromFirestore(d)).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: cases.length,
            itemBuilder: (context, index) {
              final c = cases[index];
              return LuxuryCard(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Dosya detayları yakında eklenecektir.'),
                    backgroundColor: AppColors.gold,
                  ));
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(c.title,
                              style: const TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ),
                        StatusBadge(status: c.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(c.court, style: const TextStyle(color: AppColors.textSecondary)),
                    Text("Esas No: ${c.caseNumber}", style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}