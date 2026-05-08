import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_theme.dart';
import 'models.dart';
import 'firebase_service.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final _subjectController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  bool _isSending = false;

  // Randevu Talep Formu (Bottom Sheet olarak açılacak)
  void _showRequestSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.navyLight,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20, left: 20, right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Yeni Randevu Talebi', style: TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: _subjectController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Görüşme Konusu', hintText: 'Örn: Dosya gidişatı hakkında...'),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.calendar_today, color: AppColors.gold),
                title: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', style: const TextStyle(color: AppColors.textPrimary)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (picked != null) setModalState(() => _selectedDate = picked);
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time, color: AppColors.gold),
                title: Text(_selectedTime.format(context), style: const TextStyle(color: AppColors.textPrimary)),
                onTap: () async {
                  final picked = await showTimePicker(context: context, initialTime: _selectedTime);
                  if (picked != null) setModalState(() => _selectedTime = picked);
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, minimumSize: const Size(double.infinity, 50)),
                onPressed: _isSending ? null : () => _sendRequest(),
                child: _isSending 
                  ? const CircularProgressIndicator(color: AppColors.navy)
                  : const Text('TALEBİ GÖNDER', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendRequest() async {
    if (_subjectController.text.trim().isEmpty) return;
    
    setState(() => _isSending = true);
    final user = FirebaseAuth.instance.currentUser;
    
    // Kullanıcı adını profilden çekelim (Basitlik için şimdilik auth ismini alıyoruz)
    final appointment = Appointment(
      id: '',
      clientId: user!.uid,
      clientName: user.displayName ?? "Müvekkil", 
      date: "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
      time: _selectedTime.format(context),
      subject: _subjectController.text.trim(),
    );

    await FirestoreService().createAppointment(appointment);
    
    if (!mounted) return;
    Navigator.pop(context);
    _subjectController.clear();
    setState(() => _isSending = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Talebiniz avukatınıza iletildi.'), backgroundColor: AppColors.success));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<Appointment>>(
        stream: FirestoreService().getClientAppointments(user!.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.gold));
          final appointments = snapshot.data!;

          return appointments.isEmpty 
            ? const Center(child: Text('Henüz bir randevu talebiniz yok.', style: TextStyle(color: AppColors.textMuted)))
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appo = appointments[index];
                  return _buildAppointmentCard(appo);
                },
              );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showRequestSheet,
        backgroundColor: AppColors.gold,
        icon: const Icon(Icons.add, color: AppColors.navy),
        label: const Text('Randevu Talep Et', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appo) {
    Color statusColor = Colors.orange;
    String statusText = "Bekliyor";
    if (appo.status == 'approved') { statusColor = AppColors.success; statusText = "Onaylandı"; }
    else if (appo.status == 'rejected') { statusColor = AppColors.error; statusText = "Reddedildi"; }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.navyLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.navyMedium)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appo.subject, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${appo.date} - ${appo.time}', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: statusColor)),
            child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}