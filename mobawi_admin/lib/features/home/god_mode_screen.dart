import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/nexus_theme.dart';
import '../../core/widgets/common/nexus_card.dart';
import '../../core/services/nexus_api.dart';
import '../../core/widgets/common/empty_state.dart';
import '../../core/widgets/common/kpi_card.dart';
import '../../core/widgets/common/crm_kpi_card.dart';

class GodModeScreen extends StatefulWidget {
  final Function(String) onNavigate;

  const GodModeScreen({super.key, required this.onNavigate});

  @override
  State<GodModeScreen> createState() => _GodModeScreenState();
}

class _GodModeScreenState extends State<GodModeScreen> {
  final NexusApi _api = NexusApi();
  bool _isLoading = true;
  Map<String, dynamic> _overview = {};

  @override
  void initState() {
    super.initState();
    _loadOverview();
  }

  Future<void> _loadOverview() async {
    final data = await _api.fetchFounderOverview();
    if (mounted) {
      setState(() {
        _overview = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textPrimary = isDark ? NexusTheme.textPrimary : NexusTheme.lightTextPrimary;
    final textSecondary = isDark ? NexusTheme.textSecondary : NexusTheme.lightTextSecondary;

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: theme.primaryColor));
    }

    if (_overview.isEmpty) {
      return NexusEmptyState(
        title: 'Founder Nexus Offline',
        description: 'Unable to load real operational overview metrics. Ensure PostgreSQL is connected.',
        icon: Icons.cloud_off_outlined,
        actionLabel: 'Check Health Center',
        onAction: () => widget.onNavigate('command_center'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Greeting Header ───────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Arafat Nayeem (CEO)',
                    style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Welcome back to Mobawi Nexus 👋',
                    style: TextStyle(color: textSecondary, fontSize: 12),
                  ),
                ],
              ),
              CircleAvatar(
                backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                radius: 18,
                child: Icon(Icons.shield_outlined, color: theme.primaryColor, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

          // ── Dashboard Title Row ──────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dashboard',
                style: theme.textTheme.displayMedium?.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => widget.onNavigate('settings'),
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: const Text('Create workspace', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── 4 KPI Grid Cards ──────────────────────
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
            shrinkWrap: true,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.65,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              CrmKpiCard(
                title: 'Total Revenue (M-Pesa)',
                value: 'KES ${_overview['revenue'] ?? '0.00'}',
                trend: '+12.4% from yesterday',
                icon: Icons.bar_chart_rounded,
                baseColor: const Color(0xFFF97316), // Orange
                onTap: () => widget.onNavigate('billing'),
              ),
              CrmKpiCard(
                title: 'Platform Uptime',
                value: '${_overview['uptime'] ?? '0.00'}%',
                trend: '+0% from yesterday',
                icon: Icons.article_outlined,
                baseColor: const Color(0xFFEAB308), // Yellow
                onTap: () => widget.onNavigate('command_center'),
              ),
              CrmKpiCard(
                title: 'AI Executions',
                value: '${_overview['ai_requests'] ?? 0}',
                trend: '+5.2% from yesterday',
                icon: Icons.local_offer_outlined,
                baseColor: const Color(0xFF10B981), // Green
                onTap: () => widget.onNavigate('ai_center'),
              ),
              CrmKpiCard(
                title: 'Active Customers',
                value: '${_overview['customers_count'] ?? 0}',
                trend: '+1.5% from yesterday',
                icon: Icons.person_outline,
                baseColor: const Color(0xFF0EA5E9), // Cyan/Blue
                onTap: () => widget.onNavigate('customers'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Double Charts Row (Fillio layout style) ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: NexusCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('New Workspaces Onboarded', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          TextButton(onPressed: () {}, child: const Text('7D', style: TextStyle(fontSize: 11))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 180,
                        child: LineChart(
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
                                spots: const [
                                  FlSpot(0, 1),
                                  FlSpot(1, 1.5),
                                  FlSpot(2, 1.2),
                                  FlSpot(3, 2.2),
                                  FlSpot(4, 2.0),
                                  FlSpot(5, 3.1),
                                  FlSpot(6, 4.0),
                                ],
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
              const SizedBox(width: 20),
              Expanded(
                child: NexusCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('API Traffic Load', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          TextButton(onPressed: () {}, child: const Text('7D', style: TextStyle(fontSize: 11))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 180,
                        child: LineChart(
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
                                spots: const [
                                  FlSpot(0, 10),
                                  FlSpot(1, 18),
                                  FlSpot(2, 15),
                                  FlSpot(3, 28),
                                  FlSpot(4, 22),
                                  FlSpot(5, 34),
                                  FlSpot(6, 32),
                                ],
                                isCurved: true,
                                color: NexusTheme.accentSecondary,
                                barWidth: 3,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: NexusTheme.accentSecondary.withValues(alpha: 0.1),
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
            ],
          ),
          const SizedBox(height: 24),

          // ── Two Column Bottom Content: Workspaces & Actions ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: NexusCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('System Tasks & Active Workspaces', style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 16),
                      // Workspace Table structure
                      _buildWorkspaceItem('Natty Gym POS', 'ACTIVE', 'HOTEL / SPORTS', 'Priority HIGH'),
                      _buildWorkspaceItem('Dionamax Pharmacy', 'ACTIVE', 'HEALTHCARE', 'Priority HIGH'),
                      _buildWorkspaceItem('Rongai Quick POS', 'SUSPENDED', 'RETAIL', 'Priority LOW'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: NexusCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SaaS Commands', style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 16),
                      _buildQuickAction(context, 'Deploy Latest Build', Icons.rocket_launch_outlined, () => widget.onNavigate('deployments'), textSecondary),
                      _buildQuickAction(context, 'Security Log Center', Icons.shield_outlined, () => widget.onNavigate('security'), textSecondary),
                      _buildQuickAction(context, 'Environment Settings', Icons.settings_outlined, () => widget.onNavigate('settings'), textSecondary),
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

  Widget _buildWorkspaceItem(String name, String status, String type, String priority) {
    final isActive = status == 'ACTIVE';
    final statusColor = isActive ? NexusTheme.success : NexusTheme.warning;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: statusColor.withValues(alpha: 0.1),
            radius: 16,
            child: Icon(Icons.business_outlined, color: statusColor, size: 14),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text('$type · $priority', style: const TextStyle(color: NexusTheme.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              status,
              style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String title, IconData icon, VoidCallback onTap, Color textSecondary) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: theme.primaryColor),
        title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        trailing: Icon(Icons.arrow_forward_ios, size: 12, color: textSecondary),
      ),
    );
  }
}
