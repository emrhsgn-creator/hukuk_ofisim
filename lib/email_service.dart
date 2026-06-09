import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// ─────────────────────────────────────────────────────────────────────────────
/// EmailJS ile (kartsız, ücretsiz) mail bildirimi gönderimi.
/// ─────────────────────────────────────────────────────────────────────────────
/// KURULUM (bir kez):
///   1. https://www.emailjs.com → ücretsiz hesap aç.
///   2. "Email Services" → kendi mail hesabını (Gmail vb.) bağla → Service ID al.
///   3. "Email Templates" → yeni şablon oluştur. Şablon değişkenleri:
///        {{to_email}}, {{client_name}}, {{case_title}}
///      Örnek konu:  S&B Legal — Dosyanızda yeni gelişme
///      Örnek içerik (KVKK için DETAY YOK, genel tutulur):
///        Sayın {{client_name}},
///        "{{case_title}}" dosyanızda yeni bir gelişme kaydedildi.
///        Ayrıntıyı görmek için lütfen S&B Legal uygulamasına giriş yapın.
///   4. "Account" → Public Key.
///   5. "Account" → Security → izin verilen origin'lere uygulamanın adresini ekle
///      (örn. http://localhost:8080 ve canlı alan adın).
///   6. Aşağıdaki üç sabiti doldur. Boş kaldığı sürece mail GÖNDERİLMEZ
///      (uygulama içi bildirim yine de çalışır).
/// ─────────────────────────────────────────────────────────────────────────────

class EmailService {
  EmailService._();

  // 🔧 EmailJS hesabından alınan değerlerle doldurun:
  static const String _serviceId = ''; // örn: 'service_xxx'
  static const String _templateId = ''; // örn: 'template_xxx'
  static const String _publicKey = ''; // örn: 'AbCdEf123...'

  static bool get isConfigured =>
      _serviceId.isNotEmpty && _templateId.isNotEmpty && _publicKey.isNotEmpty;

  /// Müvekkile genel (detaysız) bir "dosyanızda gelişme var" maili gönderir.
  /// KVKK gereği celse/karar detayı maile YAZILMAZ; detay uygulamada gösterilir.
  static Future<bool> sendUpdateEmail({
    required String toEmail,
    required String clientName,
    required String caseTitle,
  }) async {
    if (!isConfigured) {
      debugPrint('EmailJS yapılandırılmadı — mail atlanıyor.');
      return false;
    }
    if (toEmail.trim().isEmpty) return false;

    try {
      final res = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _publicKey,
          'template_params': {
            'to_email': toEmail.trim(),
            'client_name': clientName,
            'case_title': caseTitle,
          },
        }),
      );
      if (res.statusCode == 200) return true;
      debugPrint('EmailJS hata ${res.statusCode}: ${res.body}');
      return false;
    } catch (e) {
      debugPrint('EmailJS gönderim hatası: $e');
      return false;
    }
  }
}
