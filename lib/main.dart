import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 🌟 Rol okumak için eklendi
import 'firebase_options.dart';
import 'app_theme.dart';
import 'login_screen.dart';
import 'lawyer_main_shell.dart';
import 'client_main_shell.dart'; // 🌟 Müvekkil paneli eklendi

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SB Legal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}

// 🛡️ AKILLI AUTH GATE: Kullanıcıları E-POSTA ile tanır
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        final user = snapshot.data!;
        
        // 🌟 DİKKAT: Artık uid ile değil, e-posta ile arıyoruz!
        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: user.email)
              .limit(1)
              .get(),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: AppColors.navy,
                body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
              );
            }

            if (roleSnapshot.hasData && roleSnapshot.data!.docs.isNotEmpty) {
              final userData = roleSnapshot.data!.docs.first.data() as Map<String, dynamic>;
              final role = userData['role'] ?? 'client';

              if (role == 'lawyer') {
                return const LawyerMainShell();
              } else {
                return const ClientMainShell();
              }
            }

            // Kayıt bulunamazsa girişe at
            return const LoginScreen(); 
          },
        );
      },
    );
  }
}
