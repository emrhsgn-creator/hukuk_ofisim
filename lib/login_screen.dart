import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'firebase_service.dart';
import 'common_widgets.dart';
import 'main_shell.dart';
import 'lawyer_main_shell.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Giriş Ekranı — Firebase Auth ile e-posta/şifre doğrulama
/// ─────────────────────────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Giriş işlemini başlatır.
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _authService.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (result.error != null) {
      setState(() {
        _isLoading = false;
        _errorMessage = result.error;
      });
    } else {
      // BAŞARILI GİRİŞ: KULLANICI ROLÜNÜ KONTROL ET
      final user = result.user;
      if (user != null) {
        print('--- DİKKAT: GİRİŞ YAPAN UID: ${user.uid} ---'); // HAYALET AVI 1
        final profile = await FirestoreService().getUserProfile(user.uid);
        print('--- DİKKAT: GELEN PROFİL: $profile ---'); // HAYALET AVI 2
        
        if (profile != null) {
          print('--- DİKKAT: OKUNAN ROL: "${profile.role}" ---'); // HAYALET AVI 3
        }

        if (!mounted) return;
        
        if (profile != null && profile.role == 'lawyer') {
          // Eğer rol "lawyer" ise Avukat Yönetim Paneline yönlendir
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LawyerMainShell()),
          );
        } else {
          // Değilse normal Müvekkil Ana Sayfasına yönlendir
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainShell()),
          );
        }
      }
    }
  } // DİKKAT: EKSİK OLAN 1. PARANTEZ BURAYA EKLENDİ

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.navyGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 28,
              right: 28,
              top: 48,
              bottom: bottomPadding + 24,
            ),
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: Column(
                  children: [
                    // ── Logo ──
                    const AppLogo(size: 56),
                    const SizedBox(height: 48),

                    // ── Hata Mesajı ──
                    if (_errorMessage != null) _buildErrorBanner(),

                    // ── Giriş Formu ──
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildEmailField(),
                          const SizedBox(height: 16),
                          _buildPasswordField(),
                          const SizedBox(height: 12),
                          _buildForgotPassword(),
                          const SizedBox(height: 28),
                          GoldButton(
                            label: 'GİRİŞ YAP',
                            isLoading: _isLoading,
                            onPressed: _handleLogin,
                            icon: Icons.login_rounded,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    _buildDivider(),
                    const SizedBox(height: 24),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Hata banner'ı — kırmızı arka plan ile uyarı gösterir.
  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _errorMessage = null),
            child: const Icon(Icons.close, color: AppColors.error, size: 18),
          ),
        ],
      ),
    );
  }

  /// E-posta giriş alanı.
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: const InputDecoration(
        labelText: 'E-posta Adresi',
        hintText: 'ornek@mail.com',
        prefixIcon: Icon(Icons.mail_outline),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'E-posta adresi gereklidir.';
        }
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value.trim())) {
          return 'Geçerli bir e-posta adresi girin.';
        }
        return null;
      },
    );
  }

  /// Şifre giriş alanı — göster/gizle butonu içerir.
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleLogin(),
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: 'Şifre',
        hintText: '••••••••',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textMuted,
            size: 20,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Şifre gereklidir.';
        }
        if (value.length < 6) {
          return 'Şifre en az 6 karakter olmalıdır.';
        }
        return null;
      },
    );
  }

  /// "Şifremi Unuttum" bağlantısı.
  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          _showPasswordResetDialog();
        },
        child: const Text(
          'Şifremi Unuttum',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  /// Şifre sıfırlama dialog'u.
  void _showPasswordResetDialog() {
    final resetEmailController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navyLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Şifre Sıfırla',
          style: TextStyle(color: AppColors.gold, fontFamily: 'Playfair Display'),
        ),
        content: TextField(
          controller: resetEmailController,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'E-posta adresinizi girin',
            prefixIcon: Icon(Icons.mail_outline),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Şifre sıfırlama e-postası gönderildi.'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Gönder', style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );
  }

  /// Görsel ayırıcı çizgi.
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.navyMedium.withOpacity(0.5))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'SB LEGAL',
            style: TextStyle(
              color: AppColors.textMuted.withOpacity(0.5),
              fontSize: 11,
              letterSpacing: 3,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.navyMedium.withOpacity(0.5))),
      ],
    );
  }

  /// Alt bilgi metni.
  Widget _buildFooter() {
    return Text(
      'Gizlilik ve güvenliğiniz bizim için önemlidir.\nTüm verileriniz şifreli olarak saklanır.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: AppColors.textMuted.withOpacity(0.6),
        fontSize: 12,
        height: 1.6,
      ),
    );
  }
}
