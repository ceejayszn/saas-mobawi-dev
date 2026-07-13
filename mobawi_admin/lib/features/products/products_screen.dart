import 'package:flutter/material.dart';
import '../../core/theme/nexus_theme.dart';
import '../../core/widgets/common/nexus_card.dart';
import '../../core/services/nexus_api.dart';
import '../../core/widgets/common/empty_state.dart';

class ProductsScreen extends StatefulWidget {
  final Function(String) onNavigate;

  const ProductsScreen({super.key, required this.onNavigate});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final NexusApi _api = NexusApi();
  bool _isLoading = true;
  List<dynamic> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final data = await _api.fetchProducts();
    if (mounted) {
      setState(() {
        _products = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: NexusTheme.accent));
    }

    if (_products.isEmpty) {
      return NexusEmptyState(
        title: 'No Registered Mobawi Products',
        description: 'Ensure product catalogs are synced inside the central database registry.',
        icon: Icons.inventory_2_outlined,
        actionLabel: 'Refresh Product Catalog',
        onAction: () => _loadProducts(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MOBAWI PRODUCT PORTFOLIO', style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: 4),
          Text('Operational health metrics and release versions for active ERP components.', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 32),

          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 3 : 2,
            shrinkWrap: true,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 1.4,
            physics: const NeverScrollableScrollPhysics(),
            children: _products.map((p) => _buildProductCard(p)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(dynamic p) {
    final name = p['name'] ?? 'ERP Module';
    final version = p['version'] ?? 'v1.0.0';
    final activeUsers = p['active_users'] ?? 0;
    final uptime = p['uptime'] ?? '100.00';
    final errors = p['errors'] ?? 0;

    return NexusCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: Theme.of(context).textTheme.headlineMedium),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: NexusTheme.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: NexusTheme.accent.withValues(alpha: 0.3)),
                ),
                child: Text(version, style: const TextStyle(color: NexusTheme.accent, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricCol('Uptime', '$uptime%'),
              _buildMetricCol('Active Clients', '$activeUsers'),
              _buildMetricCol('Daily Errors', '$errors'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: NexusTheme.textMuted)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: NexusTheme.textPrimary)),
      ],
    );
  }
}
