import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/report_provider.dart';
import '../../widgets/global_header.dart';

class SalesDetailScreen extends StatefulWidget {
  const SalesDetailScreen({super.key});

  @override
  State<SalesDetailScreen> createState() => _SalesDetailScreenState();
}

class _SalesDetailScreenState extends State<SalesDetailScreen> {
  String _searchQuery = '';
  final String _selectedFilter = 'All'; // 'All', 'Cash', 'M-Pesa'
  final String _selectedSort =
      'Time (Newest)'; // 'Time (Newest)', 'Amount (Highest)', 'Amount (Lowest)'

  // Mock list of sales transactions for high-quality production preview
  final List<Map<String, dynamic>> _mockTransactions = [
    {
      'id': 'TX1001',
      'time': '10:15 AM',
      'amount': 1500.0,
      'paymentMethod': 'M-Pesa',
      'items': '2x Chicken Biryani, 1x Soda',
      'status': 'Completed',
    },
    {
      'id': 'TX1002',
      'time': '10:45 AM',
      'amount': 850.0,
      'paymentMethod': 'Cash',
      'items': '1x Beef Pilau, 1x Water',
      'status': 'Completed',
    },
    {
      'id': 'TX1003',
      'time': '11:20 AM',
      'amount': 3200.0,
      'paymentMethod': 'M-Pesa',
      'items': '4x Fish Wet Fry, 4x Ugali',
      'status': 'Completed',
    },
    {
      'id': 'TX1004',
      'time': '12:05 PM',
      'amount': 600.0,
      'paymentMethod': 'Cash',
      'items': '2x Chapati, 1x Ndengu',
      'status': 'Completed',
    },
    {
      'id': 'TX1005',
      'time': '01:30 PM',
      'amount': 1800.0,
      'paymentMethod': 'M-Pesa',
      'items': '3x Chicken Wet Fry, 3x Ugali',
      'status': 'Completed',
    },
    {
      'id': 'TX1006',
      'time': '02:15 PM',
      'amount': 450.0,
      'paymentMethod': 'Cash',
      'items': '1x Githeri, 1x Tea',
      'status': 'Completed',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final report = context.watch<ReportProvider>();

    // Filter transactions
    List<Map<String, dynamic>> filteredList = _mockTransactions.where((tx) {
      final matchesSearch =
          tx['id'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          tx['items'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      final matchesFilter =
          _selectedFilter == 'All' || tx['paymentMethod'] == _selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();

    // Sort transactions
    if (_selectedSort == 'Time (Newest)') {
      // Keep original sale
    } else if (_selectedSort == 'Amount (Highest)') {
      filteredList.sort((a, b) => b['amount'].compareTo(a['amount']));
    } else if (_selectedSort == 'Amount (Lowest)') {
      filteredList.sort((a, b) => a['amount'].compareTo(b['amount']));
    }

    // Totals
    final double amountFilteredSales = filteredList.fold(
      0.0,
      (sum, tx) => sum + tx['amount'],
    );
    final int transactionCount = filteredList.length;

    return Scaffold(
      appBar: const GlobalHeader(title: 'Sales Details', showBackButton: true),
      body: Column(
        children: [
          // Search input placed above the cards
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search by transaction ID or items...',
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

          // Summary Statistics Section
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
                        'KES ${report.amountSales.toStringAsFixed(0)}',
                        Icons.monetization_on_rounded,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'M-Pesa Sales',
                        'KES ${report.mpesaIncome.toStringAsFixed(0)}',
                        Icons.phone_android_rounded,
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
                        'Cash Sales',
                        'KES ${report.cashOnHand.toStringAsFixed(0)}',
                        Icons.wallet_rounded,
                        Colors.teal,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Transactions',
                        '$transactionCount txs',
                        Icons.receipt_rounded,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Total Filtered Bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtered Total: KES ${amountFilteredSales.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontFamily: 'Helvetica',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '$transactionCount match(es)',
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

          // Daily Activity List / Timeline
          Expanded(
            child: filteredList.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final tx = filteredList[index];
                      final isMpesa = tx['paymentMethod'] == 'M-Pesa';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Timeline Node indicator
                              Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isMpesa
                                          ? Colors.blue.shade50
                                          : Colors.teal.shade50,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isMpesa
                                          ? Icons.phone_android_rounded
                                          : Icons.payments_rounded,
                                      color: isMpesa
                                          ? Colors.blue
                                          : Colors.teal,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    tx['time'],
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
                                          tx['id'],
                                          style: const TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          'KES ${tx['amount'].toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontFamily: 'Helvetica',
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      tx['items'],
                                      style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 13,
                                        color: Colors.grey.shade800,
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
                    fontSize: 16,
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
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'No sales transactions found',
            style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 16,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try altering your search or filters.',
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
