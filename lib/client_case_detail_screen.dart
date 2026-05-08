import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'models.dart';

class ClientCaseDetailScreen extends StatelessWidget {
  final CaseFile caseFile;

  const ClientCaseDetailScreen({super.key, required this.caseFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title:
            const Text('Dosya Detayı', style: TextStyle(color: AppColors.gold)),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      body: Column(
        children: [
          // ── ÜST KISIM: DAVA ÖZETİ ──
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.navyLight,
              border: Border(
                  bottom: BorderSide(color: AppColors.gold.withOpacity(0.3))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  caseFile.title,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Playfair Display',
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.account_balance, caseFile.court),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.numbers, 'Esas No: ${caseFile.caseNumber}'),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.gavel,
                    'Sorumlu Avukat: ${caseFile.lawyerName ?? "Av. Emrah SIĞIN"}'),
              ],
            ),
          ),

          // ── ALT KISIM: SÜREÇ TAKİBİ (ZAMAN ÇİZELGESİ) ──
          Expanded(
            child: caseFile.timeline.isEmpty
                ? const Center(
                    child: Text(
                      'Henüz kaydedilmiş bir süreç bulunmamaktadır.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: caseFile.timeline.length,
                    itemBuilder: (context, index) {
                      // Ters kronolojik sıra: En yeni olay en üstte
                      final event = caseFile.timeline.reversed.toList()[index];
                      return _buildClientTimelineItem(event);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
            child: Text(text,
                style: const TextStyle(color: AppColors.textPrimary))),
      ],
    );
  }

  Widget _buildClientTimelineItem(CaseEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navyLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.navyMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                event.title,
                style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              Text(
                event.date,
                style:
                    const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
          if (event.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              event.description,
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }
}
