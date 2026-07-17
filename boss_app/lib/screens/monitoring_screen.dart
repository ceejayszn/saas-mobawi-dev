import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _mockLogs = [
    {'time': 'Just now', 'user': 'sarah_c', 'action': 'Member Registration', 'desc': 'Registered John Doe (MEM-101)', 'amount': 30.00, 'type': 'info'},
    {'time': '10m ago', 'user': 'sarah_c', 'action': 'Check In', 'desc': 'Checked in John Doe (MEM-101)', 'amount': null, 'type': 'success'},
    {'time': '1h ago', 'user': 'coach_carter', 'action': 'Equipment Service', 'desc': 'Logged fault on Treadmill #4', 'amount': null, 'type': 'warning'},
    {'time': '3h ago', 'user': 'admin', 'action': 'Refund Processed', 'desc': 'Processed refund for Bob Johnson (MEM-303)', 'amount': -50.00, 'type': 'error'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredLogs = _mockLogs.where((log) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return log['desc'].toString().toLowerCase().contains(q) ||
               log['user'].toString().toLowerCase().contains(q) ||
               log['action'].toString().toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: const Text('Live Audit & Monitoring'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search gym audits...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: isDark ? AppColors.darkCard : Colors.white,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredLogs.length,
              itemBuilder: (context, index) {
                final log = filteredLogs[index];
                Color severityColor = Colors.blue;
                if (log['type'] == 'success') severityColor = Colors.green;
                if (log['type'] == 'warning') severityColor = Colors.orange;
                if (log['type'] == 'error') severityColor = Colors.red;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      width: 4,
                      height: 40,
                      color: severityColor,
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(log['action'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(log['time'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(log['desc']),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.person, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('By: ${log['user']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        )
                      ],
                    ),
                    trailing: log['amount'] != null
                        ? Text(
                            '\$${log['amount']!.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: log['amount'] > 0 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          )
                        : null,
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
