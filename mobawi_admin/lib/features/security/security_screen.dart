import 'package:flutter/material.dart';
import '../../core/widgets/common/empty_state.dart';

class SecurityScreen extends StatelessWidget {
  final Function(String) onNavigate;

  const SecurityScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NexusEmptyState(
        title: 'Security Center Inactive',
        description: 'Audit logs, suspicious device attempts, and API abuse statistics require rate-limiting configuration.',
        icon: Icons.security_outlined,
        actionLabel: 'Check Security Spec docs',
        onAction: () {},
      ),
    );
  }
}
