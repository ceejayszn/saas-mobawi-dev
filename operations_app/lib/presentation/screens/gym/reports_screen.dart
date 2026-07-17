import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  void _exportFormat(BuildContext context, String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully exported report as $format!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Exports')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gym Performance Reports', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildReportCategoryCard(
              context,
              title: 'Revenue & Financials',
              description: 'Summary of all membership fees, product POS sales, and outstanding balances.',
              icon: Icons.attach_money,
            ),
            const SizedBox(height: 16),
            _buildReportCategoryCard(
              context,
              title: 'Attendance Analytics',
              description: 'Daily check-in logs, average occupancy, peak hours, and trainer sessions.',
              icon: Icons.people_outline,
            ),
            const SizedBox(height: 16),
            _buildReportCategoryCard(
              context,
              title: 'Membership & Renewal Rate',
              description: 'Active vs suspended users, churn logs, package performance, and frozen accounts.',
              icon: Icons.card_membership,
            ),
            const SizedBox(height: 16),
            _buildReportCategoryCard(
              context,
              title: 'Staff Performance & Log',
              description: 'Logs of who registered members, processed check-ins, and took payments.',
              icon: Icons.badge_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCategoryCard(BuildContext context, {required String title, required String description, required IconData icon}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 32, color: Colors.blue),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _exportFormat(context, 'PDF'),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Export PDF'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _exportFormat(context, 'Excel'),
                  icon: const Icon(Icons.table_view),
                  label: const Text('Excel'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _exportFormat(context, 'CSV'),
                  icon: const Icon(Icons.analytics),
                  label: const Text('CSV'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
