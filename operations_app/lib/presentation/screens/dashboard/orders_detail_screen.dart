import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/sale_provider.dart';
import '../../widgets/global_header.dart';
import 'package:intl/intl.dart';

class OrdersDetailScreen extends StatefulWidget {
  const OrdersDetailScreen({super.key});

  @override
  State<OrdersDetailScreen> createState() => _OrdersDetailScreenState();
}

class _OrdersDetailScreenState extends State<OrdersDetailScreen> {
  String _searchQuery = '';
  final String _selectedFilter = 'All'; // 'All', 'Pending', 'Delivering', 'Paid'
  final String _selectedSort = 'Time (Newest)'; // 'Time (Newest)', 'Amount (Highest)'

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<SaleProvider>();

    // Consolidating all sales to allow comprehensive search and filtering
    final allOrders = [
      ...orderProvider.pendingSales,
      ...orderProvider.readySales,
      ...orderProvider.deliveringSales,
      ...orderProvider.paidSales,
    ];

    // Filter
    List<dynamic> filteredOrders = allOrders.where((sale) {
      final matchesSearch =
          (sale.customerName ?? '').toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          (sale.location ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          sale.id.toString().contains(_searchQuery);

      bool matchesFilter = true;
      if (_selectedFilter == 'Pending') {
        matchesFilter = sale.status == 'Pending' || sale.status == 'Ready';
      } else if (_selectedFilter == 'Delivering') {
        matchesFilter = sale.status == 'Delivering';
      } else if (_selectedFilter == 'Paid') {
        matchesFilter = sale.status == 'Paid';
      }

      return matchesSearch && matchesFilter;
    }).toList();

    // Sort
    if (_selectedSort == 'Time (Newest)') {
      filteredOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_selectedSort == 'Amount (Highest)') {
      filteredOrders.sort((a, b) => b.amountPrice.compareTo(a.amountPrice));
    }

    final double amountFilteredAmount = filteredOrders.fold(
      0.0,
      (sum, o) => sum + o.amountPrice,
    );

    return Scaffold(
      appBar: const GlobalHeader(title: 'Orders Detail', showBackButton: true),
      body: Column(
        children: [
          // Search input placed above the cards
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search customer name or location...',
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

          // Statistics section
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
                        'Total Orders',
                        '${allOrders.length}',
                        Icons.receipt_long_rounded,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Pending/Ready',
                        '${orderProvider.pendingSales.length + orderProvider.readySales.length}',
                        Icons.pending_actions_rounded,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Delivering',
                        '${orderProvider.deliveringSales.length}',
                        Icons.delivery_dining_rounded,
                        Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Paid & Settled',
                        '${orderProvider.paidSales.length}',
                        Icons.check_circle_rounded,
                        Colors.green,
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
                  'Total Amount: KES ${amountFilteredAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontFamily: 'Helvetica',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '${filteredOrders.length} sale(s)',
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

          // Timeline / Activity List
          Expanded(
            child: filteredOrders.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final sale = filteredOrders[index];
                      final isReady = sale.status == 'Ready';
                      final isDelivering = sale.status == 'Delivering';
                      final isPaid = sale.status == 'Paid';

                      Color statusColor = Colors.orange;
                      if (isReady) statusColor = Colors.blue;
                      if (isDelivering) statusColor = Colors.purple;
                      if (isPaid) statusColor = Colors.green;

                      final timeStr = DateFormat(
                        'hh:mm a',
                      ).format(sale.createdAt);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 10.0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.receipt_long_rounded,
                                      color: statusColor,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    timeStr,
                                    style: TextStyle(
                                      fontFamily: 'Helvetica',
                                      fontSize: 8,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Sale #${sale.id ?? index}',
                                          style: const TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          'KES ${sale.amountPrice.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontWeight: FontWeight.w900,
                                            fontSize: 13,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Customer: ${sale.customerName}',
                                      style: const TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Location: ${sale.location}',
                                      style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 10,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 1.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        sale.status.toUpperCase(),
                                        style: TextStyle(
                                          fontFamily: 'Helvetica',
                                          fontSize: 8,
                                          color: statusColor,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Helvetica',
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: Colors.black,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 9,
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
            Icons.receipt_long_rounded,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            'No sales found',
            style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 16,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Check filters or create new sales from the POS.',
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
