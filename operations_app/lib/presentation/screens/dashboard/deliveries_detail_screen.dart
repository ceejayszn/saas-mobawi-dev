import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/report_provider.dart';
import '../../widgets/global_header.dart';
import 'package:intl/intl.dart';

class DeliveriesDetailScreen extends StatefulWidget {
  const DeliveriesDetailScreen({super.key});

  @override
  State<DeliveriesDetailScreen> createState() => _DeliveriesDetailScreenState();
}

class _DeliveriesDetailScreenState extends State<DeliveriesDetailScreen> {
  String _searchQuery = '';
  final String _selectedStatusFilter = 'All'; // 'All', 'Delivering', 'Completed'
  final String _selectedSort =
      'Time (Newest)'; // 'Time (Newest)', 'Revenue (Highest)'

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<SaleProvider>();
    final reportProvider = context.watch<ReportProvider>();

    // Consolidate deliveries
    final activeDeliveries = orderProvider.deliveringSales;
    final completedDeliveries = orderProvider
        .paidSales; // assuming paid outside sales are completed deliveries

    final allDeliveries = [...activeDeliveries, ...completedDeliveries];

    // Filter
    List<dynamic> filteredDeliveries = allDeliveries.where((del) {
      final matchesSearch =
          (del.customerName ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (del.location ?? '').toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesStatus = true;
      if (_selectedStatusFilter == 'Delivering') {
        matchesStatus = del.status == 'Delivering';
      } else if (_selectedStatusFilter == 'Completed') {
        matchesStatus = del.status == 'Paid';
      }

      return matchesSearch && matchesStatus;
    }).toList();

    // Sort
    if (_selectedSort == 'Time (Newest)') {
      filteredDeliveries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_selectedSort == 'Revenue (Highest)') {
      filteredDeliveries.sort((a, b) => b.amountPrice.compareTo(a.amountPrice));
    }

    final double amountFilteredRevenue = filteredDeliveries.fold(
      0.0,
      (sum, d) => sum + d.amountPrice,
    );

    return Scaffold(
      appBar: const GlobalHeader(
        title: 'Deliveries Detail',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Search input placed above the cards
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search customer or address...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),

          // Statistics
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Revenue',
                        'KES ${reportProvider.deliveryRevenue.toStringAsFixed(0)}',
                        Icons.delivery_dining_rounded,
                        Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Active Deliveries',
                        '${activeDeliveries.length}',
                        Icons.local_shipping_rounded,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Completed Today',
                        '${completedDeliveries.length}',
                        Icons.check_circle_outline_rounded,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'All Runs Today',
                        '${allDeliveries.length}',
                        Icons.explore_rounded,
                        Colors.teal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Total Bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtered Revenue: KES ${amountFilteredRevenue.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontFamily: 'Helvetica',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '${filteredDeliveries.length} delivery(ies)',
                  style: TextStyle(
                    fontFamily: 'Helvetica',
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Activity Timeline list
          Expanded(
            child: filteredDeliveries.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredDeliveries.length,
                    itemBuilder: (context, index) {
                      final del = filteredDeliveries[index];
                      final isDelivering = del.status == 'Delivering';
                      final timeStr = DateFormat(
                        'hh:mm a',
                      ).format(del.createdAt);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isDelivering
                                          ? Colors.blue.shade50
                                          : Colors.green.shade50,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isDelivering
                                          ? Icons.local_shipping_rounded
                                          : Icons.check_circle_outline_rounded,
                                      color: isDelivering
                                          ? Colors.blue
                                          : Colors.green,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    timeStr,
                                    style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 10,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Run #${del.id ?? index}',
                                          style: const TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          'KES ${del.amountPrice.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Client: ${del.customerName}',
                                      style: const TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Destination: ${del.location}',
                                      style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDelivering
                                            ? Colors.blue.shade50
                                            : Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isDelivering
                                            ? 'OUT FOR DELIVERY'
                                            : 'COMPLETED & PAID',
                                        style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 10,
                                          color: isDelivering
                                              ? Colors.blue
                                              : Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Helvetica',
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 11,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_shipping_rounded,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            'No deliveries found',
            style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 16,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Check status filters or dispatch new deliveries.',
            style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
