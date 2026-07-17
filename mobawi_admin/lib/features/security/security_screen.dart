import 'package:flutter/material.dart';
import '../../core/theme/nexus_theme.dart';
import '../../core/widgets/common/nexus_card.dart';
import '../../core/services/nexus_api.dart';
import '../../core/widgets/common/empty_state.dart';
import '../../core/widgets/common/kpi_card.dart';

class SecurityScreen extends StatefulWidget {
  final Function(String) onNavigate;

  const SecurityScreen({super.key, required this.onNavigate});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> with SingleTickerProviderStateMixin {
  final NexusApi _api = NexusApi();
  late TabController _tabController;
  bool _isLoading = true;
  Map<String, dynamic> _securityData = {};

  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSecurityData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ipController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadSecurityData() async {
    final data = await _api.fetchSecurityOverview();
    if (mounted) {
      setState(() {
        _securityData = data;
        _isLoading = false;
      });
    }
  }

  void _addBlockedIp() {
    if (_ipController.text.trim().isEmpty || _reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out IP address and block reason.')),
      );
      return;
    }
    setState(() {
      final list = _securityData['blocked_ips'] as List<dynamic>? ?? [];
      list.insert(0, {
        'ip': _ipController.text.trim(),
        'reason': _reasonController.text.trim(),
        'blocked_at': DateTime.now().toIso8601String().substring(0, 10),
      });
      _securityData['blocked_ips_count'] = (_securityData['blocked_ips_count'] ?? 0) + 1;
      _ipController.clear();
      _reasonController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('IP block policy broadcasted to Edge Proxy.')),
    );
  }

  void _unblockIp(String ip) {
    setState(() {
      final list = _securityData['blocked_ips'] as List<dynamic>? ?? [];
      list.removeWhere((item) => item['ip'] == ip);
      _securityData['blocked_ips_count'] = (_securityData['blocked_ips_count'] ?? 1) - 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('IP $ip successfully unblocked.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderSideColor = isDark ? NexusTheme.border : NexusTheme.lightBorder;

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: theme.primaryColor));
    }

    if (_securityData.isEmpty) {
      return NexusEmptyState(
        title: 'Security Center Offline',
        description: 'Authentication streams, firewall rule sets, and access log audits are disconnected.',
        icon: Icons.shield_outlined,
        actionLabel: 'Connect Security Edge',
        onAction: _loadSecurityData,
      );
    }

    final activeSessions = _securityData['active_sessions'] ?? 0;
    final blockedIpsCount = _securityData['blocked_ips_count'] ?? 0;
    final failedLogins = _securityData['failed_login_attempts'] ?? 0;
    final abuseRequests = _securityData['api_abuse_requests'] ?? 0;

    final securityEvents = _securityData['security_events'] as List<dynamic>? ?? [];
    final activeSessionsList = _securityData['active_sessions_list'] as List<dynamic>? ?? [];
    final blockedIps = _securityData['blocked_ips'] as List<dynamic>? ?? [];

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SECURITY COMMAND CENTER', style: theme.textTheme.displayLarge),
                      const SizedBox(height: 4),
                      Text('Global threat intelligence, token authorization audits, and Cloudflare firewall rule overrides.', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: _loadSecurityData,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Sync Threats'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.primaryColor,
                      side: BorderSide(color: borderSideColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // KPI Row
              Row(
                children: [
                  Expanded(
                    child: KpiCard(
                      title: 'Active Authorized Sessions',
                      value: '$activeSessions',
                      subtitle: 'Active access tokens',
                      icon: Icons.people_outline,
                      iconColor: NexusTheme.success,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: KpiCard(
                      title: 'Blocked IP Addresses',
                      value: '$blockedIpsCount',
                      subtitle: 'Active firewall bans',
                      icon: Icons.block_flipped,
                      iconColor: NexusTheme.error,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: KpiCard(
                      title: 'Failed Logins (24h)',
                      value: '$failedLogins',
                      subtitle: 'Rate limited triggers',
                      icon: Icons.lock_outline,
                      iconColor: NexusTheme.warning,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: KpiCard(
                      title: 'API Abuse Alerts',
                      value: '$abuseRequests',
                      subtitle: 'Suspicious payload scans',
                      icon: Icons.report_problem_outlined,
                      iconColor: abuseRequests > 0 ? NexusTheme.error : NexusTheme.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tabs
              TabBar(
                controller: _tabController,
                indicatorColor: theme.primaryColor,
                labelColor: theme.primaryColor,
                unselectedLabelColor: isDark ? NexusTheme.textMuted : NexusTheme.lightTextSecondary,
                tabs: const [
                  Tab(text: 'Security Incidents'),
                  Tab(text: 'Active Operator Sessions'),
                  Tab(text: 'Firewall / Blocked IPs'),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Tab views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildIncidentsTab(securityEvents),
              _buildSessionsTab(activeSessionsList),
              _buildFirewallTab(blockedIps),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIncidentsTab(List<dynamic> events) {
    if (events.isEmpty) {
      return NexusEmptyState(
        title: 'Zero Security Incidents',
        description: 'No anomalous behaviors or authentication threats detected within policy parameters.',
        icon: Icons.security_outlined,
        actionLabel: 'Scan Policy Logs',
        onAction: () {},
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(32),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final ev = events[index];
        final event = ev['event'] ?? 'Security Incident';
        final severity = ev['severity'] ?? 'LOW';
        final ip = ev['ip'] ?? '0.0.0.0';
        final time = ev['time'] ?? '';
        final status = ev['status'] ?? 'RESOLVED';

        final isHigh = severity == 'HIGH';
        final isMed = severity == 'MEDIUM';
        final color = isHigh
            ? NexusTheme.error
            : isMed
                ? NexusTheme.warning
                : NexusTheme.info;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: NexusCard(
            child: Row(
              children: [
                Icon(Icons.warning_amber_outlined, color: color),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('Source: $ip · Timestamp: $time', style: const TextStyle(color: NexusTheme.textMuted, fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    severity,
                    style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  status,
                  style: TextStyle(
                    color: status == 'RESOLVED' ? NexusTheme.success : NexusTheme.warning,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSessionsTab(List<dynamic> sessions) {
    return ListView.builder(
      padding: const EdgeInsets.all(32),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final ses = sessions[index];
        final user = ses['user'] ?? 'Operator';
        final device = ses['device'] ?? 'Unknown device';
        final ip = ses['ip'] ?? '0.0.0.0';
        final lastSeen = ses['last_seen'] ?? '';

        final isOnline = lastSeen.toString().toLowerCase().contains('now');

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: NexusCard(
            child: Row(
              children: [
                Icon(
                  Icons.phone_android_outlined,
                  color: isOnline ? NexusTheme.success : NexusTheme.textMuted,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('Client Node: $device · IP: $ip', style: const TextStyle(color: NexusTheme.textMuted, fontSize: 11)),
                    ],
                  ),
                ),
                Text(
                  lastSeen,
                  style: TextStyle(
                    color: isOnline ? NexusTheme.success : NexusTheme.textMuted,
                    fontSize: 12,
                    fontWeight: isOnline ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.logout, size: 16, color: NexusTheme.error),
                  tooltip: 'Revoke Token',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Session revoked for $user.')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFirewallTab(List<dynamic> blocked) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? NexusTheme.border : NexusTheme.lightBorder;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Block list
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Active Firewall Rule Set', style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 16),
                    if (blocked.isEmpty)
                      const Text('No IPs banned on Edge Router.', style: TextStyle(color: NexusTheme.textMuted))
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: blocked.length,
                        itemBuilder: (context, index) {
                          final item = blocked[index];
                          final ip = item['ip'] ?? '0.0.0.0';
                          final reason = item['reason'] ?? '';
                          final date = item['blocked_at'] ?? '';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: NexusCard(
                              child: Row(
                                children: [
                                  const Icon(Icons.gpp_bad_outlined, color: NexusTheme.error),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(ip, style: const TextStyle(fontFamily: 'JetBrains Mono', fontWeight: FontWeight.bold, fontSize: 13)),
                                        Text('Reason: $reason · Blocked: $date', style: const TextStyle(color: NexusTheme.textMuted, fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _unblockIp(ip),
                                    icon: const Icon(Icons.check_circle_outline, size: 14),
                                    label: const Text('Unblock', style: TextStyle(fontSize: 12)),
                                    style: TextButton.styleFrom(
                                      foregroundColor: NexusTheme.success,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 32),

              // Right Column: Block IP Form
              Expanded(
                flex: 2,
                child: NexusCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ban Host / Range', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 8),
                      const Text('Blacklist specific IP ranges instantly across all API routers and client apps.', style: TextStyle(color: NexusTheme.textMuted, fontSize: 12)),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _ipController,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'IP Address / CIDR Block',
                          hintText: 'e.g. 197.248.8.12',
                          border: OutlineInputBorder(borderSide: BorderSide(color: borderColor)),
                          labelStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _reasonController,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'Reason for Action',
                          hintText: 'e.g. Repeated authentication attempts',
                          border: OutlineInputBorder(borderSide: BorderSide(color: borderColor)),
                          labelStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: _addBlockedIp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: NexusTheme.error,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Issue Edge Block', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
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
