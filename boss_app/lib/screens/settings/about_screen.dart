import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/constants/app_constants.dart';
import '../../theme/app_colors.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = AppConstants.appVersion;
  String _buildNumber = AppConstants.appBuildNumber;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _version = info.version;
          _buildNumber = info.buildNumber;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: const Text('About'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // App identity
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12)],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: AppColors.primaryGreen.withValues(alpha: 0.2), blurRadius: 16)],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset('assets/images/logo.png', fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(Icons.hotel, color: AppColors.primaryGreen, size: 48)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(AppConstants.appName,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryGreen)),
                  const SizedBox(height: 4),
                  const Text(AppConstants.appSubtitle,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _infoBadge('v$_version', AppColors.success),
                      const SizedBox(width: 8),
                      _infoBadge('Build $_buildNumber', AppColors.info),
                      const SizedBox(width: 8),
                      _infoBadge('Updated ${AppConstants.lastUpdated}', AppColors.orange),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Version info
            _buildGroup('Version Information', isDark, [
              _InfoRow('App Version', _version),
              _InfoRow('Build Number', _buildNumber),
              _InfoRow('Last Updated', AppConstants.lastUpdated),
              _InfoRow('Developer', AppConstants.developerName),
            ]),
            const SizedBox(height: 12),

            // Legal documents
            _buildSection('Legal', isDark, [
              _LegalTile(title: 'Privacy Policy', icon: Icons.privacy_tip_rounded,
                  content: AppConstants.privacyPolicy, isDark: isDark),
              const Divider(height: 1, indent: 60),
              _LegalTile(title: 'Terms & Conditions', icon: Icons.gavel_rounded,
                  content: AppConstants.termsAndConditions, isDark: isDark),
              const Divider(height: 1, indent: 60),
              _LegalTile(title: 'Open Source Licenses', icon: Icons.code_rounded,
                  content: AppConstants.licenses, isDark: isDark),
              const Divider(height: 1, indent: 60),
              _LegalTile(title: 'FAQ', icon: Icons.help_rounded,
                  content: AppConstants.faq, isDark: isDark),
            ]),
            const SizedBox(height: 24),

            Text(
              '© ${DateTime.now().year} ${AppConstants.developerName}. All rights reserved.',
              style: const TextStyle(color: AppColors.textHint, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _infoBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildGroup(String title, bool isDark, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title.toUpperCase(),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 1.2)),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
          ),
          child: Column(
            children: rows.asMap().entries.map((e) => Column(children: [
              e.value,
              if (e.key < rows.length - 1) const Divider(height: 1, indent: 16, endIndent: 16),
            ])).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, bool isDark, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title.toUpperCase(),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 1.2)),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}

class _LegalTile extends StatelessWidget {
  final String title, content;
  final IconData icon;
  final bool isDark;

  const _LegalTile({required this.title, required this.content, required this.icon, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primaryGreen, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _LegalDocument(title: title, content: content, isDark: isDark),
        );
      },
    );
  }
}

class _LegalDocument extends StatelessWidget {
  final String title, content;
  final bool isDark;

  const _LegalDocument({required this.title, required this.content, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.dividerLight, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Text(content, style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.textSecondary)),
            ),
          ),
        ],
      ),
    );
  }
}
