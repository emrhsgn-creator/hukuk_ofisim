import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_theme.dart';
import 'firebase_service.dart';
import 'models.dart';
import 'common_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = AuthService();
  final _firestore = FirestoreService();
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      // Sistem e-posta merkezli olduğu için uid yerine e-posta ile okuyoruz.
      final profile = await _firestore.getUserProfileByEmail(user.email!);
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  /// TEK SEFERLİK veri bakımı: avukatı 'staff' koleksiyonuna ekler ve mevcut
  /// davalara 'clientEmail' alanını doldurur. Güvenlik kuralları DEPLOY
  /// EDİLMEDEN ÖNCE, giriş yapmış avukat tarafından bir kez çalıştırılmalıdır.
  Future<void> _runMaintenance() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navyLight,
        title: const Text('Veri Bakımı', style: TextStyle(color: AppColors.gold)),
        content: const Text(
          'Bu işlem (tek seferlik):\n\n'
          '• Hesabınızı yetkili avukat olarak kaydeder.\n'
          '• Mevcut davalara müvekkil e-postasını ekler.\n\n'
          'Hiçbir veri silinmez. Devam edilsin mi?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İPTAL', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ÇALIŞTIR', style: TextStyle(color: AppColors.navy)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: AppColors.gold)),
    );

    try {
      await _firestore.registerStaff(user!.email!);
      final result = await _firestore.backfillCaseClientEmails();
      if (!mounted) return;
      Navigator.pop(context); // yükleniyor kapat
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.navyLight,
          title: const Text('Bakım Tamamlandı',
              style: TextStyle(color: AppColors.success)),
          content: Text(result, style: const TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('TAMAM', style: TextStyle(color: AppColors.gold)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // yükleniyor kapat
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Bakım hatası: $e'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold))
          : SingleChildScrollView(
              // 🌟 DOĞRU PADDING KULLANIMI: Padding widget'ı ile sarmalıyoruz
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Profil Avatar Bölümü
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.gold, width: 2),
                        ),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.navyLight,
                          child: Icon(Icons.person,
                              size: 50, color: AppColors.gold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _profile?.fullName ?? "Değerli Kullanıcı",
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Playfair Display',
                      ),
                    ),
                    Text(
                      _profile?.role == 'lawyer'
                          ? "Yönetici Avukat"
                          : "Müvekkil",
                      style:
                          const TextStyle(color: AppColors.gold, fontSize: 14),
                    ),
                    const SizedBox(height: 32),

                    // Bilgi Kartları
                    _buildProfileItem(Icons.email_outlined, "E-posta",
                        _profile?.email ?? "-"),
                    _buildProfileItem(
                        Icons.phone_outlined, "Telefon", "Girilmedi"),
                    _buildProfileItem(
                        Icons.fingerprint, "T.C. Kimlik No", "Doğrulandı"),

                    const SizedBox(height: 40),

                    // 🔧 TEK SEFERLİK VERİ BAKIMI — yalnız avukatlara görünür.
                    // Güvenlik kuralları devreye alınmadan önce bir kez çalıştırılır.
                    if (_profile?.role == 'lawyer') ...[
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.gold,
                          side: const BorderSide(color: AppColors.gold),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: _runMaintenance,
                        icon: const Icon(Icons.build_circle_outlined),
                        label: const Text('Veri Bakımı (tek seferlik)'),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Çıkış Yap Butonu
                    GoldButton(
                      label: "GÜVENLİ ÇIKIŞ",
                      icon: Icons.logout,
                      onPressed: () async {
                        await _auth.signOut();
                        // Giriş ekranına yönlendirme main.dart içindeki AuthGate ile otomatik yapılacak
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navyLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.navyMedium),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: 22),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
