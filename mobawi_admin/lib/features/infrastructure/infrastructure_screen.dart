import 'package:flutter/material.dart';
import '../../core/widgets/common/empty_state.dart';

class InfrastructureScreen extends StatelessWidget {
  final Function(String) onNavigate;

  const InfrastructureScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NexusEmptyState(
        title: 'Infrastructure Node Disconnected',
        description: 'PostgreSQL clusters and Railway deployment status metrics require live OAuth connection.',
        icon: Icons.dns_outlined,
        actionLabel: 'Link Railway API Console',
        onAction: () {},
      ),
    );
  }
}
