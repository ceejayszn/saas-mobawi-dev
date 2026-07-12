import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/storage/secure_storage.dart';
import '../../theme/app_colors.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  bool _notificationsEnabled = true;
  String _selectedSound = 'Default';

  final List<String> _sounds = [
    'Default',
    'Ring Ding',
    'Chime',
    'Alert',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _notificationsEnabled = await SecureStorage.getBool(AppConstants.keyNotificationsEnabled, defaultValue: true);
    _selectedSound = await SecureStorage.getString(AppConstants.keyNotificationSound) ?? 'Default';
    if (mounted) setState(() {});
  }

  Future<void> _saveToggle(bool val) async {
    setState(() => _notificationsEnabled = val);
    await SecureStorage.saveBool(AppConstants.keyNotificationsEnabled, val);
  }

  Future<void> _saveSound(String val) async {
    setState(() => _selectedSound = val);
    await SecureStorage.saveString(AppConstants.keyNotificationSound, val);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Enable Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Turn on or off all notifications', style: TextStyle(fontSize: 12)),
                    value: _notificationsEnabled,
                    activeThumbColor: AppColors.primaryGreen,
                    onChanged: _saveToggle,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    enabled: _notificationsEnabled,
                    title: const Text('Notification Sound', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('Current: $_selectedSound', style: const TextStyle(fontSize: 12)),
                    trailing: DropdownButton<String>(
                      value: _sounds.contains(_selectedSound) ? _selectedSound : 'Default',
                      underline: const SizedBox(),
                      onChanged: _notificationsEnabled ? (v) {
                        if (v != null) _saveSound(v);
                      } : null,
                      items: _sounds.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
