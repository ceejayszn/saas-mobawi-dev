import 'package:flutter/material.dart';
import '../../core/widgets/common/empty_state.dart';

class WebsiteCenterScreen extends StatelessWidget {
  final Function(String) onNavigate;

  const WebsiteCenterScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NexusEmptyState(
        title: 'Website Analytics Offline',
        description: 'SEO speed indices, landing pages, documentation sites, and Cloudflare traffic analytics are empty.',
        icon: Icons.web_outlined,
        actionLabel: 'Link Cloudflare Analytics',
        onAction: () {},
      ),
    );
  }
}
