import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';
import 'main.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // 3 saniye sonra uygulamaya geç
    Future.delayed(const Duration(seconds: 3), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy, 
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Image.network(
            'https://i.ibb.co/07PH08Q/logo.png', // 🌟 Doğrudan resim bağlantın
            width: 280, // Logoyu biraz daha belirgin yaptık
            fit: BoxFit.contain,
            // Yüklenirken dönen altın sarısı imleç
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const CircularProgressIndicator(color: AppColors.gold);
            },
            // Linkte bir sorun olursa yedek lüks ikon
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.balance, size: 80, color: AppColors.gold);
            },
          ),
        ),
      ),
    );
  }
}