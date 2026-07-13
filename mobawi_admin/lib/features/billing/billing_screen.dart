import 'package:flutter/material.dart';
import '../../core/widgets/common/empty_state.dart';

class BillingScreen extends StatelessWidget {
  final Function(String) onNavigate;

  const BillingScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NexusEmptyState(
        title: 'Billing Systems Disconnected',
        description: 'M-Pesa C2B API callbacks and subscription invoices are currently blank in the core database.',
        icon: Icons.payments_outlined,
        actionLabel: 'Link M-Pesa Gateway',
        onAction: () {},
      ),
    );
  }
}
