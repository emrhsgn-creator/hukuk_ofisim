import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Klasör yolları silindi, artık direkt aynı klasörden (lib) çağırıyoruz.
import 'app_theme.dart';
import 'models.dart';
import 'firebase_service.dart';
import 'common_widgets.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Randevu Sistemi — Gün/saat seçimi ve talep oluşturma
/// ─────────────────────────────────────────────────────────────────────────────
class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final _firestoreService = FirestoreService();
  final _subjectController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;
  bool _isSubmitting = false;

  /// Uygun randevu saatleri.
  final List<String> _timeSlots = [
    '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
    '13:00', '13:30', '14:00', '14:30', '15:00', '15:30',
    '16:00', '16:30', '17:00',
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  /// Randevu talebini Firestore'a kaydeder.
  Future<void> _submitAppointment() async {
    if (_selectedTime == null) {
      _showSnackBar('Lütfen bir saat seçin.', isError: true);
      return;
    }
    if (_subjectController.text.trim().isEmpty) {
      _showSnackBar('Lütfen randevu konusunu yazın.', isError: true);
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    setState(() => _isSubmitting = true);

    try {
      await _firestoreService.createAppointment(
        Appointment(
          userId: userId,
          date: '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
          time: _selectedTime!,
          subject: _subjectController.text.trim(),
        ),
      );

      if (!mounted) return;
      _showSnackBar('Randevu talebiniz başarıyla oluşturuldu.');
      _subjectController.clear();
      setState(() {
        _selectedTime = null;
        _isSubmitting = false;
      });
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Bir hata oluştu. Lütfen tekrar deneyin.', isError: true);
      setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Randevu Al')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Bilgi Kartı ──
            _buildInfoCard(),
            const SizedBox(height: 24),

            // ── Tarih Seçimi ──
            const SectionHeader(title: 'Tarih Seçin'),
            _buildDateSelector(),
            const SizedBox(height: 24),

            // ── Saat Seçimi ──
            const SectionHeader(title: 'Saat Seçin'),
            _buildTimeGrid(),
            const SizedBox(height: 24),

            // ── Konu ──
            const SectionHeader(title: 'Randevu Konusu'),
            _buildSubjectField(),
            const SizedBox(height: 32),

            // ── Gönder Butonu ──
            GoldButton(
              label: 'RANDEVU TALEBİ OLUŞTUR',
              icon: Icons.send_rounded,
              isLoading: _isSubmitting,
              onPressed: _submitAppointment,
            ),
            const SizedBox(height: 24),

            // ── Geçmiş Randevular ──
            const SectionHeader(title: 'Randevularınız'),
            _buildAppointmentHistory(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// Üst bilgi kartı.
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.gold, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Randevu talebiniz avukatınız tarafından onaylandıktan sonra kesinleşir.',
              style: TextStyle(
                color: AppColors.goldLight,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Yatay kaydırılabilir tarih seçici.
  Widget _buildDateSelector() {
    final today = DateTime.now();
    // Sonraki 14 günü göster (hafta sonları hariç)
    final availableDays = <DateTime>[];
    var day = today.add(const Duration(days: 1));
    while (availableDays.length < 14) {
      if (day.weekday != DateTime.saturday && day.weekday != DateTime.sunday) {
        availableDays.add(day);
      }
      day = day.add(const Duration(days: 1));
    }

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: availableDays.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final date = availableDays[index];
          final isSelected = _selectedDate.year == date.year &&
              _selectedDate.month == date.month &&
              _selectedDate.day == date.day;

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              decoration: BoxDecoration(
                color: isSelected ? null : AppColors.card,
                gradient: isSelected ? AppColors.goldGradient : null,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? AppColors.gold : AppColors.navyMedium,
                  width: isSelected ? 0 : 0.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _dayName(date.weekday),
                    style: TextStyle(
                      color: isSelected ? AppColors.navy : AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      color: isSelected ? AppColors.navy : AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _monthName(date.month),
                    style: TextStyle(
                      color: isSelected ? AppColors.navy.withOpacity(0.7) : AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Saat seçim grid'i.
  Widget _buildTimeGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _timeSlots.map((time) {
        final isSelected = _selectedTime == time;
        // Öğle arası göstergesi
        final isLunchBreak = time == '13:00';

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLunchBreak)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.navyMedium)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'Öğleden Sonra',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.navyMedium)),
                  ],
                ),
              ),
            GestureDetector(
              onTap: () => setState(() => _selectedTime = time),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 72,
                height: 42,
                decoration: BoxDecoration(
                  color: isSelected ? null : AppColors.card,
                  gradient: isSelected ? AppColors.goldGradient : null,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.gold : AppColors.navyMedium,
                    width: isSelected ? 0 : 0.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    time,
                    style: TextStyle(
                      color: isSelected ? AppColors.navy : AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  /// Konu giriş alanı.
  Widget _buildSubjectField() {
    return TextFormField(
      controller: _subjectController,
      maxLines: 3,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: const InputDecoration(
        hintText: 'Randevunuzun konusunu kısaca açıklayın...',
        alignLabelWithHint: true,
      ),
    );
  }

  /// Geçmiş randevular listesi.
  Widget _buildAppointmentHistory() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return const SizedBox.shrink();

    return StreamBuilder<List<Appointment>>(
      stream: _firestoreService.getAppointments(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return LuxuryCard(
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.event_busy, size: 40, color: AppColors.textMuted.withOpacity(0.3)),
                  const SizedBox(height: 8),
                  const Text(
                    'Henüz randevu kaydınız bulunmuyor.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: snapshot.data!.map((apt) {
            return LuxuryCard(
              child: Row(
                children: [
                  // Saat bloğu
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.navyLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        apt.time,
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          apt.subject,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          apt.date,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: apt.status),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  String _dayName(int weekday) {
    const names = ['', 'Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return names[weekday];
  }

  String _monthName(int month) {
    const names = [
      '', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
    ];
    return names[month];
  }
}