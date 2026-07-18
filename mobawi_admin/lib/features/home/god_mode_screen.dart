import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/nexus_theme.dart';
import '../../core/widgets/common/nexus_card.dart';
import '../../core/services/nexus_api.dart';
import '../../core/widgets/common/empty_state.dart';

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
  List<dynamic> _applications = [];

  @override
  void initState() {
    super.initState();
    _loadOverview();
  }

  Future<void> _loadOverview() async {
    final futures = await Future.wait([
      _api.fetchFounderOverview(),
      _api.fetchApplications(),
    ]);

    if (mounted) {
      setState(() {
        _overview = futures[0] as Map<String, dynamic>;
        _applications = futures[1] as List<dynamic>;
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
          // ── Greeting Header (Stovest style) ───────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, Arafat',
                style: TextStyle(color: textPrimary, fontSize: 28, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                "Here's your SaaS platform overview",
                style: TextStyle(color: textSecondary, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ── Top Row: Revenue & Quick Portfolio ──────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Holding Card
              Expanded(
                flex: 2,
                child: NexusCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Revenue', style: TextStyle(color: textSecondary, fontSize: 14)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: theme.dividerColor),
                            ),
                            child: Row(
                              children: [
                                Text('6M', style: TextStyle(color: textPrimary, fontSize: 12)),
                                const SizedBox(width: 4),
                                Icon(Icons.keyboard_arrow_down, size: 14, color: textSecondary),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'KES ${_overview['revenue'] ?? '0.00'}',
                        style: TextStyle(color: textPrimary, fontSize: 36, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Return', style: TextStyle(color: NexusTheme.textMuted, fontSize: 13)),
                          const SizedBox(width: 8),
                          Text(
                            '+3.6% (\$ 532)',
                            style: TextStyle(color: NexusTheme.success, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // My Portfolio (Active Workspaces)
              Expanded(
                flex: 3,
                child: NexusCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Active Workspaces', style: TextStyle(color: textSecondary, fontSize: 14)),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () => widget.onNavigate('customers'),
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(color: theme.dividerColor),
                                  ),
                                ),
                                child: Text('See all', style: TextStyle(color: textPrimary, fontSize: 12)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Horizontal scroll of workspaces
                      SizedBox(
                        height: 110,
                        child: _applications.isEmpty
                            ? Center(child: Text('No active workspaces', style: TextStyle(color: textSecondary)))
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _applications.length > 4 ? 4 : _applications.length,
                                itemBuilder: (context, index) {
                                  final app = _applications[index];
                                  return _buildMiniPortfolioCard(
                                    app['name']?.toString() ?? 'App',
                                    app['onlineStatus'] == 'ACTIVE' ? 'ONLINE' : 'LOCKED',
                                    app['platform']?.toString() ?? 'System',
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Main Chart (Portfolio Performance) ──────────────────
          NexusCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Platform Performance', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                    Row(
                      children: ['1D', '1W', '1M', '6M', '1Y'].map((label) {
                        final isSelected = label == '6M';
                        return Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? theme.primaryColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? theme.primaryColor : theme.dividerColor),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: isSelected ? Colors.white : textSecondary,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 240,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(color: theme.dividerColor, strokeWidth: 1),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()}k',
                              style: TextStyle(color: textSecondary, fontSize: 10),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
                              if (value >= 0 && value < months.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(months[value.toInt()], style: TextStyle(color: textSecondary, fontSize: 10)),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 10), FlSpot(1, 15), FlSpot(2, 13), FlSpot(3, 24), FlSpot(4, 20), FlSpot(5, 30), FlSpot(6, 35),
                          ],
                          isCurved: true,
                          color: theme.primaryColor,
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                theme.primaryColor.withValues(alpha: 0.3),
                                theme.primaryColor.withValues(alpha: 0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Bottom Table (Workspaces Overview) ──────────────────
          NexusCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Workspaces Overview', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                    Row(
                      children: ['All', 'Active', 'Suspended'].map((label) {
                        final isSelected = label == 'All';
                        return Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? theme.primaryColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? theme.primaryColor : theme.dividerColor),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: isSelected ? Colors.white : textSecondary,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_applications.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(child: Text('No active workspaces found.', style: TextStyle(color: textSecondary))),
                  )
                else
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Row(
                          children: [
                            Expanded(flex: 3, child: Text('Workspace', style: TextStyle(color: textSecondary, fontSize: 12))),
                            Expanded(flex: 2, child: Text('Status', style: TextStyle(color: textSecondary, fontSize: 12))),
                            Expanded(flex: 2, child: Text('Type', style: TextStyle(color: textSecondary, fontSize: 12))),
                            Expanded(flex: 2, child: Text('Version', style: TextStyle(color: textSecondary, fontSize: 12))),
                          ],
                        ),
                      ),
                      const Divider(),
                      ..._applications.map((app) => _buildWorkspaceTableRow(
                            app['name']?.toString() ?? 'Unknown App',
                            app['onlineStatus']?.toString() ?? 'OFFLINE',
                            app['platform']?.toString() ?? 'SYSTEM',
                            'v${app['version'] ?? '1.0'}',
                          )),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPortfolioCard(String name, String status, String type) {
    final theme = Theme.of(context);
    final isOnline = status == 'ONLINE';
    final statusColor = isOnline ? NexusTheme.success : NexusTheme.error;

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
              Icon(Icons.business_outlined, color: NexusTheme.textMuted, size: 16),
            ],
          ),
          const Spacer(),
          Text(name, style: TextStyle(color: NexusTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(type, style: TextStyle(color: NexusTheme.textMuted, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildWorkspaceTableRow(String name, String status, String type, String version) {
    final isActive = status == 'ACTIVE';
    final statusColor = isActive ? NexusTheme.success : NexusTheme.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor.withValues(alpha: 0.1),
                  radius: 12,
                  child: Icon(Icons.circle, color: statusColor, size: 10),
                ),
                const SizedBox(width: 12),
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              status,
              style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(type, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
          Expanded(
            flex: 2,
            child: Text(version, style: TextStyle(color: NexusTheme.textSecondary, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
