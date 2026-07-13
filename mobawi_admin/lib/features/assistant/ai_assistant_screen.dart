import 'package:flutter/material.dart';
import '../../core/widgets/common/empty_state.dart';

class AiAssistantScreen extends StatelessWidget {
  final Function(String) onNavigate;

  const AiAssistantScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NexusEmptyState(
        title: 'AI Assistant Inactive',
        description: 'Command line terminal and vector-embedded search assistant require GCP integration keys.',
        icon: Icons.chat_bubble_outline_outlined,
        actionLabel: 'Setup Integration Keys',
        onAction: () {},
      ),
    );
  }
}
