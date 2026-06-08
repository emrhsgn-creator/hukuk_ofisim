import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_theme.dart';
import 'models.dart';
import 'firebase_service.dart';
import 'common_widgets.dart';

class LawyerClientsScreen extends StatefulWidget {
  const LawyerClientsScreen({super.key});

  @override
  State<LawyerClientsScreen> createState() => _LawyerClientsScreenState();
}

class _LawyerClientsScreenState extends State<LawyerClientsScreen> {
  final _firestoreService = FirestoreService();
  final bool _isUploading = false;

  // 🌟 MÜVEKKİL SİLME
  Future<void> _confirmDeleteClient(
      BuildContext context, UserProfile client) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.navyLight,
          title: const Text('Müvekkili Sil',
              style: TextStyle(color: AppColors.textPrimary)),
          content: Text(
              '"${client.fullName}" isimli müvekkili silmek istediğinize emin misiniz?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('İPTAL',
                    style: TextStyle(color: AppColors.textMuted))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('SİL',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _firestoreService.deleteUserProfile(client.uid);
    }
  }

  // 🌟 MÜVEKKİL DÜZENLEME (Anında güncelleme yapar)
  void _showEditClientDialog(BuildContext context, UserProfile client) {
    final nameController = TextEditingController(text: client.fullName);
    final emailController = TextEditingController(
        text: client.email == 'E-posta girilmedi' ? '' : client.email);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navyLight,
        title: const Text('Bilgileri Düzenle',
            style: TextStyle(color: AppColors.gold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Ad Soyad')),
            const SizedBox(height: 16),
            TextField(
                controller: emailController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'E-posta')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('İPTAL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(client.uid)
                  .update({
                'fullName': nameController.text.trim(),
                'email': emailController.text.trim().isEmpty
                    ? 'E-posta girilmedi'
                    : emailController.text.trim(),
              });
              if (mounted) Navigator.pop(ctx);
            },
            child:
                const Text('KAYDET', style: TextStyle(color: AppColors.ink)),
          )
        ],
      ),
    );
  }

  // 🌟 ŞİFRE OLUŞTURMA VE MENÜ (Donma ve Çökme Korumalı)
  void _showClientOptions(BuildContext context, UserProfile client) {
    // 🌟 ÇÖZÜM 2: Ana ekranın kimliğini (context) güvenli bir yere kaydediyoruz
    final parentContext = this.context;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navyLight,
      builder: (bottomSheetContext) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(client.fullName,
                  style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const Divider(color: AppColors.navyMedium, height: 30),
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.textPrimary),
                title: const Text('Bilgileri Düzenle',
                    style: TextStyle(color: AppColors.textPrimary)),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _showEditClientDialog(parentContext, client);
                },
              ),
              ListTile(
                leading: const Icon(Icons.vpn_key, color: AppColors.success),
                title: const Text('Uygulama Erişimi (Şifre) Oluştur',
                    style: TextStyle(color: AppColors.textPrimary)),
                onTap: () async {
                  // 1. Alt menüyü kapat
                  Navigator.pop(bottomSheetContext);

                  if (client.email == 'E-posta girilmedi' ||
                      client.email.trim().isEmpty) {
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Önce geçerli bir e-posta eklemelisiniz.'),
                            backgroundColor: AppColors.error));
                    return;
                  }

                  // 2. Yükleniyor Dairesini (Güvenli Context ile) Aç
                  showDialog(
                      context: parentContext,
                      barrierDismissible: false,
                      builder: (loadingContext) => const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.gold)));

                  try {
                    // Şifreyi Üret
                    String pass = await _firestoreService
                        .grantClientAccess(client.email.trim());

                    if (!mounted) return;

                    // 3. Başarılıysa yükleniyor dairesini kapat
                    Navigator.pop(parentContext);

                    // Sonucu göster
                    _showPasswordResult(client.fullName, client.email, pass);
                  } catch (e) {
                    if (!mounted) return;

                    // 4. Hata olduysa yine de yükleniyor dairesini kapat ve Kırmızı Hatayı bas!
                    Navigator.pop(parentContext);

                    ScaffoldMessenger.of(parentContext).showSnackBar(SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: AppColors.error,
                      duration: const Duration(seconds: 5),
                    ));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPasswordResult(String name, String email, String pass) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navyLight,
        title: const Text('Şifre Oluşturuldu!',
            style: TextStyle(color: AppColors.success)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('E-posta: $email',
                style: const TextStyle(color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Text('Şifre: $pass',
                style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('TAMAM'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
          title: const Text('Müvekkil Portföyü',
              style: TextStyle(color: AppColors.gold))),
      body: StreamBuilder<QuerySnapshot>(
        // 🌟 İŞTE CANLI YAYIN BURADA BAŞLIYOR!
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'client')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          final clients =
              docs.map((d) => UserProfile.fromFirestore(d)).toList();
          clients.sort((a, b) =>
              a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildImportCard(),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Kayıtlı Müvekkiller'),
              ...clients
                  .map((client) => LuxuryCard(
                        onTap: () => _showClientOptions(context, client),
                        child: ListTile(
                          leading:
                              const Icon(Icons.person, color: AppColors.gold),
                          title: Text(client.fullName,
                              style: const TextStyle(color: AppColors.textPrimary)),
                          subtitle: Text(client.email,
                              style: const TextStyle(
                                  color: AppColors.textSecondary)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: AppColors.error),
                            onPressed: () =>
                                _confirmDeleteClient(context, client),
                          ),
                        ),
                      ))
                  ,
            ],
          );
        },
      ),
    );
  }

  Widget _buildImportCard() {
    /* Önceki kodla aynı */ return InkWell(
        onTap: _isUploading ? null : _pickAndUploadCSV,
        child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: AppColors.navyLight,
                borderRadius: BorderRadius.circular(15)),
            child: Row(children: [
              Icon(Icons.upload_file, color: AppColors.gold),
              SizedBox(width: 15),
              Text('Toplu Yükle', style: TextStyle(color: AppColors.textPrimary))
            ])));
  }

  void _pickAndUploadCSV() {/* Önceki kodla aynı */}
}
