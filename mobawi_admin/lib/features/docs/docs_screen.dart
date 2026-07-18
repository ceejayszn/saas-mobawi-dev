import 'package:flutter/material.dart';
import '../../core/theme/nexus_theme.dart';

class DocsScreen extends StatelessWidget {
  final Function(String) onNavigate;

  const DocsScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = isDark ? NexusTheme.textPrimary : NexusTheme.lightTextPrimary;
    final textSecondary = isDark ? NexusTheme.textSecondary : NexusTheme.lightTextSecondary;

    return DefaultTabController(
      length: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Platform Documentation', style: TextStyle(color: textPrimary, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Comprehensive logs, database additions, prompt history, and licensing documentation.', style: TextStyle(color: textSecondary, fontSize: 14)),
                const SizedBox(height: 32),
                TabBar(
                  indicatorColor: theme.primaryColor,
                  labelColor: theme.primaryColor,
                  unselectedLabelColor: textSecondary,
                  tabs: const [
                    Tab(text: 'Architecture & DB Schemas'),
                    Tab(text: 'Prompt History & Logs'),
                    Tab(text: 'License Models'),
                    Tab(text: 'API Contracts'),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: TabBarView(
              children: [
                _buildScrollableDocContent(
                  title: 'PostgreSQL Database Schemas',
                  content: '''
### Business Table
- id: UUID (Primary Key)
- name: String
- subscription_status: String
- created_at: Timestamp

### Sale (Orders)
- id: UUID
- amount: Float
- status: String (COMPLETED, PENDING, CANCELLED)
- payment_method: String (M-PESA, CASH, CARD)
- type: String (In-Store, Delivery)
- business_id: UUID (Foreign Key)

### Products (Menu Items)
- id: UUID
- name: String
- price: Float
- stock: Int
- business_id: UUID (Foreign Key)
''',
                ),
                _buildScrollableDocContent(
                  title: 'Development Prompt History',
                  content: '''
[2026-07-18 10:00:00] Initialized God Mode dashboard creation.
[2026-07-18 11:30:00] Separated offline capabilities via local_sale_repository.dart
[2026-07-18 14:15:00] Requested UI overhaul: Deep space dark mode and neon blue.
[2026-07-18 18:00:00] Extracted mobawi_core into a shared package to fix sync issues.
[2026-07-18 20:00:00] Requested major dashboard expansion: Support tickets, Licensing generator, Affiliates, Analysis logs.

System Log: All changes successfully compiled and pushed to 'platform' branch.
''',
                ),
                _buildScrollableDocContent(
                  title: 'Licensing Models',
                  content: '''
### Architecture
Licenses are generated using a combination of the App ID, a timestamp, and the duration.
The generated hash is validated completely offline by the client applications via local cryptography.

### Tiers
- 1 Day Trial
- 48 Hours Extension
- 2 Weeks Demo
- 1 Year Full License
- Custom (e.g., Lifetime, or specific hour count)

Licenses are bound to the Device ID upon first entry to prevent sharing.
''',
                ),
                _buildScrollableDocContent(
                  title: 'API Contracts (Nexus Engine)',
                  content: '''
Base URL: https://mobawi-backend.onrender.com/api/v1/

### GET /sync/push
Uploads offline transactions from local SQLite to Postgres.
Requires: Bearer Token, Business ID.

### GET /sync/pull
Downloads latest products and settings from Postgres to local cache.

### POST /admin/login
Authenticates founder via static credentials.
Returns: JWT Token.
''',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableDocContent({required String title, required String content}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: NexusTheme.border),
            ),
            child: Text(
              content,
              style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 13, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}
