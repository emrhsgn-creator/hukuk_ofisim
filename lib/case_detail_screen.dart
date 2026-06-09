import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_theme.dart';
import 'models.dart';
import 'common_widgets.dart';
import 'firebase_service.dart';

class CaseDetailScreen extends StatefulWidget {
  final CaseFile caseFile;
  const CaseDetailScreen({super.key, required this.caseFile});

  @override
  State<CaseDetailScreen> createState() => _CaseDetailScreenState();
}

class _CaseDetailScreenState extends State<CaseDetailScreen> {
  late CaseFile _currentCase;

  // 🌟 Yeni eklediğimiz dosya durumları
  final List<String> _statusOptions = [
    'Derdest',
    'Karara Çıkmış',
    'İstinafta',
    'Yargıtayda',
    'İnfazda',
    'Arabuluculukta',
    'Kapalı'
  ];

  @override
  void initState() {
    super.initState();
    _currentCase = widget.caseFile;
  }

  // 🌟 DOSYA DURUMUNU GÜNCELLEME PENCERESİ VE FONKSİYONU
  void _showStatusUpdateDialog() {
    String tempSelectedStatus = _currentCase.status;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: AppColors.navyLight,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              'Dosya Durumunu Güncelle',
              style: TextStyle(
                  color: AppColors.gold, fontFamily: 'Playfair Display'),
            ),
            content: DropdownButtonFormField<String>(
              initialValue: _statusOptions.contains(tempSelectedStatus)
                  ? tempSelectedStatus
                  : 'Derdest',
              dropdownColor: AppColors.navyLight,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.navy,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
              items: _statusOptions.map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                setModalState(() {
                  tempSelectedStatus = value!;
                });
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('İPTAL',
                    style: TextStyle(color: AppColors.textMuted)),
              ),
              ElevatedButton(
                style:
                    ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
                onPressed: () async {
                  // Firebase'de güncelle
                  await FirebaseFirestore.instance
                      .collection('cases')
                      .doc(_currentCase.id)
                      .update({'status': tempSelectedStatus});

                  // Ekranda anında güncelle
                  if (mounted) {
                    setState(() {
                      _currentCase = CaseFile(
                        id: _currentCase.id,
                        clientId: _currentCase.clientId,
                        title: _currentCase.title,
                        caseNumber: _currentCase.caseNumber,
                        court: _currentCase.court,
                        status: tempSelectedStatus, // 🌟 Yeni durum atandı
                        timeline: _currentCase.timeline,
                        nextHearingDate: _currentCase.nextHearingDate,
                        nextHearingTime: _currentCase.nextHearingTime,
                        opposingParty: _currentCase.opposingParty,
                      );
                    });
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Dosya durumu başarıyla güncellendi!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                child: const Text('GÜNCELLE',
                    style: TextStyle(
                        color: AppColors.ink, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEventDialog({CaseEvent? existingEvent, int? index}) {
    final titleController =
        TextEditingController(text: existingEvent?.title ?? '');
    final descController =
        TextEditingController(text: existingEvent?.description ?? '');

    String selectedType = existingEvent?.type ?? 'note';
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = const TimeOfDay(hour: 09, minute: 00);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (stateContext, setModalState) {
          return AlertDialog(
            backgroundColor: AppColors.navyLight,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              existingEvent == null ? 'Yeni Süreç Ekle' : 'Süreci Düzenle',
              style: const TextStyle(
                  color: AppColors.gold, fontFamily: 'Playfair Display'),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    dropdownColor: AppColors.navyLight,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                        labelText: 'Süreç Türü',
                        labelStyle: TextStyle(color: AppColors.gold)),
                    items: [
                      DropdownMenuItem(
                          value: 'note',
                          child: Row(children: const [
                            Icon(Icons.edit_note,
                                color: AppColors.textPrimary, size: 18),
                            SizedBox(width: 8),
                            Text('Bilgi Notu')
                          ])),
                      DropdownMenuItem(
                          value: 'hearing',
                          child: Row(children: const [
                            Icon(Icons.gavel, color: AppColors.gold, size: 18),
                            SizedBox(width: 8),
                            Text('Duruşma Günü',
                                style: TextStyle(
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.bold))
                          ])),
                      DropdownMenuItem(
                          value: 'document',
                          child: Row(children: const [
                            Icon(Icons.folder_open,
                                color: AppColors.textPrimary, size: 18),
                            SizedBox(width: 8),
                            Text('Evrak Girişi')
                          ])),
                    ],
                    onChanged: (val) =>
                        setModalState(() => selectedType = val!),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading:
                        const Icon(Icons.calendar_today, color: AppColors.gold),
                    title: Text(
                        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                        style: const TextStyle(color: AppColors.textPrimary)),
                    onTap: () async {
                      final picked = await showDatePicker(
                          context: stateContext,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030));
                      if (picked != null) {
                        setModalState(() => selectedDate = picked);
                      }
                    },
                  ),
                  if (selectedType == 'hearing')
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading:
                          const Icon(Icons.access_time, color: AppColors.gold),
                      title: Text(selectedTime.format(stateContext),
                          style: const TextStyle(color: AppColors.textPrimary)),
                      onTap: () async {
                        final picked = await showTimePicker(
                            context: stateContext, initialTime: selectedTime);
                        if (picked != null) {
                          setModalState(() => selectedTime = picked);
                        }
                      },
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                        labelText: 'Başlık',
                        prefixIcon:
                            Icon(Icons.edit_note, color: AppColors.gold)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                        labelText: 'Açıklama',
                        prefixIcon:
                            Icon(Icons.description, color: AppColors.gold)),
                  ),
                ],
              ),
            ),
            actions: [
              if (existingEvent != null)
                TextButton(
                  onPressed: () async {
                    final updatedTimeline =
                        List<CaseEvent>.from(_currentCase.timeline);
                    updatedTimeline.removeAt(index!);

                    await FirebaseFirestore.instance
                        .collection('cases')
                        .doc(_currentCase.id)
                        .update({
                      'timeline':
                          updatedTimeline.map((e) => e.toMap()).toList(),
                    });

                    if (!mounted) return;
                    setState(() {
                      _currentCase = CaseFile(
                        id: _currentCase.id,
                        clientId: _currentCase.clientId,
                        title: _currentCase.title,
                        caseNumber: _currentCase.caseNumber,
                        court: _currentCase.court,
                        status: _currentCase.status,
                        timeline: updatedTimeline,
                        nextHearingDate: _currentCase.nextHearingDate,
                        nextHearingTime: _currentCase.nextHearingTime,
                        opposingParty: _currentCase.opposingParty,
                      );
                    });
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('SİL',
                      style: TextStyle(
                          color: AppColors.error, fontWeight: FontWeight.bold)),
                ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('İptal',
                    style: TextStyle(color: AppColors.textMuted)),
              ),
              TextButton(
                onPressed: () async {
                  if (titleController.text.isEmpty) return;
                  final dateStr =
                      "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
                  final timeStr = selectedTime.format(stateContext);
                  final newEvent = CaseEvent(
                      date: dateStr,
                      time: timeStr,
                      title: titleController.text.trim(),
                      description: descController.text.trim(),
                      type: selectedType);

                  final updatedTimeline =
                      List<CaseEvent>.from(_currentCase.timeline);
                  if (existingEvent == null) {
                    updatedTimeline.add(newEvent);
                  } else {
                    updatedTimeline[index!] = newEvent;
                  }

                  Map<String, dynamic> updateData = {
                    'timeline': updatedTimeline.map((e) => e.toMap()).toList()
                  };
                  if (selectedType == 'hearing') {
                    updateData['nextHearingDate'] = dateStr;
                    updateData['nextHearingTime'] = timeStr;
                  }

                  await FirebaseFirestore.instance
                      .collection('cases')
                      .doc(_currentCase.id)
                      .update(updateData);

                  // 🔔 Yalnız YENİ gelişmelerde müvekkile bildirim gönder
                  if (existingEvent == null) {
                    final aciklama = descController.text.trim();
                    final ozet = aciklama.isNotEmpty
                        ? "${titleController.text.trim()} — $aciklama"
                        : titleController.text.trim();
                    final govde = selectedType == 'hearing'
                        ? "$ozet\nSonraki duruşma: $dateStr $timeStr"
                        : ozet;
                    FirestoreService().notifyCaseUpdate(
                      clientEmail: _currentCase.clientEmail ?? '',
                      caseId: _currentCase.id,
                      caseTitle: _currentCase.title,
                      title: 'Dosyanızda yeni gelişme',
                      body: govde,
                      type: selectedType == 'hearing'
                          ? 'hearing'
                          : 'case_update',
                    );
                  }

                  if (!mounted) return;
                  setState(() {
                    _currentCase = CaseFile(
                      id: _currentCase.id,
                      clientId: _currentCase.clientId,
                      title: _currentCase.title,
                      caseNumber: _currentCase.caseNumber,
                      court: _currentCase.court,
                      status: _currentCase.status,
                      timeline: updatedTimeline,
                      nextHearingDate: selectedType == 'hearing'
                          ? dateStr
                          : _currentCase.nextHearingDate,
                      nextHearingTime: selectedType == 'hearing'
                          ? timeStr
                          : _currentCase.nextHearingTime,
                      opposingParty: _currentCase.opposingParty,
                    );
                  });
                  Navigator.pop(dialogContext);
                },
                child: const Text('KAYDET',
                    style: TextStyle(
                        color: AppColors.gold, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
          title: const Text('Dava Detayı',
              style: TextStyle(color: AppColors.gold)),
          iconTheme: const IconThemeData(color: AppColors.gold)),
      body: Column(
        children: [
          _buildCaseHeader(), // 🌟 Başlık kısmı güncellendi
          Expanded(
            child: _currentCase.timeline.isEmpty
                ? const Center(
                    child: Text('Henüz süreç eklenmedi.',
                        style: TextStyle(color: AppColors.textMuted)))
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _currentCase.timeline.length,
                    itemBuilder: (context, index) {
                      final event =
                          _currentCase.timeline.reversed.toList()[index];
                      return LuxuryCard(
                        onTap: () => _showEventDialog(
                            existingEvent: event,
                            index: _currentCase.timeline.length - 1 - index),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(event.title,
                                    style: const TextStyle(
                                        color: AppColors.gold,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    event.time != null
                                        ? "${event.date} - ${event.time}"
                                        : event.date,
                                    style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 12)),
                              ],
                            ),
                            if (event.description.isNotEmpty)
                              Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(event.description,
                                      style: const TextStyle(
                                          color: AppColors.textSecondary))),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _showEventDialog(),
          backgroundColor: AppColors.gold,
          child: const Icon(Icons.add, color: AppColors.ink)),
    );
  }

  // 🌟 GÜNCELLENEN BAŞLIK KISMI
  Widget _buildCaseHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.navyLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(_currentCase.title,
                    style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ),

              // 🌟 DURUM GÜNCELLEME BUTONU
              InkWell(
                onTap: _showStatusUpdateDialog,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.1),
                    border: Border.all(color: AppColors.gold.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentCase.status,
                        style: const TextStyle(
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit, color: AppColors.gold, size: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.account_balance, _currentCase.court),
          _infoRow(Icons.tag, _currentCase.caseNumber),
          // Eğer karşı taraf girilmişse onu da gösterelim
          if (_currentCase.opposingParty != null &&
              _currentCase.opposingParty!.isNotEmpty)
            _infoRow(Icons.compare_arrows,
                'Karşı Taraf: ${_currentCase.opposingParty}'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Row(children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          // Yazı uzun olursa alta kaysın diye Expanded içine aldık
          child: Text(text,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
        )
      ]),
    );
  }
}
