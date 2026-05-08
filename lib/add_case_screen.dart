import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'models.dart';
import 'firebase_service.dart';
import 'common_widgets.dart';

class AddCaseScreen extends StatefulWidget {
  const AddCaseScreen({super.key});

  @override
  State<AddCaseScreen> createState() => _AddCaseScreenState();
}

class _AddCaseScreenState extends State<AddCaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _caseNumberController = TextEditingController();
  final _courtController = TextEditingController();
  final _opposingPartyController = TextEditingController();

  final _clientSearchController = TextEditingController();

  String? _selectedClientId;

  // 🌟 YENİ: DOSYA DURUMU SEÇENEKLERİ
  final List<String> _statusOptions = [
    'Derdest',
    'Karara Çıkmış',
    'İstinafta',
    'Yargıtayda',
    'İnfazda',
    'Arabuluculukta',
    'Kapalı'
  ];
  String _selectedStatus = 'Derdest'; // Varsayılan olarak Derdest seçili gelsin

  bool _isLoading = false;
  List<UserProfile> _clients = [];
  bool _isLoadingClients = true;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    try {
      final clients = await FirestoreService().getAllClients();
      clients.sort((a, b) =>
          a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));

      if (mounted) {
        setState(() {
          _clients = clients;
          _isLoadingClients = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingClients = false);
    }
  }

  Future<void> _saveCase() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedClientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lütfen listeden bir müvekkil arayıp seçin.'),
            backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newCase = CaseFile(
        id: '',
        clientId: _selectedClientId!,
        title: _titleController.text.trim(),
        caseNumber: _caseNumberController.text.trim(),
        court: _courtController.text.trim(),
        opposingParty: _opposingPartyController.text.trim(),
        status:
            _selectedStatus, // 🌟 YENİ: Artık sabit "active" değil, seçilen durumu kaydediyoruz
      );

      await FirestoreService().addCaseFile(newCase);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Dava dosyası başarıyla oluşturuldu!'),
              backgroundColor: AppColors.success),
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
        title: const Text('Yeni Dava Dosyası',
            style: TextStyle(color: AppColors.gold)),
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      body: _isLoadingClients
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Müvekkil Seçimi'),
                    const SizedBox(height: 8),

                    Autocomplete<UserProfile>(
                      displayStringForOption: (UserProfile option) =>
                          option.fullName,
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<UserProfile>.empty();
                        }
                        return _clients.where((UserProfile client) {
                          return client.fullName
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase());
                        });
                      },
                      onSelected: (UserProfile selection) {
                        setState(() {
                          _selectedClientId = selection.uid;
                        });
                      },
                      fieldViewBuilder:
                          (context, controller, focusNode, onFieldSubmitted) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.navyLight,
                            prefixIcon: const Icon(Icons.person_search,
                                color: AppColors.gold),
                            suffixIcon: controller.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear,
                                        color: AppColors.textMuted),
                                    onPressed: () {
                                      controller.clear();
                                      setState(() => _selectedClientId = null);
                                    },
                                  )
                                : null,
                            labelText: 'Müvekkil Ara (İsim yazmaya başlayın)',
                            labelStyle:
                                const TextStyle(color: AppColors.textMuted),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                          ),
                          validator: (value) {
                            if (_selectedClientId == null) {
                              return 'Lütfen listeden geçerli bir müvekkil seçin';
                            }
                            return null;
                          },
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              width: MediaQuery.of(context).size.width - 48,
                              margin: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                color: AppColors.navyLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.gold.withOpacity(0.3)),
                              ),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final UserProfile option =
                                      options.elementAt(index);
                                  return ListTile(
                                    title: Text(option.fullName,
                                        style: const TextStyle(
                                            color: Colors.white)),
                                    subtitle: Text(option.email,
                                        style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12)),
                                    leading: const Icon(Icons.person,
                                        color: AppColors.gold),
                                    onTap: () => onSelected(option),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                    const SectionHeader(title: 'Dava Detayları'),

                    _buildTextField(
                      controller: _titleController,
                      label: 'Dosya Başlığı / Türü (Örn: İş Kazası)',
                      icon: Icons.folder_special,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _courtController,
                      label: 'Mahkeme (Örn: Bakırköy 6. İş Mahkemesi)',
                      icon: Icons.account_balance,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _caseNumberController,
                      label: 'Esas Numarası (Örn: 2025/657)',
                      icon: Icons.tag,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _opposingPartyController,
                      label: 'Karşı Taraf (Davalı/Davacı Kurum veya Şahıs)',
                      icon: Icons.compare_arrows,
                      isRequired: false,
                    ),
                    const SizedBox(height: 16),

                    // 🌟 YENİ: DOSYA DURUMU AÇILIR MENÜSÜ
                    DropdownButtonFormField<String>(
                      initialValue: _selectedStatus,
                      dropdownColor: AppColors.navyLight,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.navyLight,
                        prefixIcon: const Icon(Icons.info_outline,
                            color: AppColors.gold),
                        labelText: 'Dosya Durumu',
                        labelStyle: const TextStyle(color: AppColors.textMuted),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                      ),
                      items: _statusOptions.map((status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 40),
                    GoldButton(
                      label: 'DOSYAYI OLUŞTUR',
                      icon: Icons.save,
                      isLoading: _isLoading,
                      onPressed: _saveCase,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.navyLight,
        prefixIcon: Icon(icon, color: AppColors.gold),
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMuted),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
      validator: isRequired
          ? (value) =>
              value == null || value.isEmpty ? 'Bu alan zorunludur' : null
          : null,
    );
  }
}
