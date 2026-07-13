import 'package:flutter/material.dart';
import '../../core/widgets/common/empty_state.dart';

class AiCenterScreen extends StatelessWidget {
  final Function(String) onNavigate;

  const AiCenterScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NexusEmptyState(
        title: 'AI Logs & Analytics Offline',
        description: 'Google AI token usage cost trackers and prompt performance evaluation tables are currently empty.',
        icon: Icons.psychology_outlined,
        actionLabel: 'Link Gemini API Adapter',
        onAction: () {},
      ),
    );
  }
}
