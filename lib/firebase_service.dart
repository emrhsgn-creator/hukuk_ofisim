import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'models.dart';
import 'package:firebase_core/firebase_core.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// AuthService — Firebase Authentication İşlemleri
/// ─────────────────────────────────────────────────────────────────────────────
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<({User? user, String? error})> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return (user: result.user, error: null);
    } on FirebaseAuthException catch (e) {
      return (user: null, error: _mapAuthError(e.code));
    } catch (e) {
      return (user: null, error: 'Beklenmedik bir hata oluştu.');
    }
  }

  Future<({User? user, String? error})> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (result.user != null) {
        await FirestoreService().createUserProfile(
          UserProfile(
            uid: result.user!.uid,
            fullName: fullName,
            email: email.trim(),
            role: 'client',
          ),
        );
      }
      return (user: result.user, error: null);
    } on FirebaseAuthException catch (e) {
      return (user: null, error: _mapAuthError(e.code));
    } catch (e) {
      return (user: null, error: 'Kayıt sırasında bir hata oluştu.');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Şifre sıfırlama e-postası gönderir.
  Future<({bool success, String? error})> sendPasswordReset(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      return (success: false, error: 'Lütfen e-posta adresinizi girin.');
    }
    try {
      await _auth.sendPasswordResetEmail(email: trimmed);
      return (success: true, error: null);
    } on FirebaseAuthException catch (e) {
      return (success: false, error: _mapAuthError(e.code));
    } catch (e) {
      return (success: false, error: 'Şifre sıfırlama e-postası gönderilemedi.');
    }
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Bu e-posta adresiyle kayıtlı bir hesap bulunamadı.';
      case 'wrong-password':
        return 'Girdiğiniz şifre hatalı.';
      case 'invalid-email':
        return 'Geçersiz e-posta formatı.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanılıyor.';
      case 'weak-password':
        return 'Şifre en az 6 karakter olmalıdır.';
      case 'invalid-credential':
        return 'E-posta veya şifre hatalı.';
      default:
        return 'Bir hata oluştu ($code).';
    }
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// FirestoreService — Cloud Firestore İşlemleri
/// ─────────────────────────────────────────────────────────────────────────────
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // Dava dosyasını silen fonksiyon
  Future<void> deleteCaseFile(String caseId) async {
    try {
      await _db.collection('cases').doc(caseId).delete();
    } catch (e) {
      debugPrint('Dosya silinirken hata oluştu: $e');
      rethrow;
    }
  }

  // Müvekkili (Kullanıcı Profilini) silen fonksiyon
  Future<void> deleteUserProfile(String uid) async {
    try {
      // Not: 'users' koleksiyon adı senin projende farklıysa (örn: 'profiles') onu değiştir
      await _db.collection('users').doc(uid).delete();
    } catch (e) {
      debugPrint('Müvekkil silinirken hata oluştu: $e');
      rethrow;
    }
  }

  // Randevu talebini (Appointment) tamamen silen fonksiyon
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _db.collection('appointments').doc(appointmentId).delete();
    } catch (e) {
      debugPrint('Randevu silinirken hata oluştu: $e');
      rethrow;
    }
  }

  // 🌟 MÜVEKKİLE ŞİFRE OLUŞTURMA MOTORU (Kusursuz Versiyon)
  Future<String> grantClientAccess(String email) async {
    String password =
        (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString();

    FirebaseApp tempApp;

    try {
      // 🌟 ÇÖZÜM: Arka planda çalışan tüm Firebase motorlarının listesine bakıyoruz
      var existingApps =
          Firebase.apps.where((app) => app.name == 'ClientCreatorApp').toList();

      if (existingApps.isNotEmpty) {
        // Eğer motor zaten varsa (önceden butona basıldıysa) onu kullan
        tempApp = existingApps.first;
      } else {
        // Eğer listede yoksa, güvenle yepyeni bir tane oluştur
        tempApp = await Firebase.initializeApp(
          name: 'ClientCreatorApp',
          options: Firebase.app().options,
        );
      }

      // Şifreyi oluştur
      await FirebaseAuth.instanceFor(app: tempApp)
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return password;
    } catch (e) {
      // Eğer şifre oluşturulurken e-posta hatası çıkarsa buraya düşer
      throw 'HATA: Bu e-posta adresi zaten kullanımda veya formatı geçersiz.';
    }
  }

  // ────────── Kullanıcı İşlemleri ──────────

  Future<void> createUserProfile(UserProfile profile) async {
    await _db.collection('users').doc(profile.uid).set(profile.toMap());
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  /// E-posta ile profil okur. Sistem e-posta merkezli olduğundan (users döküman
  /// id'si Auth uid'ine eşit olmayabilir) uid yerine bunu kullanmak daha güvenli.
  Future<UserProfile?> getUserProfileByEmail(String email) async {
    final snap = await _db
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return UserProfile.fromFirestore(snap.docs.first);
  }


  Future<List<UserProfile>> getAllClients() async {
    final snapshot =
        await _db.collection('users').where('role', isEqualTo: 'client').get();
    return snapshot.docs.map((doc) => UserProfile.fromFirestore(doc)).toList();
  }

  // ────────── Dava Dosyası ve Süreç İşlemleri ──────────

  Future<void> addCaseFile(CaseFile caseFile) async {
    await _db.collection('cases').add(caseFile.toMap());
  }

  Future<void> addEventToCase(String caseId, CaseEvent event) async {
    final docRef = _db.collection('cases').doc(caseId);

    await docRef.update({
      'timeline': FieldValue.arrayUnion([event.toMap()])
    });

    if (event.type == 'hearing') {
      await docRef.update({
        'nextHearingDate': event.date,
        'nextHearingTime': event.time,
      });
    }
  }

  Stream<List<CaseFile>> getCaseFilesForClient(String clientId) {
    return _db
        .collection('cases')
        .where('clientId', isEqualTo: clientId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CaseFile.fromFirestore(doc)).toList());
  }

  Stream<CaseFile?> getUpcomingHearing(String clientId) {
    return _db
        .collection('cases')
        .where('clientId', isEqualTo: clientId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;

      final cases =
          snapshot.docs.map((doc) => CaseFile.fromFirestore(doc)).toList();
      final hearingCases = cases
          .where(
              (c) => c.nextHearingDate != null && c.nextHearingDate!.isNotEmpty)
          .toList();

      if (hearingCases.isEmpty) return null;

      hearingCases
          .sort((a, b) => a.nextHearingDate!.compareTo(b.nextHearingDate!));
      return hearingCases.first;
    });
  }

  Future<CaseFile?> getCaseFile(String caseId) async {
    final doc = await _db.collection('cases').doc(caseId).get();
    if (!doc.exists) return null;
    return CaseFile.fromFirestore(doc);
  }

  // ────────── Randevu İşlemleri ──────────

  Future<void> createAppointment(Appointment appointment) async {
    await _db.collection('appointments').add(appointment.toMap());
  }

  Stream<List<Appointment>> getClientAppointments(String clientId) {
    return _db
        .collection('appointments')
        .where('clientId', isEqualTo: clientId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromFirestore(doc))
            .toList());
  }

  // 🌟 İŞTE HATA VEREN FONKSİYON TAM BURADA! 🌟
  Stream<List<Appointment>> getClientActiveAppointments(String clientId) {
    return _db
        .collection('appointments')
        .where('clientId', isEqualTo: clientId)
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromFirestore(doc))
            .toList());
  }

  Stream<List<Appointment>> getAllAppointments() {
    return _db.collection('appointments').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Appointment.fromFirestore(doc)).toList());
  }

  Future<void> updateAppointmentStatus(String id, String status) async {
    await _db.collection('appointments').doc(id).update({'status': status});
  }
}
