import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/nexus_theme.dart';
import '../../core/widgets/common/nexus_card.dart';
import '../../core/services/nexus_api.dart';
import '../../core/widgets/common/empty_state.dart';
import '../../core/widgets/common/kpi_card.dart';

class BillingScreen extends StatefulWidget {
  final Function(String) onNavigate;

  const BillingScreen({super.key, required this.onNavigate});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> with SingleTickerProviderStateMixin {
  final NexusApi _api = NexusApi();
  late TabController _tabController;

  bool _isLoading = true;
  Map<String, dynamic> _billingData = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadBillingData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBillingData() async {
    final data = await _api.fetchBillingOverview();
    if (mounted) {
      setState(() {
        _billingData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderSideColor = isDark ? NexusTheme.border : NexusTheme.lightBorder;

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: theme.primaryColor));
    }

    if (_billingData.isEmpty) {
      return NexusEmptyState(
        title: 'Billing System Disconnected',
        description: 'Subscription records, M-Pesa callbacks and invoice history require a live backend connection.',
        icon: Icons.payments_outlined,
        actionLabel: 'Reconnect Billing Engine',
        onAction: _loadBillingData,
      );
    }

    final subscriptions = _billingData['subscriptions'] as List<dynamic>? ?? [];
    final invoices = _billingData['invoices'] as List<dynamic>? ?? [];
    final payments = _billingData['payments'] as List<dynamic>? ?? [];
    final mrr = _billingData['mrr'] ?? 0.0;
    final arr = _billingData['arr'] ?? 0.0;
    final outstanding = _billingData['outstanding_amount'] ?? 0.0;
    final activeCount = _billingData['active_subscriptions'] ?? 0;

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
                      Text('BILLING & SUBSCRIPTIONS', style: theme.textTheme.displayLarge),
                      const SizedBox(height: 4),
                      Text('Revenue tracking, subscription management, and payment history.', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _loadBillingData,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Refresh'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.primaryColor,
                          side: BorderSide(color: borderSideColor),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('New Invoice'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // KPI Row
              Row(
                children: [
                  Expanded(
                    child: KpiCard(
                      title: 'Monthly Recurring Revenue',
                      value: 'KES ${(mrr as num).toStringAsFixed(2)}',
                      subtitle: 'Active subscriptions',
                      icon: Icons.trending_up,
                      iconColor: NexusTheme.success,
                      trend: '+8.2%',
                      isTrendPositive: true,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: KpiCard(
                      title: 'Annual Recurring Revenue',
                      value: 'KES ${(arr as num).toStringAsFixed(2)}',
                      subtitle: 'Annualized projection',
                      icon: Icons.calendar_today_outlined,
                      iconColor: NexusTheme.info,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: KpiCard(
                      title: 'Outstanding Invoices',
                      value: 'KES ${(outstanding as num).toStringAsFixed(2)}',
                      subtitle: 'Awaiting payment',
                      icon: Icons.pending_actions_outlined,
                      iconColor: NexusTheme.warning,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: KpiCard(
                      title: 'Active Subscriptions',
                      value: '$activeCount',
                      subtitle: 'Paying customers',
                      icon: Icons.card_membership_outlined,
                      iconColor: NexusTheme.accent,
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
                  Tab(text: 'Subscriptions'),
                  Tab(text: 'Invoices'),
                  Tab(text: 'Payment History'),
                  Tab(text: 'License Generator'),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSubscriptionsTab(subscriptions),
              _buildInvoicesTab(invoices),
              _buildPaymentsTab(payments),
              _buildLicenseTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionsTab(List<dynamic> subscriptions) {
    if (subscriptions.isEmpty) {
      return NexusEmptyState(
        title: 'No Active Subscriptions',
        description: 'Subscription plans will appear here once customers are onboarded.',
        icon: Icons.card_membership_outlined,
        actionLabel: 'Create Plan',
        onAction: () {},
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(32),
      itemCount: subscriptions.length,
      itemBuilder: (context, index) => _buildSubscriptionRow(subscriptions[index]),
    );
  }

  Widget _buildSubscriptionRow(dynamic sub) {
    final theme = Theme.of(context);
    final name = sub['business_name'] ?? 'Business';
    final plan = sub['plan'] ?? 'STARTER';
    final amount = sub['amount'] ?? 0.0;
    final status = sub['status'] ?? 'ACTIVE';
    final nextBilling = sub['next_billing_date'] ?? 'N/A';

    final isActive = status.toString().toUpperCase() == 'ACTIVE';
    final color = isActive ? NexusTheme.success : NexusTheme.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: NexusCard(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(Icons.business_outlined, color: color, size: 18),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: theme.textTheme.titleLarge?.copyWith(fontSize: 14)),
                  Text('Plan: $plan · Next billing: $nextBilling',
                      style: const TextStyle(color: NexusTheme.textMuted, fontSize: 11)),
                ],
              ),
            ),
            Text(
              'KES ${(amount as num).toStringAsFixed(2)}/mo',
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 24),
            _buildStatusChip(status, color),
            const SizedBox(width: 16),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, size: 18, color: NexusTheme.textMuted),
              onSelected: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$value for $name — requires backend integration')),
                );
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'View Invoice', child: Text('View Invoice')),
                const PopupMenuItem(value: 'Suspend', child: Text('Suspend')),
                const PopupMenuItem(value: 'Cancel', child: Text('Cancel')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoicesTab(List<dynamic> invoices) {
    if (invoices.isEmpty) {
      return NexusEmptyState(
        title: 'No Invoices Found',
        description: 'Invoice records will appear once billing cycles run.',
        icon: Icons.receipt_long_outlined,
        actionLabel: 'Generate Invoice',
        onAction: () {},
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(32),
      itemCount: invoices.length,
      itemBuilder: (context, index) => _buildInvoiceRow(invoices[index]),
    );
  }

  Widget _buildInvoiceRow(dynamic inv) {
    final theme = Theme.of(context);
    final id = inv['invoice_id'] ?? '#INV-001';
    final business = inv['business_name'] ?? 'Business';
    final amount = inv['amount'] ?? 0.0;
    final status = inv['status'] ?? 'PENDING';
    final date = inv['date'] ?? 'N/A';

    final isPaid = status.toString().toUpperCase() == 'PAID';
    final color = isPaid ? NexusTheme.success : NexusTheme.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: NexusCard(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(Icons.receipt_outlined, color: color, size: 20),
            const SizedBox(width: 16),
            Text(id, style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 12, color: NexusTheme.textMuted)),
            const SizedBox(width: 20),
            Expanded(
              child: Text(business, style: theme.textTheme.titleLarge?.copyWith(fontSize: 14)),
            ),
            Text(date, style: const TextStyle(color: NexusTheme.textMuted, fontSize: 12)),
            const SizedBox(width: 24),
            Text(
              'KES ${(amount as num).toStringAsFixed(2)}',
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 14),
            ),
            const SizedBox(width: 24),
            _buildStatusChip(status, color),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.copy_outlined, size: 16),
              tooltip: 'Copy Invoice ID',
              onPressed: () => Clipboard.setData(ClipboardData(text: id)),
              color: NexusTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsTab(List<dynamic> payments) {
    if (payments.isEmpty) {
      return NexusEmptyState(
        title: 'No Payment Records',
        description: 'M-Pesa C2B callbacks and manual payment records will appear here.',
        icon: Icons.account_balance_wallet_outlined,
        actionLabel: 'Refresh Payments',
        onAction: _loadBillingData,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(32),
      itemCount: payments.length,
      itemBuilder: (context, index) => _buildPaymentRow(payments[index]),
    );
  }

  Widget _buildPaymentRow(dynamic pay) {
    final theme = Theme.of(context);
    final method = pay['method'] ?? 'M-PESA';
    final amount = pay['amount'] ?? 0.0;
    final reference = pay['reference'] ?? 'TXN-???';
    final business = pay['business_name'] ?? 'Business';
    final date = pay['date'] ?? 'N/A';

    final methodColor = method == 'M-PESA'
        ? const Color(0xFF00B140)
        : method == 'CARD'
            ? NexusTheme.info
            : NexusTheme.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: NexusCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: methodColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: methodColor.withValues(alpha: 0.3)),
              ),
              child: Text(method, style: TextStyle(color: methodColor, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 16),
            Text(reference, style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, color: NexusTheme.textMuted)),
            const SizedBox(width: 20),
            Expanded(
              child: Text(business, style: theme.textTheme.titleLarge?.copyWith(fontSize: 13)),
            ),
            Text(date, style: const TextStyle(color: NexusTheme.textMuted, fontSize: 12)),
            const SizedBox(width: 24),
            Text(
              'KES ${(amount as num).toStringAsFixed(2)}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: NexusTheme.success,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, Color color) {
    return Container(
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
    );
  }

  String _selectedApp = 'Natty Gym';
  String _selectedDuration = '1 Year';
  String _generatedLicense = '';

  Widget _buildLicenseTab() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderSideColor = isDark ? NexusTheme.border : NexusTheme.lightBorder;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Generate Application License', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('Create an encrypted, time-limited license key that can be verified by the offline POS apps.', style: TextStyle(color: NexusTheme.textMuted)),
          const SizedBox(height: 32),
          NexusCard(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Target Application', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: borderSideColor),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedApp,
                                isExpanded: true,
                                dropdownColor: theme.cardColor,
                                items: ['Natty Gym', 'Delights Juice Shop', 'Felixpinski Hotel', 'Custom App'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                onChanged: (v) => setState(() => _selectedApp = v!),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Duration', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: borderSideColor),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedDuration,
                                isExpanded: true,
                                dropdownColor: theme.cardColor,
                                items: ['1 Day', '48 Hours', '2 Weeks', '1 Year', 'Custom'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                onChanged: (v) => setState(() => _selectedDuration = v!),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    final timestamp = DateTime.now().millisecondsSinceEpoch;
                    setState(() {
                      _generatedLicense = 'MBW-${_selectedApp.substring(0, 3).toUpperCase()}-${timestamp.toString().substring(6)}-${_selectedDuration.replaceAll(" ", "")}';
                    });
                  },
                  icon: const Icon(Icons.key, color: Colors.white),
                  label: const Text('Generate Secret Code', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NexusTheme.accent,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  ),
                ),
                if (_generatedLicense.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 24),
                  const Text('Generated Encrypted License', style: TextStyle(fontWeight: FontWeight.bold, color: NexusTheme.success)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: NexusTheme.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: NexusTheme.success.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_generatedLicense, style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
                        IconButton(
                          icon: const Icon(Icons.copy, color: NexusTheme.success),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _generatedLicense));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('License copied to clipboard!')));
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
