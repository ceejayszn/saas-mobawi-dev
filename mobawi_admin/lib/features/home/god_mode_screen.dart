import 'package:flutter/material.dart';
import '../../core/theme/nexus_theme.dart';
import '../../core/widgets/common/nexus_card.dart';
import '../../core/services/nexus_api.dart';
import '../../core/widgets/common/empty_state.dart';
import '../../core/widgets/common/kpi_card.dart';

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

    final textSecondary = isDark ? NexusTheme.textSecondary : NexusTheme.lightTextSecondary;
    final borderSideColor = isDark ? NexusTheme.border : NexusTheme.lightBorder;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CEO GOD MODE', style: theme.textTheme.displayLarge),
                  const SizedBox(height: 4),
                  Text('Unified operating command dashboard for Mobawi Inc.', style: theme.textTheme.bodyMedium),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _loadOverview(),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Sync Operations'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.cardColor,
                  foregroundColor: theme.primaryColor,
                  side: BorderSide(color: borderSideColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // 4 Grid KPI Cards
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
            shrinkWrap: true,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 1.6,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              KpiCard(
                title: 'Revenue (M-Pesa)',
                value: 'KES ${_overview['revenue'] ?? '0.00'}',
                subtitle: 'vs last week',
                icon: Icons.payments_outlined,
                iconColor: theme.primaryColor,
                trend: '+12.4%',
                isTrendPositive: true,
                onTap: () => widget.onNavigate('billing'),
              ),
              KpiCard(
                title: 'Total Active Customers',
                value: '${_overview['customers_count'] ?? 0}',
                subtitle: 'Active workspaces',
                icon: Icons.business_outlined,
                iconColor: NexusTheme.accent,
                onTap: () => widget.onNavigate('customers'),
              ),
              KpiCard(
                title: 'Platform Uptime',
                value: '${_overview['uptime'] ?? '0.00'}%',
                subtitle: 'Railway + Cloudflare health',
                icon: Icons.speed_outlined,
                iconColor: NexusTheme.success,
                onTap: () => widget.onNavigate('command_center'),
              ),
              KpiCard(
                title: 'AI Execution Engine',
                value: '${_overview['ai_requests'] ?? 0} reqs',
                subtitle: 'Google AI quota utilized',
                icon: Icons.psychology_outlined,
                iconColor: NexusTheme.info,
                onTap: () => widget.onNavigate('ai_center'),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Two Column Widgets
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: NexusCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Active Service Infrastructure Status', style: theme.textTheme.headlineMedium),
                          const Icon(Icons.circle, color: NexusTheme.success, size: 10),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildServiceStatusRow(context, 'Railway Backend API', 'Operational', '99.998% Uptime', NexusTheme.success),
                      _buildServiceStatusRow(context, 'PostgreSQL Core DB', 'Healthy', '12ms Latency', NexusTheme.success),
                      _buildServiceStatusRow(context, 'Cloudflare DNS Edge', 'Online', 'Fastest Propagation', NexusTheme.success),
                      _buildServiceStatusRow(context, 'Google Gemini AI Adapter', 'Connected', 'Google Cloud Platform', NexusTheme.success),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 2,
                child: NexusCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('System Tasks & Actions', style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 24),
                      _buildQuickAction(context, 'Deploy Latest Release', Icons.rocket_launch_outlined, () => widget.onNavigate('deployments'), textSecondary),
                      _buildQuickAction(context, 'Review Incident Logs', Icons.terminal_outlined, () => widget.onNavigate('command_center'), textSecondary),
                      _buildQuickAction(context, 'Manage Customer Accounts', Icons.business_outlined, () => widget.onNavigate('customers'), textSecondary),
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

  Widget _buildServiceStatusRow(BuildContext context, String name, String status, String metric, Color color) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(Icons.fiber_manual_record, color: color, size: 12),
          const SizedBox(width: 16),
          Expanded(child: Text(name, style: theme.textTheme.titleLarge?.copyWith(fontSize: 14))),
          Text(metric, style: theme.textTheme.labelLarge),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
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
