import 'package:flutter/material.dart';
import '../../core/theme/nexus_theme.dart';
import '../../core/widgets/common/nexus_card.dart';

class PortfolioScreen extends StatelessWidget {
  final Function(String) onNavigate;

  const PortfolioScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = isDark ? NexusTheme.textPrimary : NexusTheme.lightTextPrimary;
    final textSecondary = isDark ? NexusTheme.textSecondary : NexusTheme.lightTextSecondary;

    // Dummy data for portfolio apps
    final apps = [
      {
        'name': 'Natty Gym',
        'client': 'Arafat',
        'status': 'Complete',
        'price': '\$ 4,500',
        'type': 'Fitness Management',
        'color': Colors.orangeAccent,
      },
      {
        'name': 'Delights Juice Shop',
        'client': 'Delights',
        'status': 'Complete',
        'price': '\$ 2,200',
        'type': 'Point of Sale',
        'color': Colors.greenAccent,
      },
      {
        'name': 'Felixpinski Hotel',
        'client': 'Felix',
        'status': 'Incomplete',
        'price': '\$ 8,000',
        'type': 'Hotel Management',
        'color': Colors.blueAccent,
      },
      {
        'name': 'Stovest',
        'client': 'Internal',
        'status': 'Complete',
        'price': 'N/A',
        'type': 'Fintech UI',
        'color': Colors.purpleAccent,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portfolio & Clients',
            style: TextStyle(color: textPrimary, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Overview of all manufactured applications and client projects.',
            style: TextStyle(color: textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 32),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 350,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.2,
            ),
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              final isComplete = app['status'] == 'Complete';
              final statusColor = isComplete ? NexusTheme.success : NexusTheme.warning;

              return NexusCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundColor: (app['color'] as Color).withValues(alpha: 0.2),
                          child: Icon(Icons.apps_outlined, color: app['color'] as Color),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            app['status'] as String,
                            style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      app['name'] as String,
                      style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      app['type'] as String,
                      style: TextStyle(color: textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Client', style: TextStyle(color: textSecondary, fontSize: 10)),
                            const SizedBox(height: 2),
                            Text(app['client'] as String, style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Value', style: TextStyle(color: textSecondary, fontSize: 10)),
                            const SizedBox(height: 2),
                            Text(app['price'] as String, style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
