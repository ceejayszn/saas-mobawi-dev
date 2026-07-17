import 'package:flutter/material.dart';
import '../../core/theme/nexus_theme.dart';
import '../../core/widgets/common/nexus_card.dart';
import '../../core/services/nexus_api.dart';
import '../../core/widgets/common/empty_state.dart';

class InfrastructureScreen extends StatefulWidget {
  final Function(String) onNavigate;

  const InfrastructureScreen({super.key, required this.onNavigate});

  @override
  State<InfrastructureScreen> createState() => _InfrastructureScreenState();
}

class _InfrastructureScreenState extends State<InfrastructureScreen> {
  final NexusApi _api = NexusApi();
  bool _isLoading = true;
  Map<String, dynamic> _infraData = {};

  @override
  void initState() {
    super.initState();
    _loadInfraData();
  }

  Future<void> _loadInfraData() async {
    final data = await _api.fetchInfrastructureOverview();
    if (mounted) {
      setState(() {
        _infraData = data;
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

    if (_infraData.isEmpty) {
      return NexusEmptyState(
        title: 'Infrastructure Disconnected',
        description: 'Neon cluster parameters, system logs, and direct database adapters are unavailable.',
        icon: Icons.dns_outlined,
        actionLabel: 'Connect Infrastructure Console',
        onAction: _loadInfraData,
      );
    }

    final postgres = _infraData['postgres'] as Map<String, dynamic>? ?? {};
    final logs = _infraData['system_logs'] as List<dynamic>? ?? [];

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
                  Text('DEVELOPER & INFRASTRUCTURE NODES', style: theme.textTheme.displayLarge),
                  const SizedBox(height: 4),
                  Text('Neon PostgreSQL configurations, server logs, and API health parameters.', style: theme.textTheme.bodyMedium),
                ],
              ),
              OutlinedButton.icon(
                onPressed: _loadInfraData,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Sync Nodes'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.primaryColor,
                  side: BorderSide(color: borderColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Neon PG details
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    NexusCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Database Node Status', style: theme.textTheme.headlineMedium),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: NexusTheme.success.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: NexusTheme.success.withValues(alpha: 0.3)),
                                ),
                                child: const Text(
                                  'ONLINE',
                                  style: TextStyle(color: NexusTheme.success, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildDetailCol('Database Provider', postgres['version'] ?? 'Neon PG'),
                          _buildDetailCol('Active Database Size', postgres['database_size'] ?? 'N/A'),
                          _buildDetailCol('Concurrent Connection Capacity', '${postgres['active_connections'] ?? 0} / ${postgres['max_connections'] ?? 100} slots'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    NexusCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Developer Console Links', style: theme.textTheme.titleLarge),
                          const SizedBox(height: 8),
                          const Text('Admin links to production platforms.', style: TextStyle(color: NexusTheme.textMuted, fontSize: 12)),
                          const SizedBox(height: 20),
                          _buildConsoleLinkTile(context, 'Railway Control Panel', 'https://railway.app/', Icons.rocket_launch_outlined),
                          _buildConsoleLinkTile(context, 'Neon SQL Dashboard', 'https://neon.tech/', Icons.storage_outlined),
                          _buildConsoleLinkTile(context, 'Cloudflare Proxy Management', 'https://cloudflare.com/', Icons.cloud_outlined),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Right Column: System logs console terminal
              Expanded(
                flex: 3,
                child: NexusCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Live System Event Logs', style: theme.textTheme.headlineMedium),
                          const Icon(Icons.terminal, color: NexusTheme.textSecondary, size: 18),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('Standard output streams captured from production instances.', style: TextStyle(color: NexusTheme.textMuted, fontSize: 12)),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        height: 340,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor),
                        ),
                        child: logs.isEmpty
                            ? const Center(child: Text('No system logs streaming from edge instance.', style: TextStyle(color: Colors.white38, fontFamily: 'JetBrains Mono', fontSize: 12)))
                            : ListView.builder(
                                itemCount: logs.length,
                                itemBuilder: (context, index) {
                                  final log = logs[index].toString();
                                  final isWarn = log.contains('[WARN]');
                                  final isError = log.contains('[ERROR]');

                                  final textColor = isError
                                      ? Colors.redAccent
                                      : isWarn
                                          ? Colors.amberAccent
                                          : Colors.greenAccent;

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      log,
                                      style: TextStyle(
                                        fontFamily: 'JetBrains Mono',
                                        fontSize: 11,
                                        color: textColor,
                                      ),
                                    ),
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
        ],
      ),
    );
  }

  Widget _buildDetailCol(String title, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: NexusTheme.textMuted, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(val, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const Divider(height: 16),
        ],
      ),
    );
  }

  Widget _buildConsoleLinkTile(BuildContext context, String label, String url, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        title: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.open_in_new, size: 12, color: NexusTheme.textMuted),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Redirecting to developer URL: $url')),
          );
        },
      ),
    );
  }
}
