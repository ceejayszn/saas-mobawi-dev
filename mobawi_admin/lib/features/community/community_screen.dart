import 'package:flutter/material.dart';
import '../../core/theme/nexus_theme.dart';
import '../../core/widgets/common/nexus_card.dart';

class CommunityScreen extends StatelessWidget {
  final Function(String) onNavigate;

  const CommunityScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = isDark ? NexusTheme.textPrimary : NexusTheme.lightTextPrimary;
    final textSecondary = isDark ? NexusTheme.textSecondary : NexusTheme.lightTextSecondary;

    final affiliates = [
      {'company': 'Mobawi Retail', 'contact': 'retail@mobawi.com', 'tier': 'Platinum', 'apps': 4, 'status': 'Active'},
      {'company': 'Felixpinski Group', 'contact': 'admin@felixpinski.com', 'tier': 'Gold', 'apps': 1, 'status': 'Active'},
      {'company': 'Natty Gym HQ', 'contact': 'management@natty.fit', 'tier': 'Silver', 'apps': 1, 'status': 'Active'},
      {'company': 'Delights Corp', 'contact': 'hello@delights.co', 'tier': 'Bronze', 'apps': 1, 'status': 'Inactive'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Community & Affiliates',
            style: TextStyle(color: textPrimary, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your affiliated companies, app deployments, and client relationships.',
            style: TextStyle(color: textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 32),
          
          NexusCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Affiliated Companies', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: affiliates.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final comp = affiliates[index];
                    final isActive = comp['status'] == 'Active';
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                            child: Icon(Icons.corporate_fare_outlined, color: theme.primaryColor),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(comp['company'] as String, style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                                Text(comp['contact'] as String, style: TextStyle(color: textSecondary, fontSize: 12)),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Partner Tier', style: TextStyle(color: textSecondary, fontSize: 10)),
                                Text(comp['tier'] as String, style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Apps', style: TextStyle(color: textSecondary, fontSize: 10)),
                                Text('${comp['apps']}', style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isActive ? NexusTheme.success.withValues(alpha: 0.1) : NexusTheme.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isActive ? NexusTheme.success.withValues(alpha: 0.3) : NexusTheme.error.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              comp['status'] as String,
                              style: TextStyle(
                                color: isActive ? NexusTheme.success : NexusTheme.error,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.more_vert),
                            color: textSecondary,
                            onPressed: () {},
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
