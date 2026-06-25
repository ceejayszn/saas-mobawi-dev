import 'package:flutter/material.dart';
import 'welcome_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFF1B5E20),
                    child: const Text('A', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  const Text('Admin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('System Administrator', style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection('Account', [
              _buildSettingTile(Icons.person_outline, 'Profile', 'Manage your account details'),
              _buildSettingTile(Icons.business_outlined, 'Business Settings', 'Configure business info'),
            ]),
            const SizedBox(height: 12),
            _buildSection('Preferences', [
              _buildSettingTile(Icons.notifications_outlined, 'Notifications', 'Configure push notifications'),
              _buildSettingTile(Icons.palette_outlined, 'Theme', 'App appearance and colors'),
            ]),
            const SizedBox(height: 12),
            _buildSection('Security', [
              _buildSettingTile(Icons.lock_outline, 'Security', 'Change password and permissions'),
              _buildSettingTile(Icons.phone_android_outlined, 'Device Information', 'View connected devices'),
            ]),
            const SizedBox(height: 12),
            _buildSection('Information', [
              _buildSettingTile(Icons.info_outline, 'About', 'App version and legal info'),
              _buildSettingTile(Icons.support_outlined, 'Support', 'Get help and contact developer'),
            ]),
            const SizedBox(height: 12),
            _buildSection('Future Integrations', [
              _buildSettingTile(Icons.cloud_outlined, 'Cloud Sync', 'Coming soon', isPlaceholder: true),
              _buildSettingTile(Icons.analytics_outlined, 'SuperAdmin Link', 'Coming soon', isPlaceholder: true),
              _buildSettingTile(Icons.api_outlined, 'API Connections', 'Coming soon', isPlaceholder: true),
            ]),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(title,
              style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
          ),
          child: Column(children: tiles),
        ),
      ],
    );
  }

  Widget _buildSettingTile(IconData icon, String title, String subtitle, {bool isPlaceholder = false}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isPlaceholder
              ? Colors.grey.withOpacity(0.1)
              : const Color(0xFF1B5E20).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isPlaceholder ? Colors.grey : const Color(0xFF1B5E20), size: 20),
      ),
      title: Text(title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isPlaceholder ? Colors.grey : Colors.black87,
          )),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Icon(Icons.chevron_right, color: isPlaceholder ? Colors.grey[300] : Colors.grey),
      onTap: isPlaceholder ? null : () {},
    );
  }
}
