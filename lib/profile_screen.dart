import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_theme.dart';
import 'models.dart';
import 'firebase_service.dart';
import 'common_widgets.dart';
import 'login_screen.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Profil ve İletişim Sayfası — Kullanıcı bilgileri, ofis bilgisi, çıkış
/// ─────────────────────────────────────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final profile = await _firestoreService.getUserProfile(user.uid);
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    }
  }

  /// Güvenli çıkış — onay dialog'u gösterir.
  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navyLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Çıkış Yap',
          style: TextStyle(
            color: AppColors.gold,
            fontFamily: 'Playfair Display',
          ),
        ),
        content: const Text(
          'Oturumunuzu kapatmak istediğinize emin misiniz?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Çıkış Yap', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ── Kullanıcı Profil Kartı ──
                  _buildProfileHeader(user),
                  const SizedBox(height: 24),

                  // ── Kişisel Bilgiler ──
                  const SectionHeader(title: 'Kişisel Bilgiler'),
                  _buildPersonalInfo(user),
                  const SizedBox(height: 24),

                  // ── Ofis İletişim ──
                  const SectionHeader(title: 'Ofis İletişim Bilgileri'),
                  _buildOfficeInfo(),
                  const SizedBox(height: 24),

                  // ── Çalışma Saatleri ──
                  const SectionHeader(title: 'Çalışma Saatleri'),
                  _buildWorkingHours(),
                  const SizedBox(height: 24),

                  // ── Hakkında ──
                  _buildAboutCard(),
                  const SizedBox(height: 32),

                  // ── Çıkış Butonu ──
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _handleSignOut,
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('GÜVENLİ ÇIKIŞ'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error, width: 0.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Versiyon
                  Text(
                    'SB Legal v1.0.0',
                    style: TextStyle(
                      color: AppColors.textMuted.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  /// Profil başlığı — avatar, isim ve e-posta.
  Widget _buildProfileHeader(User? user) {
    final name = _profile?.fullName ?? user?.email?.split('@').first ?? 'Kullanıcı';
    final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

    return LuxuryCard(
      showGoldAccent: true,
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.goldGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.25),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Müvekkil',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Kişisel bilgiler listesi.
  Widget _buildPersonalInfo(User? user) {
    return LuxuryCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          _infoTile(Icons.person_outline, 'Ad Soyad', _profile?.fullName ?? '-'),
          _divider(),
          _infoTile(Icons.mail_outline, 'E-posta', user?.email ?? '-'),
          _divider(),
          _infoTile(Icons.phone_outlined, 'Telefon', _profile?.phone ?? '-'),
          _divider(),
          _infoTile(Icons.badge_outlined, 'T.C. Kimlik', _profile?.tcNo ?? '***********'),
        ],
      ),
    );
  }

  /// Ofis iletişim bilgileri kartı.
  Widget _buildOfficeInfo() {
    return LuxuryCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          _infoTile(Icons.location_on_outlined, 'Adres',
              'Levent Mah. Büyükdere Cad.\nNo:123 Kat:5, Beşiktaş/İstanbul'),
          _divider(),
          _infoTile(Icons.phone, 'Telefon', '+90 (212) 555 00 00'),
          _divider(),
          _infoTile(Icons.mail, 'E-posta', 'info@sblegal.com.tr'),
          _divider(),
          _infoTile(Icons.language, 'Web', 'www.sblegal.com.tr'),
        ],
      ),
    );
  }

  /// Çalışma saatleri kartı.
  Widget _buildWorkingHours() {
    return LuxuryCard(
      child: Column(
        children: [
          _hourRow('Pazartesi - Cuma', '09:00 - 18:00'),
          const SizedBox(height: 8),
          _hourRow('Cumartesi', '10:00 - 14:00'),
          const SizedBox(height: 8),
          _hourRow('Pazar', 'Kapalı', isClosed: true),
        ],
      ),
    );
  }

  Widget _hourRow(String day, String hours, {bool isClosed = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(day, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        Text(
          hours,
          style: TextStyle(
            color: isClosed ? AppColors.error : AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Hakkında kartı.
  Widget _buildAboutCard() {
    return LuxuryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, color: AppColors.gold, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Güvenlik ve Gizlilik',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Tüm kişisel verileriniz SSL şifreleme ile korunmaktadır. '
            'Avukat-müvekkil gizliliği kapsamında hiçbir bilginiz üçüncü kişilerle paylaşılmaz.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.gold),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      indent: 52,
      color: AppColors.navyMedium.withOpacity(0.3),
    );
  }
}
