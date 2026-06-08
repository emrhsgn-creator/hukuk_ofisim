import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_theme.dart';
import 'models.dart';
import 'common_widgets.dart';
import 'case_detail_screen.dart';
import 'add_case_screen.dart';
import 'firebase_service.dart'; // 🌟 Silme işlemi için servisimizi çağırdık

class LawyerCasesScreen extends StatelessWidget {
  const LawyerCasesScreen({super.key});

  // 🌟 ONAY PENCERESİ VE SİLME İŞLEMİ
  Future<void> _confirmDelete(BuildContext context, CaseFile caseFile) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.navyLight,
          title:
              const Text('Dosyayı Sil',
                  style: TextStyle(color: AppColors.textPrimary)),
          content: Text(
            '"${caseFile.title}" başlıklı dosyayı silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false), // İptal
              child: const Text('İPTAL',
                  style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => Navigator.of(dialogContext).pop(true), // Onayla
              child: const Text('SİL',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    // Eğer kullanıcı 'SİL' butonuna bastıysa işlemi başlat
    if (confirm == true) {
      try {
        await FirestoreService().deleteCaseFile(caseFile.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dava dosyası başarıyla silindi.'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Silme işlemi başarısız: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title:
            const Text('Tüm Dosyalar', style: TextStyle(color: AppColors.gold)),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cases').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.gold));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('Ofise ait dosya bulunamadı.',
                    style: TextStyle(color: AppColors.textMuted)));
          }

          final cases = snapshot.data!.docs
              .map((d) => CaseFile.fromFirestore(d))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: cases.length,
            itemBuilder: (context, index) {
              final c = cases[index];
              return Stack(
                // 🌟 Butonu sağ üste yerleştirmek için Stack kullandık
                children: [
                  LuxuryCard(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => CaseDetailScreen(caseFile: c)));
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                          right: 40.0), // 🌟 Sil butonuna yer açtık
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
                                          fontWeight: FontWeight.bold))),
                              StatusBadge(status: c.status),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(c.court,
                              style: const TextStyle(
                                  color: AppColors.textSecondary)),
                          Text("Esas No: ${c.caseNumber}",
                              style: const TextStyle(
                                  color: AppColors.textMuted, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),

                  // 🌟 İŞTE KIRMIZI ÇÖP KUTUSU (Kartın sağ üst köşesinde durur)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.error),
                      tooltip: 'Dosyayı Sil',
                      onPressed: () =>
                          _confirmDelete(context, c), // Tıklanınca onaya gönder
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddCaseScreen()));
        },
        backgroundColor: AppColors.gold,
        icon: const Icon(Icons.add, color: AppColors.ink),
        label: const Text('Yeni Dava Ekle',
            style:
                TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
