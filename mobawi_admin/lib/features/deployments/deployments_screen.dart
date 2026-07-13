import 'package:flutter/material.dart';
import '../../core/theme/nexus_theme.dart';
import '../../core/widgets/common/nexus_card.dart';
import '../../core/services/nexus_api.dart';
import '../../core/widgets/common/empty_state.dart';

class DeploymentsScreen extends StatefulWidget {
  final Function(String) onNavigate;

  const DeploymentsScreen({super.key, required this.onNavigate});

  @override
  State<DeploymentsScreen> createState() => _DeploymentsScreenState();
}

class _DeploymentsScreenState extends State<DeploymentsScreen> {
  final NexusApi _api = NexusApi();
  bool _isLoading = true;
  List<dynamic> _deployments = [];

  @override
  void initState() {
    super.initState();
    _loadDeployments();
  }

  Future<void> _loadDeployments() async {
    final data = await _api.fetchLiveDeployments();
    if (mounted) {
      setState(() {
        _deployments = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: NexusTheme.accent));
    }

    if (_deployments.isEmpty) {
      return NexusEmptyState(
        title: 'No Deployment Pipeline Data',
        description: 'Sync GitHub actions and Railway triggers to inspect active production pipelines.',
        icon: Icons.rocket_launch_outlined,
        actionLabel: 'Refresh Deployment Center',
        onAction: () => _loadDeployments(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LIVE DEPLOYMENTS & RELEASES', style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: 4),
          Text('Release pipelines, build queues, and zero-downtime hot-deploy targets.', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 32),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _deployments.length,
            itemBuilder: (context, index) {
              final d = _deployments[index];
              return _buildDeploymentRow(d);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeploymentRow(dynamic d) {
    final commit = d['commit'] ?? 'Initial commit';
    final repo = d['repo'] ?? 'mobawi-core';
    final status = d['status'] ?? 'pending';
    final started = d['started'] ?? '';

    final isSuccess = status == 'success';
    final color = isSuccess ? NexusTheme.success : NexusTheme.warning;

    return NexusCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(Icons.rocket_launch_outlined, color: color),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(commit, style: Theme.of(context).textTheme.titleLarge),
                Text('$repo · $started', style: const TextStyle(color: NexusTheme.textMuted, fontSize: 11)),
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
              status.toString().toUpperCase(),
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
