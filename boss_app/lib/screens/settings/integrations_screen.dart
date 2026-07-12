import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class IntegrationsScreen extends StatelessWidget {
  const IntegrationsScreen({super.key});

  static const List<_Integration> _integrations = [
    _Integration('Payment Gateway', Icons.payment_rounded, 'Accept card payments directly in-app', AppColors.info),
    _Integration('M-Pesa Integration', Icons.phone_android_rounded, 'Real-time M-Pesa payment processing', AppColors.success),
    _Integration('Stripe Payments', Icons.credit_card_rounded, 'International card payment processing', AppColors.purple),
    _Integration('Accounting Software', Icons.calculate_rounded, 'Sync with QuickBooks or similar', AppColors.orange),
    _Integration('Customer Loyalty', Icons.card_giftcard_rounded, 'Points, rewards and loyalty programs', AppColors.pink),
    _Integration('QR Code Ordering', Icons.qr_code_rounded, 'Customers scan QR to place orders', AppColors.teal),
    _Integration('Kitchen Display (KDS)', Icons.kitchen_rounded, 'Live kitchen order display system', AppColors.warning),
    _Integration('Staff Attendance', Icons.fingerprint_rounded, 'Biometric attendance tracking', AppColors.info),
    _Integration('AI Sales Insights', Icons.auto_graph_rounded, 'AI-powered sales predictions', AppColors.purple),
    _Integration('AI Inventory Forecast', Icons.inventory_2_rounded, 'Smart restocking predictions', AppColors.teal),
    _Integration('Multi-Branch', Icons.store_mall_directory_rounded, 'Manage multiple hotel branches', AppColors.orange),
    _Integration('Cloud Backup', Icons.cloud_upload_rounded, 'Automatic encrypted cloud backup', AppColors.info),
    _Integration('Google Drive Backup', Icons.backup_rounded, 'Backup to your Google Drive', AppColors.success),
    _Integration('SMS Notifications', Icons.sms_rounded, 'Send SMS alerts to customers & staff', AppColors.warning),
    _Integration('Email Reports', Icons.email_rounded, 'Automated email report delivery', AppColors.error),
    _Integration('Multi-Language', Icons.translate_rounded, 'Support for multiple languages', AppColors.purple),
    _Integration('API Integration', Icons.api_rounded, 'Connect to external systems via API', AppColors.teal),
    _Integration('POS Hardware', Icons.receipt_rounded, 'Thermal printer & cash drawer support', AppColors.orange),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: const Text('Future Integrations'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Coming Soon', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                        SizedBox(height: 4),
                        Text(
                          'These powerful integrations are being developed and will be available in future updates.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${_integrations.length} UPCOMING FEATURES',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _integrations.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final item = _integrations[index];
                return _IntegrationCard(item: item, isDark: isDark);
              },
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
              ),
              child: const Column(
                children: [
                  Icon(Icons.email_rounded, color: AppColors.primaryGreen, size: 28),
                  SizedBox(height: 8),
                  Text('Request a Feature', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  SizedBox(height: 4),
                  Text(
                    'Have a feature in mind? Contact MOBAWI LLC to discuss custom integrations for your hotel.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
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

class _IntegrationCard extends StatelessWidget {
  final _Integration item;
  final bool isDark;

  const _IntegrationCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerLight.withValues(alpha: isDark ? 0.2 : 1)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: item.color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Soon',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            item.title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.description,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _Integration {
  final String title, description;
  final IconData icon;
  final Color color;
  const _Integration(this.title, this.icon, this.description, this.color);
}
