import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/utils/input_validator.dart';
import '../../core/security/crypto_utils.dart';
import '../../theme/app_colors.dart';

class BusinessSettings extends StatefulWidget {
  const BusinessSettings({super.key});

  @override
  State<BusinessSettings> createState() => _BusinessSettingsState();
}

class _BusinessSettingsState extends State<BusinessSettings> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _taxCtrl = TextEditingController();

  String _selectedType = AppConstants.businessTypes[0];
  String _subgroup = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _nameCtrl.text = await SecureStorage.getString(AppConstants.keyBusinessName) ?? 'Euton Hotel';
    _selectedType = await SecureStorage.getString(AppConstants.keyBusinessType) ?? AppConstants.businessTypes[0];
    _subgroup = await SecureStorage.getString(AppConstants.keyBusinessSubgroup) ?? '';
    _addressCtrl.text = await SecureStorage.getString(AppConstants.keyBusinessAddress) ?? '';
    _phoneCtrl.text = await SecureStorage.getString(AppConstants.keyBusinessPhone) ?? '';
    _emailCtrl.text = await SecureStorage.getString(AppConstants.keyBusinessEmail) ?? '';
    _websiteCtrl.text = await SecureStorage.getString(AppConstants.keyBusinessWebsite) ?? '';
    _taxCtrl.text = await SecureStorage.getString(AppConstants.keyBusinessTax) ?? '';
    if (mounted) setState(() {});
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    await SecureStorage.saveString(AppConstants.keyBusinessName, CryptoUtils.sanitizeInput(_nameCtrl.text.trim()));
    await SecureStorage.saveString(AppConstants.keyBusinessType, _selectedType);
    await SecureStorage.saveString(AppConstants.keyBusinessSubgroup, CryptoUtils.sanitizeInput(_subgroup.trim()));
    await SecureStorage.saveString(AppConstants.keyBusinessAddress, CryptoUtils.sanitizeInput(_addressCtrl.text.trim()));
    await SecureStorage.saveString(AppConstants.keyBusinessPhone, _phoneCtrl.text.trim());
    await SecureStorage.saveString(AppConstants.keyBusinessEmail, _emailCtrl.text.trim().toLowerCase());
    await SecureStorage.saveString(AppConstants.keyBusinessWebsite, _websiteCtrl.text.trim());
    await SecureStorage.saveString(AppConstants.keyBusinessTax, _taxCtrl.text.trim());

    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business settings saved'), backgroundColor: AppColors.success),
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _websiteCtrl.dispose();
    _taxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: const Text('Business Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('Business Identity'),
              _card(isDark, [
                _field('Business Name', _nameCtrl, Icons.store_rounded, validator: InputValidator.validateBusinessName),
                const SizedBox(height: 16),
                // Business Type Dropdown
                DropdownButtonFormField<String>(
                  initialValue: AppConstants.businessTypes.contains(_selectedType) ? _selectedType : AppConstants.businessTypes[0],
                  decoration: const InputDecoration(
                    labelText: 'Business Type',
                    prefixIcon: Icon(Icons.category_rounded, color: AppColors.primaryGreen, size: 20),
                  ),
                  items: AppConstants.businessTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedType = v ?? _selectedType),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _subgroup,
                  onChanged: (v) => _subgroup = v,
                  validator: (v) => InputValidator.validateOptionalText(v, 'Subgroup'),
                  decoration: const InputDecoration(
                    labelText: 'Business Subgroup (optional)',
                    prefixIcon: Icon(Icons.label_rounded, color: AppColors.primaryGreen, size: 20),
                    hintText: 'e.g. Fine Dining, Budget Hotel',
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              _sectionLabel('Contact Details'),
              _card(isDark, [
                _field('Physical Address', _addressCtrl, Icons.location_on_rounded,
                    validator: (v) => InputValidator.validateOptionalText(v, 'Address')),
                const SizedBox(height: 16),
                _field('Phone Number', _phoneCtrl, Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                    validator: InputValidator.validatePhone),
                const SizedBox(height: 16),
                _field('Email Address', _emailCtrl, Icons.email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: InputValidator.validateEmail),
                const SizedBox(height: 16),
                _field('Website', _websiteCtrl, Icons.language_rounded,
                    keyboardType: TextInputType.url,
                    validator: InputValidator.validateUrl),
              ]),
              const SizedBox(height: 16),
              _sectionLabel('Tax & Legal'),
              _card(isDark, [
                _field('Tax Number (optional)', _taxCtrl, Icons.receipt_long_rounded,
                    validator: (v) => InputValidator.validateOptionalText(v, 'Tax number')),
              ]),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveSettings,
                  child: _isSaving
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Save Business Settings'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 0.5)),
  );

  Widget _card(bool isDark, List<Widget> children) => Container(
    padding: const EdgeInsets.all(20),
    margin: const EdgeInsets.only(bottom: 4),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkCard : Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
    ),
    child: Column(children: children),
  );

  Widget _field(String label, TextEditingController ctrl, IconData icon,
      {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryGreen, size: 20),
      ),
    );
  }
}
