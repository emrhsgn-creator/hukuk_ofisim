import 'package:cloud_firestore/cloud_firestore.dart';

class CaseFile {
  final String id;
  final String clientId;
  final String title;
  final String caseNumber;
  final String court;
  final String status;
  final List<CaseEvent> timeline;
  final String? nextHearingDate;
  final String? nextHearingTime;
  final String? opposingParty;
  final String? lawyerName; // 🌟 EKSİK OLAN DEĞİŞKEN EKLENDİ
  // 🔐 Güvenlik kurallarının müvekkil sahipliğini doğrulayabilmesi için, davanın
  // sahibi müvekkilin e-postası. (clientId rastgele UUID olduğundan kurallar onu
  // kimliğe bağlayamıyor; e-posta token ile eşleştirilebiliyor.)
  final String? clientEmail;

  CaseFile({
    required this.id,
    required this.clientId,
    required this.title,
    required this.caseNumber,
    required this.court,
    required this.status,
    this.timeline = const [],
    this.nextHearingDate,
    this.nextHearingTime,
    this.opposingParty,
    this.lawyerName, // 🌟
    this.clientEmail,
  });

  factory CaseFile.fromFirestore(dynamic doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CaseFile(
      id: doc.id,
      clientId: data['clientId'] ?? '',
      title: data['title'] ?? '',
      caseNumber: data['caseNumber'] ?? '',
      court: data['court'] ?? '',
      status: data['status'] ?? 'active',
      opposingParty: data['opposingParty'],
      lawyerName: data['lawyerName'], // 🌟
      clientEmail: data['clientEmail'],
      timeline: (data['timeline'] as List<dynamic>?)
              ?.map((e) => CaseEvent.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      nextHearingDate: data['nextHearingDate'],
      nextHearingTime: data['nextHearingTime'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'title': title,
      'caseNumber': caseNumber,
      'court': court,
      'status': status,
      'opposingParty': opposingParty,
      'lawyerName': lawyerName, // 🌟
      'clientEmail': clientEmail,
      'timeline': timeline.map((e) => e.toMap()).toList(),
      'nextHearingDate': nextHearingDate,
      'nextHearingTime': nextHearingTime,
    };
  }
}

class CaseEvent {
  final String date;
  final String? time; // 🌟 Saat alanı
  final String title;
  final String description;
  final String type;

  CaseEvent({
    required this.date,
    this.time,
    required this.title,
    required this.description,
    this.type = 'note',
  });

  factory CaseEvent.fromMap(Map<String, dynamic> map) => CaseEvent(
        date: map['date'] ?? '',
        time: map['time'],
        title: map['title'] ?? '',
        description: map['description'] ?? '',
        type: map['type'] ?? 'note',
      );

  Map<String, dynamic> toMap() => {
        'date': date,
        'time': time,
        'title': title,
        'description': description,
        'type': type,
      };
}

// UserProfile ve Appointment modelleri de burada durmalı...
class UserProfile {
  final String uid;
  final String fullName;
  final String email;
  final String role;
  UserProfile(
      {required this.uid,
      required this.fullName,
      required this.email,
      required this.role});
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
        uid: doc.id,
        fullName: data['fullName'] ?? '',
        email: data['email'] ?? '',
        role: data['role'] ?? 'client');
  }
  Map<String, dynamic> toMap() =>
      {'fullName': fullName, 'email': email, 'role': role};
}

/// Müvekkile gönderilen uygulama içi bildirim (dava güncellemesi vb.)
class AppNotification {
  final String id;
  final String clientEmail; // hedef müvekkilin e-postası (kural + sorgu için)
  final String caseId;
  final String caseTitle;
  final String title; // örn: "Dosyanızda yeni gelişme"
  final String body; // güncelleme metni (in-app'te detay gösterilir)
  final String type; // 'case_update' | 'hearing' | ...
  final DateTime? createdAt;
  final bool read;

  AppNotification({
    required this.id,
    required this.clientEmail,
    required this.caseId,
    required this.caseTitle,
    required this.title,
    required this.body,
    this.type = 'case_update',
    this.createdAt,
    this.read = false,
  });

  Map<String, dynamic> toMap() => {
        'clientEmail': clientEmail,
        'caseId': caseId,
        'caseTitle': caseTitle,
        'title': title,
        'body': body,
        'type': type,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
        'read': read,
      };

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final ts = data['createdAt'];
    return AppNotification(
      id: doc.id,
      clientEmail: data['clientEmail'] ?? '',
      caseId: data['caseId'] ?? '',
      caseTitle: data['caseTitle'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: data['type'] ?? 'case_update',
      createdAt: ts is Timestamp ? ts.toDate() : null,
      read: data['read'] ?? false,
    );
  }
}

class Appointment {
  final String id;
  final String clientId;
  final String clientName;
  final String date;
  final String time;
  final String subject;
  final String status;
  Appointment(
      {required this.id,
      required this.clientId,
      required this.clientName,
      required this.date,
      required this.time,
      required this.subject,
      this.status = 'pending'});
  Map<String, dynamic> toMap() => {
        'clientId': clientId,
        'clientName': clientName,
        'date': date,
        'time': time,
        'subject': subject,
        'status': status
      };
  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Appointment(
        id: doc.id,
        clientId: data['clientId'] ?? '',
        clientName: data['clientName'] ?? '',
        date: data['date'] ?? '',
        time: data['time'] ?? '',
        subject: data['subject'] ?? '',
        status: data['status'] ?? 'pending');
  }
}
