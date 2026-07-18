import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/custom_widgets.dart';
import '../../theme/app_colors.dart';
import '../../widgets/global_header.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String?
  _selectedAccount; // null means show account list, otherwise show account details

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadDailyExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();

    return Scaffold(
      appBar: GlobalHeader(
        title: _selectedAccount == null
            ? 'Expense Accounts'
            : 'Account: $_selectedAccount',
        showBackButton: _selectedAccount != null,
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedAccount == null) ...[
            FloatingActionButton.extended(
              heroTag: 'new_account_fab',
              onPressed: () => _showAddAccountDialog(context),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.create_new_folder_rounded),
              label: const Text('New Account'),
            ),
            const SizedBox(height: 12),
          ],
          FloatingActionButton.extended(
            heroTag: 'log_expense_fab',
            onPressed: () => _showAddExpenseDialog(context),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_task_rounded),
            label: const Text('Log Expense'),
          ),
        ],
      ),
      body: PopScope(
        canPop: false,
      onPopInvokedWithResult: (didPop, result) {
          if (_selectedAccount != null) {
            setState(() => _selectedAccount = null);
            
          }
          
        },
        child: _selectedAccount == null
            ? _buildAccountList(provider)
            : _buildAccountDetails(provider, _selectedAccount!),
      ),
    );
  }

  Widget _buildAccountList(ExpenseProvider provider) {
    final accounts = provider.accounts;

    if (accounts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'No accounts created yet',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Create First Account',
              width: 220,
              onTap: () => _showAddAccountDialog(context),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final acc = accounts[index];
        final accExpenses = provider.dailyExpenses
            .where((e) => e.accountName == acc)
            .toList();
        final unsettledCount = accExpenses
            .where((e) => e.status == 'Unsettled')
            .length;
        final amountAmount = accExpenses.fold<double>(
          0,
          (sum, e) => sum + e.amount,
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryLightGreen,
              child: const Icon(
                Icons.folder_rounded,
                color: AppColors.primaryGreen,
              ),
            ),
            title: Text(
              acc,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            subtitle: Row(
              children: [
                Text(
                  '${accExpenses.length} logs',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
                if (unsettledCount > 0) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.orangeAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$unsettledCount Unsettled',
                      style: const TextStyle(
                        color: AppColors.orangeAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'KES ${amountAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              ],
            ),
            onTap: () => setState(() => _selectedAccount = acc),
          ),
        );
      },
    );
  }

  Widget _buildAccountDetails(ExpenseProvider provider, String accountName) {
    final accExpenses = provider.dailyExpenses
        .where((e) => e.accountName == accountName)
        .toList();

    if (accExpenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No expenses logged in "$accountName" today',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Add Expense Log',
              width: 220,
              onTap: () => _showAddExpenseDialog(context),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: accExpenses.length,
      itemBuilder: (context, index) {
        final exp = accExpenses[index];
        final isSettled = exp.status == 'Settled';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exp.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'KES ${exp.amount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _toggleStatus(context, provider, exp),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSettled
                          ? const Color(0xFFE6F7DF)
                          : const Color(0xFFFFF0C8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      exp.status.toUpperCase(),
                      style: TextStyle(
                        color: isSettled
                            ? const Color(0xFF5AB75A)
                            : const Color(0xFFB57A00),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleStatus(
    BuildContext context,
    ExpenseProvider provider,
    dynamic exp,
  ) {
    if (exp.id == null) return;
    final nextStatus = exp.status == 'Settled' ? 'Unsettled' : 'Settled';
    provider.updateExpenseStatus(exp.id!, nextStatus);
  }

  void _showAddAccountDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'New Expense Account',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Account Name (e.g. Gas Supplier)',
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<ExpenseProvider>().addAccount(
                  controller.text.trim(),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('CREATE'),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final provider = context.read<ExpenseProvider>();
    String tempAccount = _selectedAccount ?? provider.accounts.first;
    String tempStatus = 'Settled';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Log Expense',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: tempAccount,
                  decoration: InputDecoration(
                    labelText: 'Select Account',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: provider.accounts
                      .map(
                        (acc) => DropdownMenuItem(value: acc, child: Text(acc)),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => tempAccount = val);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'Description (e.g. 50L Water)',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    hintText: 'Amount (KES)',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Status:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => tempStatus = 'Settled'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: tempStatus == 'Settled'
                                  ? const Color(0xFFE6F7DF)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'SETTLED',
                              style: TextStyle(
                                color: tempStatus == 'Settled'
                                    ? const Color(0xFF5AB75A)
                                    : Colors.grey[600],
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setState(() => tempStatus = 'Unsettled'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: tempStatus == 'Unsettled'
                                  ? const Color(0xFFFFF0C8)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'UNSETTLED',
                              style: TextStyle(
                                color: tempStatus == 'Unsettled'
                                    ? const Color(0xFFB57A00)
                                    : Colors.grey[600],
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                final amt = double.tryParse(amountController.text);
                if (titleController.text.isNotEmpty && amt != null) {
                  provider.addExpense(
                    titleController.text,
                    amt,
                    accountName: tempAccount,
                    status: tempStatus,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('LOG'),
            ),
          ],
        ),
      ),
    );
  }
}
