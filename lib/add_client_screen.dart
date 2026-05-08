import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'models.dart';
import 'firebase_service.dart';
import 'common_widgets.dart';
import 'package:uuid/uuid.dart'; // Benzersiz ID oluşturmak için

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveClient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 🌟 HATA VEREN "const" KELİMESİ BURADAN SİLİNDİ
      String tempUid = Uuid().v4(); 

      final newProfile = UserProfile(
        uid: tempUid,
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        role: 'client',
      );

      await FirestoreService().createUserProfile(newProfile);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Müvekkil başarıyla eklendi!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: const Text('Yeni Müvekkil Kaydı', style: TextStyle(color: AppColors.gold)),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SectionHeader(title: 'Müvekkil Bilgileri'),
              const SizedBox(height: 20),
              _buildField(_nameController, 'Ad Soyad', Icons.person),
              const SizedBox(height: 16),
              _buildField(_emailController, 'E-posta Adresi', Icons.email, isEmail: true),
              const SizedBox(height: 16),
              _buildField(_phoneController, 'Telefon Numarası', Icons.phone, isRequired: false),
              const SizedBox(height: 40),
              GoldButton(
                label: 'MÜVEKKİLİ KAYDET',
                icon: Icons.person_add,
                isLoading: _isLoading,
                onPressed: _saveClient,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {bool isEmail = false, bool isRequired = true}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.navyLight,
        prefixIcon: Icon(icon, color: AppColors.gold),
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMuted),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) return 'Bu alan zorunludur';
        if (isEmail && value != null && !value.contains('@')) return 'Geçersiz e-posta';
        return null;
      },
    );
  }
}