import 'package:flutter/material.dart';
import '../../core/widgets/common/empty_state.dart';

class SettingsScreen extends StatelessWidget {
  final Function(String) onNavigate;

  const SettingsScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NexusEmptyState(
        title: 'Settings Lock Active',
        description: 'Environment variables, global webhook routes, and OAuth keys require primary MFA authorization.',
        icon: Icons.settings_outlined,
        actionLabel: 'Authenticate Founder MFA',
        onAction: () {},
      ),
    );
  }
}
