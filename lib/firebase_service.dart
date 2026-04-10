import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// AuthService — Firebase Authentication işlemleri
/// ─────────────────────────────────────────────────────────────────────────────
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Mevcut oturum açmış kullanıcı.
  User? get currentUser => _auth.currentUser;

  /// Oturum durumunu dinleyen stream.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// E-posta ve şifre ile giriş yapar.
  /// Hata durumunda kullanıcı dostu Türkçe mesaj döner.
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
      return (user: null, error: 'Beklenmedik bir hata oluştu. Lütfen tekrar deneyin.');
    }
  }

  /// Yeni hesap oluşturur ve Firestore'da profil kaydı yapar.
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

      // Firestore'da kullanıcı profili oluştur
      if (result.user != null) {
        await FirestoreService().createUserProfile(
          UserProfile(
            uid: result.user!.uid,
            fullName: fullName,
            email: email.trim(),
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

  /// Oturumu kapatır.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Firebase hata kodlarını Türkçe mesajlara çevirir.
  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Bu e-posta adresiyle kayıtlı bir hesap bulunamadı.';
      case 'wrong-password':
        return 'Girdiğiniz şifre hatalı. Lütfen tekrar deneyin.';
      case 'invalid-email':
        return 'Geçersiz e-posta formatı.';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanılıyor.';
      case 'weak-password':
        return 'Şifre en az 6 karakter olmalıdır.';
      case 'too-many-requests':
        return 'Çok fazla deneme yaptınız. Lütfen biraz bekleyin.';
      case 'invalid-credential':
        return 'E-posta veya şifre hatalı.';
      default:
        return 'Giriş yapılırken bir hata oluştu ($code).';
    }
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// FirestoreService — Cloud Firestore CRUD işlemleri
/// ─────────────────────────────────────────────────────────────────────────────
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ────────── Kullanıcı Profili ──────────

  /// Yeni kullanıcı profili oluşturur.
  Future<void> createUserProfile(UserProfile profile) async {
    await _db.collection('users').doc(profile.uid).set(profile.toMap());
  }

  /// Kullanıcı profilini getirir.
  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  // ────────── Dava Dosyaları ──────────

  /// Kullanıcıya ait dava dosyalarını stream olarak dinler.
  Stream<List<CaseFile>> getCaseFiles(String userId) {
    return _db
        .collection('cases')
        .where('clientId', isEqualTo: userId)
        //.orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CaseFile.fromFirestore(doc)).toList());
  }

  /// Tek bir dava dosyasını getirir.
  Future<CaseFile?> getCaseFile(String caseId) async {
    final doc = await _db.collection('cases').doc(caseId).get();
    if (!doc.exists) return null;
    return CaseFile.fromFirestore(doc);
  }

  // ────────── Randevular ──────────

  /// Yeni randevu talebi oluşturur.
  Future<void> createAppointment(Appointment appointment) async {
    await _db.collection('appointments').add(appointment.toMap());
  }

  /// Kullanıcının randevularını dinler.
  Stream<List<Appointment>> getAppointments(String userId) {
    return _db
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromFirestore(doc))
            .toList());
  }
}
