import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// FİREBASE AYAR DOSYASI EKLENDİ (Kırmızı ekrandan kurtaran satır)
import 'firebase_options.dart'; 

// CLAUDE'UN DOSYA YAPISI (Bu dosyaları birazdan oluşturacağız)
import 'app_theme.dart';
import 'login_screen.dart';
import 'main_shell.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// SB Legal — Ana Giriş Noktası
/// ─────────────────────────────────────────────────────────────────────────────

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // FİREBASE BAĞLANTISI AKTİF EDİLDİ
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, 
  );

  // Sistem UI stilini ayarla — status bar luxury temaya uygun
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0A192F), // Tema rengi
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Tüm yönlendirmelere (Dikey ve Yatay) izin ver
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const SBLegalApp());
}

/// Uygulamanın kök widget'ı.
class SBLegalApp extends StatelessWidget {
  const SBLegalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SB Legal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // Tema dosyasından çekilecek
      home: const AuthGate(),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// AuthGate — Kullanıcı oturum durumunu dinler
/// ─────────────────────────────────────────────────────────────────────────────
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const MainShell();
        }

        return const LoginScreen();
      },
    );
  }
}

/// Uygulama yüklenirken gösterilen splash ekranı.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F), // Yedek arka plan
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F203C), Color(0xFF0A192F)], // Lacivert geçiş
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1200),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(
                      scale: 0.8 + (value * 0.2),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFD4AF37), width: 2), // Altın rengi
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.balance,
                        color: Color(0xFFD4AF37),
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'SB LEGAL',
                      style: TextStyle(
                        fontFamily: 'Playfair Display', // Bu fontu daha sonra ekleriz
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4AF37),
                        letterSpacing: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFFD4AF37),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}