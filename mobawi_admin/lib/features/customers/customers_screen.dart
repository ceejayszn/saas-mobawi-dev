import 'package:flutter/material.dart';
import '../../core/theme/nexus_theme.dart';
import '../../core/widgets/common/nexus_card.dart';
import '../../core/services/nexus_api.dart';
import '../../core/widgets/common/empty_state.dart';
import 'business_detail_monitor_screen.dart';

class CustomersScreen extends StatefulWidget {
  final Function(String) onNavigate;

  const CustomersScreen({super.key, required this.onNavigate});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final NexusApi _api = NexusApi();
  bool _isLoading = true;
  List<dynamic> _businesses = [];
  Map<String, dynamic>? _selectedBusiness;

  @override
  void initState() {
    super.initState();
    _loadBusinesses();
  }

  Future<void> _loadBusinesses() async {
    final data = await _api.fetchBusinesses();
    if (mounted) {
      setState(() {
        _businesses = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedBusiness != null) {
      return BusinessDetailMonitorScreen(
        business: _selectedBusiness!,
        onBack: () => setState(() => _selectedBusiness = null),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: NexusTheme.accent));
    }

    if (_businesses.isEmpty) {
      return NexusEmptyState(
        title: 'No Registered Business Workspaces',
        description: 'Provision client organizations, verify licenses, and activate workspaces.',
        icon: Icons.business_outlined,
        actionLabel: 'Provision First Client',
        onAction: () => _loadBusinesses(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CUSTOMER WORKSPACES', style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: 4),
          Text('Central directory of active business entities, devices, and licensing context.', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 32),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _businesses.length,
            itemBuilder: (context, index) {
              final b = _businesses[index];
              return _buildBusinessRow(b);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessRow(dynamic b) {
    final name = b['name'] ?? 'Company';
    final type = b['type'] ?? 'HOTEL';
    final status = b['status'] ?? 'inactive';
    final userCount = b['_count']?['users'] ?? 0;
    final salesCount = b['_count']?['sales'] ?? 0;

    final isActive = status.toString().toUpperCase() == 'ACTIVE';
    final color = isActive ? NexusTheme.success : NexusTheme.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedBusiness = b as Map<String, dynamic>;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: NexusCard(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.1),
                child: Icon(
                  type == 'HOTEL' 
                      ? Icons.hotel_outlined 
                      : type == 'PHARMACY' 
                          ? Icons.local_pharmacy_outlined 
                          : Icons.shopping_bag_outlined,
                  color: color,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.titleLarge),
                    Text('Type: $type · Operators: $userCount · Transactions: $salesCount', style: const TextStyle(color: NexusTheme.textMuted, fontSize: 11)),
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
        ),
      ),
    );
  }
}
