import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_theme.dart';
import 'models.dart';
import 'firebase_service.dart';
import 'common_widgets.dart';
import 'client_case_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _firestoreService = FirestoreService();
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final profile = await _firestoreService.getUserProfile(user.uid);
    if (mounted) setState(() => _profile = profile);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: user == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold))
          : CustomScrollView(
              slivers: [
                // ── 1. ÜST KISIM: HOŞGELDİNİZ VE CANLI İSTATİSTİKLER ──
                SliverToBoxAdapter(child: _buildWelcomeHeader(user)),

                // ── 2. KRİTİK BÖLÜM: YAKLAŞAN DURUŞMA BİLDİRİMİ ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SectionHeader(title: 'Yaklaşan Duruşma'),
                        _buildLiveHearingCard(user.uid),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // ── 3. LİSTE: AKTİF DOSYALAR ──
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: SectionHeader(title: 'Aktif Dosyalarınız'),
                  ),
                ),
                _buildCaseFilesList(user.uid),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
    );
  }

  // ── CANLI İSTATİSTİKLERİ İÇEREN KARŞILAMA BÖLÜMÜ ──
  Widget _buildWelcomeHeader(User user) {
    final greeting = _getGreeting();
    final displayName = _profile?.fullName ?? user.email ?? 'Değerli Müvekkil';

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(greeting,
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      displayName,
                      style: const TextStyle(
                          fontFamily: 'Playfair Display',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _buildNotificationBell(),
            ],
          ),
          const SizedBox(height: 20),

          // DİNAMİK İSTATİSTİK KUTULARI
          Row(
            children: [
              // Aktif Dosya Sayacı
              StreamBuilder<List<CaseFile>>(
                stream: _firestoreService.getCaseFilesForClient(user.uid),
                builder: (context, snapshot) {
                  final count = snapshot.data?.length ?? 0;
                  return _buildQuickStat(
                      Icons.folder_outlined, count.toString(), 'Aktif Dosya');
                },
              ),
              const SizedBox(width: 12),
              // Planlı Randevu Sayacı
              StreamBuilder<List<Appointment>>(
                stream: _firestoreService.getClientActiveAppointments(user.uid),
                builder: (context, snapshot) {
                  final count = snapshot.data?.length ?? 0;
                  return _buildQuickStat(
                      Icons.event_note, count.toString(), 'Onaylı Randevu');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🌟 GÜNCEL VE HATASIZ İSTATİSTİK KUTUSU WIDGET'I
  Widget _buildQuickStat(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: AppColors.navyLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.navyMedium)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.1),
                  shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.gold, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                Text(label,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── DURUŞMA BİLDİRİM KARTI ──
  Widget _buildLiveHearingCard(String uid) {
    return StreamBuilder<CaseFile?>(
      stream: _firestoreService.getUpcomingHearing(uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text('Veri çekilemedi: ${snapshot.error}',
                  style: const TextStyle(color: AppColors.error)));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: LinearProgressIndicator(
                  color: AppColors.gold, backgroundColor: AppColors.navyLight));
        }

        final nextCase = snapshot.data;

        if (nextCase == null ||
            nextCase.nextHearingDate == null ||
            nextCase.nextHearingDate!.isEmpty) {
          return const LuxuryCard(
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.textMuted, size: 20),
                SizedBox(width: 12),
                Text("Yakın tarihte duruşmanız bulunmamaktadır.",
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ],
            ),
          );
        }

        // Güvenli Tarih Parçalama
        String dayNumber = "00";
        if (nextCase.nextHearingDate!.contains('/')) {
          dayNumber = nextCase.nextHearingDate!.split('/').first;
        } else if (nextCase.nextHearingDate!.contains('.')) {
          dayNumber = nextCase.nextHearingDate!.split('.').first;
        } else {
          // Format farklıysa ilk 2 karakteri almayı dene
          dayNumber = nextCase.nextHearingDate!.length >= 2
              ? nextCase.nextHearingDate!.substring(0, 2)
              : nextCase.nextHearingDate!;
        }

        return LuxuryCard(
          showGoldAccent: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ClientCaseDetailScreen(caseFile: nextCase)),
            );
          },
          child: Row(
            children: [
              Container(
                width: 55,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.gavel, color: AppColors.navy, size: 18),
                    Text(
                      dayNumber,
                      style: const TextStyle(
                          color: AppColors.navy,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nextCase.title,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(nextCase.court,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 14, color: AppColors.gold),
                        const SizedBox(width: 4),
                        Text(nextCase.nextHearingTime ?? "Belirsiz",
                            style: const TextStyle(
                                color: AppColors.gold,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                        const SizedBox(width: 12),
                        const Icon(Icons.calendar_today,
                            size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(nextCase.nextHearingDate!,
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 14, color: AppColors.textMuted),
            ],
          ),
        );
      },
    );
  }

  // ── DOSYALAR LİSTESİ ──
  Widget _buildCaseFilesList(String uid) {
    return StreamBuilder<List<CaseFile>>(
      stream: _firestoreService.getCaseFilesForClient(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        final cases = snapshot.data!;
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildCaseCard(cases[index]),
              childCount: cases.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCaseCard(CaseFile caseFile) {
    return LuxuryCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ClientCaseDetailScreen(caseFile: caseFile)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(caseFile.title,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold))),
              StatusBadge(status: caseFile.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(caseFile.court,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 4),
          Text('Esas No: ${caseFile.caseNumber}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildNotificationBell() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
          color: AppColors.navyLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.navyMedium)),
      child: const Icon(Icons.notifications_outlined,
          color: AppColors.textSecondary, size: 22),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Günaydın,';
    if (hour < 18) return 'İyi günler,';
    return 'İyi akşamlar,';
  }
}
