import 'package:cloud_firestore/cloud_firestore.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Veri Modelleri — Firestore ile uyumlu serialize/deserialize
/// ─────────────────────────────────────────────────────────────────────────────

/// Bir dava dosyasını temsil eder.
class CaseFile {
  final String id;
  final String title;
  final String caseNumber;
  final String court;
  final String status; // 'active', 'pending', 'closed'
  final String? nextHearingDate;
  final String? nextHearingTime;
  final String? lawyerName;
  final List<CaseEvent> timeline;

  CaseFile({
    required this.id,
    required this.title,
    required this.caseNumber,
    required this.court,
    required this.status,
    this.nextHearingDate,
    this.nextHearingTime,
    this.lawyerName,
    this.timeline = const [],
  });

  /// Firestore dokümanından CaseFile oluşturur.
  factory CaseFile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CaseFile(
      id: doc.id,
      title: data['title'] ?? '',
      caseNumber: data['caseNumber'] ?? '',
      court: data['court'] ?? '',
      status: data['status'] ?? 'active',
      nextHearingDate: data['nextHearingDate'],
      nextHearingTime: data['nextHearingTime'],
      lawyerName: data['lawyerName'],
      timeline: (data['timeline'] as List<dynamic>?)
              ?.map((e) => CaseEvent.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Firestore'a yazmak için Map'e dönüştürür.
  Map<String, dynamic> toMap() => {
        'title': title,
        'caseNumber': caseNumber,
        'court': court,
        'status': status,
        'nextHearingDate': nextHearingDate,
        'nextHearingTime': nextHearingTime,
        'lawyerName': lawyerName,
        'timeline': timeline.map((e) => e.toMap()).toList(),
      };
}

/// Dava sürecindeki bir olayı temsil eder (timeline öğesi).
class CaseEvent {
  final String date;
  final String title;
  final String description;
  final String type; // 'hearing', 'document', 'decision', 'note'

  CaseEvent({
    required this.date,
    required this.title,
    required this.description,
    this.type = 'note',
  });

  factory CaseEvent.fromMap(Map<String, dynamic> map) => CaseEvent(
        date: map['date'] ?? '',
        title: map['title'] ?? '',
        description: map['description'] ?? '',
        type: map['type'] ?? 'note',
      );

  Map<String, dynamic> toMap() => {
        'date': date,
        'title': title,
        'description': description,
        'type': type,
      };
}

/// Randevu talebini temsil eder.
class Appointment {
  final String? id;
  final String userId;
  final String date;
  final String time;
  final String subject;
  final String status; // 'pending', 'confirmed', 'cancelled'
  final DateTime createdAt;

  Appointment({
    this.id,
    required this.userId,
    required this.date,
    required this.time,
    required this.subject,
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Appointment(
      id: doc.id,
      userId: data['userId'] ?? '',
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      subject: data['subject'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'date': date,
        'time': time,
        'subject': subject,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

/// Kullanıcı profil bilgilerini tutar.
class UserProfile {
  final String uid;
  final String fullName;
  final String email;
  final String? phone;
  final String? tcNo;
  final String role; // 'client', 'lawyer'

  UserProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    this.phone,
    this.tcNo,
    this.role = 'client',
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      tcNo: data['tcNo'],
      role: data['role'] ?? 'client',
    );
  }

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'tcNo': tcNo,
        'role': role,
      };
}
