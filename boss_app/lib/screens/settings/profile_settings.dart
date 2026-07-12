import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/utils/input_validator.dart';
import '../../core/security/crypto_utils.dart';
import '../../theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  bool _isSaving = false;
  bool _hasChanges = false;
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _nameCtrl.addListener(() => setState(() => _hasChanges = true));
    _roleCtrl.addListener(() => setState(() => _hasChanges = true));
  }

  Future<void> _loadProfile() async {
    final name = await SecureStorage.getString(AppConstants.keyProfileName);
    final role = await SecureStorage.getString(AppConstants.keyProfileRole);
    final imagePath = await SecureStorage.getString(AppConstants.keyProfileImagePath);
    if (mounted) {
      _nameCtrl.text = name ?? 'Admin';
      _roleCtrl.text = role ?? 'System Administrator';
      _imagePath = imagePath;
      setState(() => _hasChanges = false);
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
        _hasChanges = true;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final sanitizedName = CryptoUtils.sanitizeInput(_nameCtrl.text.trim());
    final sanitizedRole = CryptoUtils.sanitizeInput(_roleCtrl.text.trim());
    await SecureStorage.saveString(AppConstants.keyProfileName, sanitizedName);
    await SecureStorage.saveString(AppConstants.keyProfileRole, sanitizedRole);
    if (_imagePath != null) {
      await SecureStorage.saveString(AppConstants.keyProfileImagePath, _imagePath!);
    }
    setState(() {
      _isSaving = false;
      _hasChanges = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: _imagePath != null
                          ? ClipOval(
                              child: Image.file(
                                File(_imagePath!),
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Center(
                              child: Text(
                                _nameCtrl.text.isNotEmpty ? _nameCtrl.text[0].toUpperCase() : 'A',
                                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900),
                              ),
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildCard(isDark, [
                _buildField('Display Name', _nameCtrl, Icons.person_rounded,
                    validator: InputValidator.validateDisplayName),
                const SizedBox(height: 16),
                _buildField('Role / Title', _roleCtrl, Icons.badge_rounded,
                    validator: (v) => InputValidator.validateRequired(v, 'Role')),
              ]),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  child: _isSaving
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(bool isDark, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, {String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryGreen, size: 20),
      ),
    );
  }
}
