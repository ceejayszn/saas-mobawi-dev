import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/nexus_theme.dart';
import '../../core/widgets/common/nexus_card.dart';
import '../../core/services/nexus_api.dart';
import '../../core/widgets/common/empty_state.dart';
import '../../core/widgets/common/kpi_card.dart';

class AiCenterScreen extends StatefulWidget {
  final Function(String) onNavigate;

  const AiCenterScreen({super.key, required this.onNavigate});

  @override
  State<AiCenterScreen> createState() => _AiCenterScreenState();
}

class _AiCenterScreenState extends State<AiCenterScreen> {
  final NexusApi _api = NexusApi();
  bool _isLoading = true;
  Map<String, dynamic> _aiData = {};

  @override
  void initState() {
    super.initState();
    _loadAiData();
  }

  Future<void> _loadAiData() async {
    final data = await _api.fetchAiCenterOverview();
    if (mounted) {
      setState(() {
        _aiData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? NexusTheme.border : NexusTheme.lightBorder;

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: theme.primaryColor));
    }

    if (_aiData.isEmpty) {
      return NexusEmptyState(
        title: 'AI Logs & Analytics Offline',
        description: 'Google AI token cost logs and prompt performance analytics tables are disconnected.',
        icon: Icons.psychology_outlined,
        actionLabel: 'Link Gemini Edge Adapter',
        onAction: _loadAiData,
      );
    }

    final totalRequests = _aiData['total_ai_requests'] ?? 0;
    final totalCost = _aiData['total_cost_usd'] ?? 0.0;
    final averageResponseTime = _aiData['average_response_time_ms'] ?? 0.0;

    final distributions = _aiData['model_distribution'] as List<dynamic>? ?? [];
    final usageHistory = _aiData['usage_history'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('GOOGLE AI ENGINE ANALYTICS', style: theme.textTheme.displayLarge),
                  const SizedBox(height: 4),
                  Text('Token quota logs, execution costs, and model latency parameters.', style: theme.textTheme.bodyMedium),
                ],
              ),
              OutlinedButton.icon(
                onPressed: _loadAiData,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Sync Tokens'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.primaryColor,
                  side: BorderSide(color: borderColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // KPI Cards
          Row(
            children: [
              Expanded(
                child: KpiCard(
                  title: 'Total Execution Requests',
                  value: '$totalRequests calls',
                  subtitle: 'Quota utilized this month',
                  icon: Icons.psychology_outlined,
                  iconColor: theme.primaryColor,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: KpiCard(
                  title: 'Token Service Cost',
                  value: '\$${(totalCost as num).toStringAsFixed(2)}',
                  subtitle: 'Google Cloud Platform cost',
                  icon: Icons.monetization_on_outlined,
                  iconColor: NexusTheme.success,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: KpiCard(
                  title: 'Average Token Latency',
                  value: '${(averageResponseTime as num).toStringAsFixed(0)} ms',
                  subtitle: 'Edge processing performance',
                  icon: Icons.timer_outlined,
                  iconColor: NexusTheme.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Graph Card
              Expanded(
                flex: 3,
                child: NexusCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI ENGINE CALL HISTORY', style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      const Text('Call frequency logs logged by Gemini adapter routing layers.', style: TextStyle(color: NexusTheme.textMuted, fontSize: 12)),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 260,
                        child: usageHistory.isEmpty
                            ? const Center(child: Text('No call trends history available.', style: TextStyle(color: NexusTheme.textMuted)))
                            : LineChart(
                                LineChartData(
                                  gridData: const FlGridData(show: false),
                                  titlesData: const FlTitlesData(
                                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: usageHistory.asMap().entries.map((e) {
                                        final reqs = (e.value['requests'] as num?)?.toDouble() ?? 0.0;
                                        return FlSpot(e.key.toDouble(), reqs);
                                      }).toList(),
                                      isCurved: true,
                                      color: theme.primaryColor,
                                      barWidth: 3,
                                      dotData: const FlDotData(show: true),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: theme.primaryColor.withValues(alpha: 0.1),
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
              const SizedBox(width: 24),

              // Breakdown Card
              Expanded(
                flex: 2,
                child: NexusCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Model Cost Distribution', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 8),
                      const Text('Calculated cost values based on model types.', style: TextStyle(color: NexusTheme.textMuted, fontSize: 12)),
                      const SizedBox(height: 24),
                      if (distributions.isEmpty)
                        const Text('No model distribution records found.', style: TextStyle(color: NexusTheme.textMuted))
                      else
                        ...distributions.map((dist) {
                          final model = dist['model'] ?? 'Gemini';
                          final calls = dist['calls'] ?? 0;
                          final cost = dist['cost'] ?? 0.0;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: [
                                Icon(Icons.circle_notifications_outlined, color: theme.primaryColor, size: 20),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(model, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      Text('$calls calls executed', style: const TextStyle(color: NexusTheme.textMuted, fontSize: 11)),
                                    ],
                                  ),
                                ),
                                Text(
                                  '\$${(cost as num).toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: NexusTheme.success),
                                ),
                              ],
                            ),
                          );
                        }),
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
