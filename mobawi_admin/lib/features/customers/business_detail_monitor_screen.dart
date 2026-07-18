import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/nexus_theme.dart';
import '../../core/widgets/common/nexus_card.dart';
import '../../core/services/nexus_api.dart';

class BusinessDetailMonitorScreen extends StatefulWidget {
  final Map<String, dynamic> business;
  final VoidCallback onBack;

  const BusinessDetailMonitorScreen({
    super.key,
    required this.business,
    required this.onBack,
  });

  @override
  State<BusinessDetailMonitorScreen> createState() => _BusinessDetailMonitorScreenState();
}

class _BusinessDetailMonitorScreenState extends State<BusinessDetailMonitorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NexusApi _api = NexusApi();

  bool _loadingStats = true;
  bool _loadingLogs = true;
  bool _loadingDevices = true;

  Map<String, dynamic> _stats = {};
  Map<String, dynamic> _logs = {};
  Map<String, dynamic> _devicesData = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    final businessId = widget.business['id'];
    if (businessId == null) return;

    setState(() {
      _loadingStats = true;
      _loadingLogs = true;
      _loadingDevices = true;
    });

    final stats = await _api.fetchBusinessStatistics(businessId);
    if (mounted) {
      setState(() {
        _stats = stats;
        _loadingStats = false;
      });
    }

    final logs = await _api.fetchBusinessLogs(businessId);
    if (mounted) {
      setState(() {
        _logs = logs;
        _loadingLogs = false;
      });
    }

    final devices = await _api.fetchBusinessDevices(businessId);
    if (mounted) {
      setState(() {
        _devicesData = devices;
        _loadingDevices = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final businessName = widget.business['name'] ?? 'Business';
    final businessType = widget.business['type'] ?? 'HOTEL';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: NexusTheme.textPrimary),
          onPressed: widget.onBack,
        ),
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  businessName.toUpperCase(),
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Entity Type: $businessType',
                  style: const TextStyle(color: NexusTheme.textMuted, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (widget.business['status'] == 'ACTIVE')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Suspend Workspace?'),
                      content: const Text('This will immediately block all API access, POS syncs, and Manager logins for this business. Are you sure?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: NexusTheme.error),
                          onPressed: () => Navigator.pop(ctx, true), 
                          child: const Text('Suspend', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && widget.business['id'] != null) {
                    final success = await _api.suspendBusiness(widget.business['id']);
                    if (success) {
                      setState(() {
                        widget.business['status'] = 'SUSPENDED';
                      });
                    }
                  }
                },
                icon: const Icon(Icons.lock_outline, color: Colors.white, size: 16),
                label: const Text('Suspend App', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: NexusTheme.error),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (widget.business['id'] != null) {
                    final success = await _api.activateBusiness(widget.business['id']);
                    if (success) {
                      setState(() {
                        widget.business['status'] = 'ACTIVE';
                      });
                    }
                  }
                },
                icon: const Icon(Icons.lock_open_outlined, color: Colors.white, size: 16),
                label: const Text('Activate App', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: NexusTheme.success),
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.primaryColor,
          labelColor: theme.primaryColor,
          unselectedLabelColor: isDark ? NexusTheme.textMuted : NexusTheme.lightTextSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.analytics_outlined), text: 'Analytics & Charts'),
            Tab(icon: Icon(Icons.history_toggle_off), text: 'Activity Logs'),
            Tab(icon: Icon(Icons.devices), text: 'Connected Devices'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAnalyticsTab(),
          _buildLogsTab(),
          _buildDevicesTab(),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    if (_loadingStats) {
      return const Center(child: CircularProgressIndicator(color: NexusTheme.accent));
    }

    final totalSales = _stats['totalSales'] ?? 0.0;
    final totalExpenses = _stats['totalExpenses'] ?? 0.0;
    final netRevenue = _stats['netRevenue'] ?? 0.0;
    final salesOverTime = _stats['salesOverTime'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row of Overview KPI Cards
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  'TOTAL REVENUE',
                  '\$${totalSales.toStringAsFixed(2)}',
                  Icons.trending_up,
                  NexusTheme.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildKpiCard(
                  'TOTAL EXPENSES',
                  '\$${totalExpenses.toStringAsFixed(2)}',
                  Icons.trending_down,
                  NexusTheme.error,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildKpiCard(
                  'NET POSITION',
                  '\$${netRevenue.toStringAsFixed(2)}',
                  Icons.account_balance_wallet_outlined,
                  netRevenue >= 0 ? NexusTheme.accent : NexusTheme.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Chart Card
          NexusCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SALES VELOCITY CHART', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Daily revenue trends logged by transaction layers.', style: TextStyle(color: NexusTheme.textMuted, fontSize: 12)),
                const SizedBox(height: 32),
                SizedBox(
                  height: 300,
                  child: salesOverTime.isEmpty
                      ? const Center(child: Text('No transaction history logged for this client yet.', style: TextStyle(color: NexusTheme.textMuted)))
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
                                spots: salesOverTime.asMap().entries.map((e) {
                                  final amount = (e.value['amount'] as num?)?.toDouble() ?? 0.0;
                                  return FlSpot(e.key.toDouble(), amount);
                                }).toList(),
                                isCurved: true,
                                color: NexusTheme.accent,
                                barWidth: 3,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: NexusTheme.accent.withValues(alpha: 0.1),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsTab() {
    if (_loadingLogs) {
      return const Center(child: CircularProgressIndicator(color: NexusTheme.accent));
    }

    final auditLogs = _logs['auditLogs'] as List<dynamic>? ?? [];
    final activityLogs = _logs['activityLogs'] as List<dynamic>? ?? [];

    if (auditLogs.isEmpty && activityLogs.isEmpty) {
      return const Center(child: Text('No system or activity logs recorded.', style: TextStyle(color: NexusTheme.textMuted)));
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (activityLogs.isNotEmpty) ...[
          Text('LIVE ACTIVITY STREAM', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...activityLogs.map((log) => _buildLogTile(log, isAudit: false)),
          const SizedBox(height: 32),
        ],
        if (auditLogs.isNotEmpty) ...[
          Text('SECURITY & AUDIT LOGS', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...auditLogs.map((log) => _buildLogTile(log, isAudit: true)),
        ],
      ],
    );
  }

  Widget _buildDevicesTab() {
    if (_loadingDevices) {
      return const Center(child: CircularProgressIndicator(color: NexusTheme.accent));
    }

    final devices = _devicesData['devices'] as List<dynamic>? ?? [];
    final health = _devicesData['health'] as Map<String, dynamic>? ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Database & Connection Health Cards
          Text('SYSTEM METRICS & CONNECTIONS', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildHealthStatusIndicator('Database Connection', health['databaseOnline'] ?? true),
              const SizedBox(width: 16),
              _buildHealthStatusIndicator('Sync Gateway API', health['apiOnline'] ?? true),
            ],
          ),
          const SizedBox(height: 32),

          Text('PROVISIONED TERMINALS', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          devices.isEmpty
              ? const Text('No devices registered under this business yet.', style: TextStyle(color: NexusTheme.textMuted))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final dev = devices[index];
                    return _buildDeviceCard(dev);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return NexusCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: NexusTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 20)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLogTile(dynamic log, {required bool isAudit}) {
    final action = log['action'] ?? 'Updated Record';
    final user = log['user'] ?? 'System';
    final time = log['time'] ?? '';
    final device = log['device'] ?? 'Cloud';
    final result = log['result'] ?? 'SUCCESS';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: NexusTheme.border.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isAudit ? Icons.admin_panel_settings_outlined : Icons.info_outline,
            size: 16,
            color: isAudit ? NexusTheme.warning : NexusTheme.accent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAudit ? '${log['oldValue'] ?? ''} ➔ ${log['newValue'] ?? ''}' : action,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Operator: $user · Device: $device · $time',
                  style: const TextStyle(color: NexusTheme.textMuted, fontSize: 10),
                ),
              ],
            ),
          ),
          Text(
            result.toString().toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: result == 'SUCCESS' ? NexusTheme.success : NexusTheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStatusIndicator(String label, bool isOnline) {
    final color = isOnline ? NexusTheme.success : NexusTheme.error;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.circle, color: color, size: 8),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 12)),
            const Spacer(),
            Text(isOnline ? 'ONLINE' : 'OFFLINE', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard(dynamic dev) {
    final name = dev['deviceName'] ?? 'Terminal';
    final user = dev['user'] ?? 'Staff';
    final isOnline = dev['isOnline'] ?? false;
    final statusColor = isOnline ? NexusTheme.success : NexusTheme.textMuted;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: NexusTheme.border.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.tablet_android, color: statusColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                Text('Active Cashier: $user · App v${dev['appVersion'] ?? '1.0.0'}', style: const TextStyle(color: NexusTheme.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Icon(Icons.circle, color: statusColor, size: 8),
        ],
      ),
    );
  }
}
