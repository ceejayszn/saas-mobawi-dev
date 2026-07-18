import 'package:flutter/material.dart';
import '../../core/theme/nexus_theme.dart';
import '../../core/widgets/common/nexus_card.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalysisScreen extends StatelessWidget {
  final Function(String) onNavigate;

  const AnalysisScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = isDark ? NexusTheme.textPrimary : NexusTheme.lightTextPrimary;
    final textSecondary = isDark ? NexusTheme.textSecondary : NexusTheme.lightTextSecondary;

    final logs = [
      {'time': '10:42 AM', 'event': 'IP Change Detected', 'details': '192.168.1.44 -> 10.0.0.5', 'severity': 'Medium'},
      {'time': '09:15 AM', 'event': 'Suspicious Login Attempt', 'details': 'Failed brute force from RU', 'severity': 'High'},
      {'time': '08:30 AM', 'event': 'Device Power Cycle', 'details': 'POS Terminal 4 rebooted', 'severity': 'Low'},
      {'time': '02:00 AM', 'event': 'Database Backup', 'details': 'Automated Postgres dump successful', 'severity': 'Low'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Security & Analysis',
            style: TextStyle(color: textPrimary, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Monitor traffic, hacks, IP changes, and device power states.',
            style: TextStyle(color: textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 32),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: NexusCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Live Traffic Analysis', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: const [
                                  FlSpot(0, 1), FlSpot(1, 3), FlSpot(2, 2), FlSpot(3, 5), FlSpot(4, 3.5), FlSpot(5, 6),
                                ],
                                isCurved: true,
                                color: NexusTheme.accent,
                                barWidth: 3,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: NexusTheme.accent.withValues(alpha: 0.2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 3,
                child: NexusCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('System Event Logs', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: logs.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final log = logs[index];
                          final isHigh = log['severity'] == 'High';
                          final isMed = log['severity'] == 'Medium';
                          final color = isHigh ? NexusTheme.error : (isMed ? NexusTheme.warning : NexusTheme.success);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Text(log['time']!, style: TextStyle(color: textSecondary, fontSize: 12)),
                                const SizedBox(width: 16),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(log['event']!, style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                                      Text(log['details']!, style: TextStyle(color: textSecondary, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
