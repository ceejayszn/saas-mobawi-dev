import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/security/auth_service.dart';
import '../../core/storage/secure_storage.dart';
import '../../theme/app_colors.dart';
import '../login_screen.dart';
import 'profile_settings.dart';
import 'business_settings.dart';

import 'theme_settings.dart';
import 'security_settings.dart';
import 'device_info_screen.dart';
import 'support_screen.dart';
import 'about_screen.dart';
import 'integrations_screen.dart';
import 'notification_settings.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _adminName = 'Admin';
  String _adminRole = 'System Administrator';
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final name = await SecureStorage.getString(AppConstants.keyProfileName);
    final role = await SecureStorage.getString(AppConstants.keyProfileRole);
    final imagePath = await SecureStorage.getString(AppConstants.keyProfileImagePath);
    if (mounted) {
      setState(() {
        if (name != null && name.isNotEmpty) _adminName = name;
        if (role != null && role.isNotEmpty) _adminRole = role;
        _imagePath = imagePath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              width: double.infinity,
              color: isDark ? AppColors.darkSurface : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _navigate(context, const ProfileSettings()),
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _imagePath != null
                          ? ClipOval(
                              child: Image.file(
                                File(_imagePath!),
                                width: 68,
                                height: 68,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Center(
                              child: Text(
                                _adminName.isNotEmpty ? _adminName[0].toUpperCase() : 'A',
                                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_adminName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(_adminRole, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Active', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: AppColors.primaryGreen),
                    onPressed: () => _navigate(context, const ProfileSettings()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            _buildSection('Account', isDark, [
              _SettingItem(Icons.person_rounded, 'Profile', 'Manage your account details', AppColors.info, () => _navigate(context, const ProfileSettings())),
              _SettingItem(Icons.business_rounded, 'Business Settings', 'Configure business info', AppColors.orange, () => _navigate(context, const BusinessSettings())),
            ]),
            const SizedBox(height: 12),

            _buildSection('Preferences', isDark, [
              _SettingItem(Icons.palette_rounded, 'Theme', 'Light & Dark mode', AppColors.purple, () => _navigate(context, const ThemeSettings())),
              _SettingItem(Icons.notifications_active_rounded, 'Notifications', 'Manage sounds and alerts', AppColors.orange, () => _navigate(context, const NotificationSettings())),
            ]),
            const SizedBox(height: 12),

            _buildSection('Security', isDark, [
              _SettingItem(Icons.lock_rounded, 'Security & Password', 'PIN and security questions', AppColors.error, () => _navigate(context, const SecuritySettings())),
              _SettingItem(Icons.phone_android_rounded, 'Device Information', 'Hardware & software info', AppColors.teal, () => _navigate(context, const DeviceInfoScreen())),
            ]),
            const SizedBox(height: 12),

            _buildSection('Information', isDark, [
              _SettingItem(Icons.support_agent_rounded, 'Support', 'Contact developer', AppColors.success, () => _navigate(context, const SupportScreen())),
              _SettingItem(Icons.info_rounded, 'About', 'App version & legal', AppColors.info, () => _navigate(context, const AboutScreen())),
            ]),
            const SizedBox(height: 12),

            _buildSection('Future', isDark, [
              _SettingItem(Icons.integration_instructions_rounded, 'Integrations', 'Coming soon modules', AppColors.textSecondary, () => _navigate(context, const IntegrationsScreen()), isPlaceholder: true),
            ]),
            const SizedBox(height: 24),

            // Logout button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                  label: const Text('Sign Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700, fontSize: 15)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${AppConstants.appName} v${AppConstants.appVersion}',
              style: const TextStyle(color: AppColors.textHint, fontSize: 12),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, bool isDark, List<_SettingItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: item.isPlaceholder
                            ? AppColors.textHint.withValues(alpha: 0.1)
                            : item.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        item.icon,
                        color: item.isPlaceholder ? AppColors.textHint : item.color,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: item.isPlaceholder
                            ? AppColors.textSecondary
                            : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                      ),
                    ),
                    subtitle: Text(
                      item.subtitle,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: item.isPlaceholder ? AppColors.textHint.withValues(alpha: 0.4) : AppColors.textSecondary,
                    ),
                    onTap: item.isPlaceholder ? null : item.onTap,
                  ),
                  if (i < items.length - 1)
                    const Divider(height: 1, indent: 60, endIndent: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    ).then((_) => _loadProfile());
  }

  Future<void> _logout(BuildContext context) async {
    final navigator = Navigator.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of the admin panel?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await AuthService.instance.logout();
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}

class _SettingItem {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isPlaceholder;
  const _SettingItem(this.icon, this.title, this.subtitle, this.color, this.onTap, {this.isPlaceholder = false});
}
