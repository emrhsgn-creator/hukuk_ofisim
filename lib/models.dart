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
