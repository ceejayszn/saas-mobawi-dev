import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/global_header.dart';

class ExpensesDetailScreen extends StatefulWidget {
  const ExpensesDetailScreen({super.key});

  @override
  State<ExpensesDetailScreen> createState() => _ExpensesDetailScreenState();
}

class _ExpensesDetailScreenState extends State<ExpensesDetailScreen> {
  String _searchQuery = '';
  final String _selectedAccountFilter = 'All';
  final String _selectedStatusFilter = 'All'; // 'All', 'Settled', 'Unsettled'
  final String _selectedSort =
      'Newest'; // 'Newest', 'Amount (Highest)', 'Amount (Lowest)'

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final allExpenses = expenseProvider.dailyExpenses;

    // Filter
    List<dynamic> filteredExpenses = allExpenses.where((exp) {
      final matchesSearch = exp.title.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesAccount =
          _selectedAccountFilter == 'All' ||
          exp.accountName == _selectedAccountFilter;
      final matchesStatus =
          _selectedStatusFilter == 'All' || exp.status == _selectedStatusFilter;
      return matchesSearch && matchesAccount && matchesStatus;
    }).toList();

    // Sort
    if (_selectedSort == 'Newest') {
      filteredExpenses.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    } else if (_selectedSort == 'Amount (Highest)') {
      filteredExpenses.sort((a, b) => b.amount.compareTo(a.amount));
    } else if (_selectedSort == 'Amount (Lowest)') {
      filteredExpenses.sort((a, b) => a.amount.compareTo(b.amount));
    }

    final double amountFilteredExpenses = filteredExpenses.fold(
      0.0,
      (sum, exp) => sum + exp.amount,
    );
    final double amountUnsettled = allExpenses
        .where((e) => e.status == 'Unsettled')
        .fold(0.0, (sum, e) => sum + e.amount);

    return Scaffold(
      appBar: const GlobalHeader(
        title: 'Expenses Detail',
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
                hintText: 'Search description...',
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
                        'Total Logged',
                        'KES ${expenseProvider.dailyExpenses.fold<double>(0, (sum, e) => sum + e.amount).toStringAsFixed(0)}',
                        Icons.money_off_rounded,
                        Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Unsettled',
                        'KES ${amountUnsettled.toStringAsFixed(0)}',
                        Icons.warning_amber_rounded,
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
                        'Accounts',
                        '${expenseProvider.accounts.length}',
                        Icons.folder_copy_rounded,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Total Logs',
                        '${expenseProvider.dailyExpenses.length}',
                        Icons.receipt_long_rounded,
                        Colors.teal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Total bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtered Total: KES ${amountFilteredExpenses.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontFamily: 'Helvetica',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '${filteredExpenses.length} log(s)',
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

          // Timeline of events / Daily activity list
          Expanded(
            child: filteredExpenses.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final exp = filteredExpenses[index];
                      final isSettled = exp.status == 'Settled';

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
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSettled
                                      ? Colors.green.shade50
                                      : Colors.red.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.shopping_bag_outlined,
                                  color: isSettled ? Colors.green : Colors.red,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exp.title,
                                      style: const TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Account: ${exp.accountName}',
                                      style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontSize: 10,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'KES ${exp.amount.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontFamily: 'Helvetica',
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                        color: isSettled
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isSettled
                                      ? const Color(0xFFE6F7DF)
                                      : const Color(0xFFFFF0C8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  exp.status.toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'Helvetica',
                                    color: isSettled
                                        ? const Color(0xFF5AB75A)
                                        : const Color(0xFFB57A00),
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
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
            Icons.folder_open_rounded,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            'No expenses found',
            style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 16,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Adjust search filters or log new expenses.',
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
