import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_theme.dart';
import 'models.dart';
import 'firebase_service.dart';
import 'common_widgets.dart';
import 'case_detail_screen.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Ana Sayfa (Dashboard) — Müvekkil karşılama, yaklaşan duruşma ve dosyalar
/// ─────────────────────────────────────────────────────────────────────────────
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _firestoreService = FirestoreService();
  final _currentUser = FirebaseAuth.instance.currentUser;

  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (_currentUser == null) return;
    final profile = await _firestoreService.getUserProfile(_currentUser!.uid);
    if (mounted) setState(() => _profile = profile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hoşgeldiniz Başlığı ──
          SliverToBoxAdapter(child: _buildWelcomeHeader()),

          // ── Yaklaşan Duruşma Kartı ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SectionHeader(title: 'Yaklaşan Duruşma'),
                  _buildNextHearingCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Aktif Dosyalar Listesi ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const SectionHeader(title: 'Aktif Dosyalarınız'),
            ),
          ),
          _buildCaseFilesList(),

          // Alt boşluk
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  /// Karşılama bölümü — kullanıcı adı ve tarih gösterir.
  Widget _buildWelcomeHeader() {
    final greeting = _getGreeting();
    final displayName = _profile?.fullName ?? _currentUser?.email ?? 'Değerli Müvekkil';

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.navyLight,
            AppColors.navy.withOpacity(0.3),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst satır: Selamlama ve bildirim
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              // Bildirim ikonu
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.navyMedium),
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(Icons.notifications_outlined, color: AppColors.textSecondary, size: 22),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Hızlı özet satırı
          Row(
            children: [
              _buildQuickStat(Icons.folder_outlined, '3', 'Aktif Dosya'),
              const SizedBox(width: 12),
              _buildQuickStat(Icons.event_outlined, '1', 'Yaklaşan'),
              const SizedBox(width: 12),
              _buildQuickStat(Icons.check_circle_outline, '5', 'Tamamlanan'),
            ],
          ),
        ],
      ),
    );
  }

  /// Hızlı istatistik kutusu.
  Widget _buildQuickStat(IconData icon, String count, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.navyMedium.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.gold, size: 20),
            const SizedBox(height: 8),
            Text(
              count,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Yaklaşan duruşma kartı — altın vurgulu.
  Widget _buildNextHearingCard() {
    return LuxuryCard(
      showGoldAccent: true,
      child: Row(
        children: [
          // Tarih bloğu
          Container(
            width: 60,
            height: 68,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '15',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Oca',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Duruşma detayları
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'İş Hukuku Davası',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'İstanbul 5. İş Mahkemesi',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: AppColors.gold),
                    const SizedBox(width: 4),
                    Text(
                      '10:30',
                      style: TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Dosya No: 2024/1234',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }

  /// Firestore'dan gelen dava dosyalarını listeler.
  Widget _buildCaseFilesList() {
    if (_currentUser == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return StreamBuilder<List<CaseFile>>(
      stream: _firestoreService.getCaseFiles(_currentUser!.uid),
      builder: (context, snapshot) {
        // Henüz veri yokken demo kartlar göster
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildDemoCaseCard(
                    title: 'İş Hukuku Davası',
                    caseNo: '2024/1234',
                    court: 'İstanbul 5. İş Mahkemesi',
                    status: 'active',
                    lawyer: 'Av. Selin Bayraktar',
                  ),
                  _buildDemoCaseCard(
                    title: 'Kira Uyuşmazlığı',
                    caseNo: '2024/5678',
                    court: 'İstanbul 3. Sulh Hukuk',
                    status: 'pending',
                    lawyer: 'Av. Selin Bayraktar',
                  ),
                  _buildDemoCaseCard(
                    title: 'Tüketici Hakları',
                    caseNo: '2023/9012',
                    court: 'İstanbul Tüketici Mahkemesi',
                    status: 'closed',
                    lawyer: 'Av. Kemal Yılmaz',
                  ),
                ],
              ),
            ),
          );
        }

        final cases = snapshot.data!;
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.builder(
            itemCount: cases.length,
            itemBuilder: (context, index) {
              final c = cases[index];
              return _buildCaseCard(c);
            },
          ),
        );
      },
    );
  }

  /// Tek bir dava dosyası kartı.
  Widget _buildCaseCard(CaseFile caseFile) {
    return LuxuryCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CaseDetailScreen(caseFile: caseFile),
          ),
        );
      },
      child: _caseCardContent(
        title: caseFile.title,
        caseNo: caseFile.caseNumber,
        court: caseFile.court,
        status: caseFile.status,
        lawyer: caseFile.lawyerName,
      ),
    );
  }

  /// Demo dava dosyası kartı (Firestore verisi olmadığında).
  Widget _buildDemoCaseCard({
    required String title,
    required String caseNo,
    required String court,
    required String status,
    String? lawyer,
  }) {
    // Demo veriler ile CaseFile oluştur
    final demoCase = CaseFile(
      id: 'demo_${caseNo.replaceAll('/', '_')}',
      title: title,
      caseNumber: caseNo,
      court: court,
      status: status,
      lawyerName: lawyer,
      timeline: _generateDemoTimeline(),
    );

    return LuxuryCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CaseDetailScreen(caseFile: demoCase),
          ),
        );
      },
      child: _caseCardContent(
        title: title,
        caseNo: caseNo,
        court: court,
        status: status,
        lawyer: lawyer,
      ),
    );
  }

  /// Kart iç düzeni (ortak kullanım).
  Widget _caseCardContent({
    required String title,
    required String caseNo,
    required String court,
    required String status,
    String? lawyer,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            StatusBadge(status: status),
          ],
        ),
        const SizedBox(height: 10),
        _infoRow(Icons.tag, 'Dosya No: $caseNo'),
        const SizedBox(height: 4),
        _infoRow(Icons.account_balance, court),
        if (lawyer != null) ...[
          const SizedBox(height: 4),
          _infoRow(Icons.person_outline, lawyer),
        ],
      ],
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      ],
    );
  }

  /// Demo timeline verisi.
  List<CaseEvent> _generateDemoTimeline() {
    return [
      CaseEvent(date: '2024-12-20', title: 'Dava Açıldı', description: 'Dava dilekçesi mahkemeye sunuldu.', type: 'document'),
      CaseEvent(date: '2024-12-28', title: 'Tensip Zaptı', description: 'Mahkeme tensip zaptı düzenledi.', type: 'decision'),
      CaseEvent(date: '2025-01-10', title: 'Cevap Dilekçesi', description: 'Davalı taraf cevap dilekçesini sundu.', type: 'document'),
      CaseEvent(date: '2025-01-15', title: 'İlk Duruşma', description: 'Tanık dinleme ve delil incelemesi yapılacak.', type: 'hearing'),
    ];
  }

  /// Saat dilimine göre selamlama.
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Günaydın,';
    if (hour < 18) return 'İyi günler,';
    return 'İyi akşamlar,';
  }
}