import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'models.dart';
import 'common_widgets.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Dosya Detay Sayfası — Dikey Timeline (Zaman Çizelgesi) ile süreç takibi
/// ─────────────────────────────────────────────────────────────────────────────
class CaseDetailScreen extends StatelessWidget {
  final CaseFile caseFile;

  const CaseDetailScreen({super.key, required this.caseFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dosya Detayı'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Dosya Özet Kartı ──
            _buildSummaryCard(context),
            const SizedBox(height: 28),

            // ── Zaman Çizelgesi Başlığı ──
            const SectionHeader(title: 'Süreç Takibi'),
            const SizedBox(height: 8),

            // ── Timeline ──
            _buildTimeline(context),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// Dosyanın özet bilgilerini gösteren üst kart.
  Widget _buildSummaryCard(BuildContext context) {
    return LuxuryCard(
      showGoldAccent: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık ve durum
          Row(
            children: [
              Expanded(
                child: Text(
                  caseFile.title,
                  style: const TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              StatusBadge(status: caseFile.status),
            ],
          ),
          const SizedBox(height: 16),

          // Detay satırları
          Divider(color: AppColors.navyMedium.withOpacity(0.5)),
          const SizedBox(height: 12),
          _detailRow(Icons.tag, 'Dosya No', caseFile.caseNumber),
          _detailRow(Icons.account_balance, 'Mahkeme', caseFile.court),
          if (caseFile.lawyerName != null)
            _detailRow(Icons.person_outline, 'Avukat', caseFile.lawyerName!),
          if (caseFile.nextHearingDate != null)
            _detailRow(
              Icons.event,
              'Sonraki Duruşma',
              '${caseFile.nextHearingDate} ${caseFile.nextHearingTime ?? ''}',
            ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.gold),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dikey zaman çizelgesi — her olay bir düğüm ve bağlantı çizgisi ile gösterilir.
  Widget _buildTimeline(BuildContext context) {
    final events = caseFile.timeline;

    if (events.isEmpty) {
      return LuxuryCard(
        child: Center(
          child: Column(
            children: [
              Icon(Icons.timeline, size: 48, color: AppColors.textMuted.withOpacity(0.3)),
              const SizedBox(height: 12),
              const Text(
                'Henüz kayıtlı süreç bulunmuyor.',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: List.generate(events.length, (index) {
        final event = events[index];
        final isLast = index == events.length - 1;
        final isFirst = index == 0;
        return _buildTimelineItem(event, isFirst: isFirst, isLast: isLast);
      }),
    );
  }

  /// Tek bir timeline öğesi.
  Widget _buildTimelineItem(
    CaseEvent event, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    final config = _eventTypeConfig(event.type);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Sol taraf: Çizgi ve düğüm ──
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Üst çizgi (ilk öğe hariç)
                Container(
                  width: 2,
                  height: 16,
                  color: isFirst ? Colors.transparent : AppColors.navyMedium,
                ),
                // Düğüm noktası
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isLast ? config.color : config.color.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: config.color, width: 2),
                    boxShadow: isLast
                        ? [
                            BoxShadow(
                              color: config.color.withOpacity(0.4),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                ),
                // Alt çizgi (son öğe hariç)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : AppColors.navyMedium,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ── Sağ taraf: Olay kartı ──
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isLast
                      ? config.color.withOpacity(0.3)
                      : AppColors.navyMedium.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tarih ve tür etiketi
                  Row(
                    children: [
                      Icon(config.icon, size: 14, color: config.color),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(event.date),
                        style: TextStyle(
                          color: config.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: config.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          config.label,
                          style: TextStyle(
                            color: config.color,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Olay başlığı
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Açıklama
                  Text(
                    event.description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Olay türüne göre renk ve ikon ayarları.
  ({Color color, IconData icon, String label}) _eventTypeConfig(String type) {
    switch (type) {
      case 'hearing':
        return (color: AppColors.gold, icon: Icons.gavel, label: 'Duruşma');
      case 'document':
        return (color: AppColors.info, icon: Icons.description, label: 'Belge');
      case 'decision':
        return (color: AppColors.success, icon: Icons.check_circle, label: 'Karar');
      default:
        return (color: AppColors.textSecondary, icon: Icons.note, label: 'Not');
    }
  }

  /// Tarih formatını düzenler (2025-01-15 → 15 Ocak 2025).
  String _formatDate(String date) {
    try {
      final parts = date.split('-');
      if (parts.length != 3) return date;
      final months = [
        '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
        'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
      ];
      return '${parts[2]} ${months[int.parse(parts[1])]} ${parts[0]}';
    } catch (_) {
      return date;
    }
  }
}
