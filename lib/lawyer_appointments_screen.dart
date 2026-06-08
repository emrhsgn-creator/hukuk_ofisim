import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'models.dart';
import 'firebase_service.dart';

class LawyerAppointmentsScreen extends StatelessWidget {
  const LawyerAppointmentsScreen({super.key});

  // 🌟 SİLME İŞLEMİ VE GÜVENLİK KALKANI EKLENDİ
  Future<void> _confirmDeleteAppointment(
      BuildContext context, Appointment appo) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.navyLight,
          title:
              const Text('Talebi Sil',
                  style: TextStyle(color: AppColors.textPrimary)),
          content: Text(
            '"${appo.clientName}" kişisine ait "${appo.subject}" konulu randevu talebini kalıcı olarak silmek istediğinize emin misiniz?',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('İPTAL',
                  style: TextStyle(color: AppColors.textMuted)),
            ),
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

    // Eğer kullanıcı onaya bastıysa silme komutunu gönder
    if (confirm == true) {
      try {
        await FirestoreService().deleteAppointment(appo.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Randevu talebi başarıyla silindi.'),
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
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<Appointment>>(
        stream: FirestoreService().getAllAppointments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.gold));
          }

          final appointments = snapshot.data ?? [];

          // 🌟 GELİŞTİRME: Talepleri tarih sırasına göre veya en yeni en üstte olacak şekilde dizebiliriz.
          // Şimdilik Firebase'in geliş sırasına göre listeliyoruz.

          if (appointments.isEmpty) {
            return const Center(
              child: Text('Henüz bir randevu talebi bulunmuyor.',
                  style: TextStyle(color: AppColors.textMuted)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appo = appointments[index];
              return _buildLawyerAppointmentCard(context, appo);
            },
          );
        },
      ),
    );
  }

  Widget _buildLawyerAppointmentCard(BuildContext context, Appointment appo) {
    bool isPending = appo.status == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navyLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending
              ? AppColors.gold.withOpacity(0.5)
              : AppColors.navyMedium,
          width: isPending ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sol Kısım: İsim ve Etiket
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appo.clientName,
                      style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    _buildStatusBadge(appo.status),
                  ],
                ),
              ),
              // Sağ Kısım: SİL BUTONU 🌟
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                tooltip: 'Talebi Sil',
                onPressed: () => _confirmDeleteAppointment(context, appo),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(appo.subject,
              style:
                  const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_month,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text('${appo.date} - ${appo.time}',
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 13)),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateStatus(appo.id, 'rejected'),
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error)),
                    child: const Text('REDDET',
                        style: TextStyle(color: AppColors.error)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(appo.id, 'approved'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success),
                    child: const Text('ONAYLA',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    switch (status) {
      case 'approved':
        color = AppColors.success;
        text = "Onaylandı";
        break;
      case 'rejected':
        color = AppColors.error;
        text = "Reddedildi";
        break;
      default:
        color = Colors.orange;
        text = "Bekliyor";
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color)),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  void _updateStatus(String id, String newStatus) {
    FirestoreService().updateAppointmentStatus(id, newStatus);
  }
}
