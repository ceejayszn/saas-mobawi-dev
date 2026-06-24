import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/kiosk_services.dart';
import '../../models/kiosk_models.dart';

class ExpensesScreenV2 extends StatefulWidget {
  const ExpensesScreenV2({super.key});

  @override
  State<ExpensesScreenV2> createState() => _ExpensesScreenV2State();
}

class _ExpensesScreenV2State extends State<ExpensesScreenV2> {
  @override
  void initState() {
    super.initState();
    context.read<SupplierService>().loadSuppliers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Suppliers & Shops')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSupplier(context),
        child: const Icon(Icons.add_business),
      ),
      body: Consumer<SupplierService>(
        builder: (context, supplierService, child) {
          if (supplierService.suppliers.isEmpty) return const Center(child: Text('No suppliers yet. Tap + to add.'));
          
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: supplierService.suppliers.length,
            itemBuilder: (context, index) {
              final supplier = supplierService.suppliers[index];
              return Card(
                child: ListTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => SupplierExpensesScreen(supplier: supplier)));
                  },
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF1B5E20).withOpacity(0.1),
                    child: const Icon(Icons.store, color: Color(0xFF1B5E20)),
                  ),
                  title: Text(supplier.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddSupplier(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Supplier/Shop'),
        content: TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Supplier Name (e.g. Steam Shop)')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<SupplierService>().addSupplier(nameController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class SupplierExpensesScreen extends StatefulWidget {
  final Supplier supplier;
  const SupplierExpensesScreen({super.key, required this.supplier});

  @override
  State<SupplierExpensesScreen> createState() => _SupplierExpensesScreenState();
}

class _SupplierExpensesScreenState extends State<SupplierExpensesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ExpenseService>().loadDailyExpenses(supplierId: widget.supplier.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.supplier.name} Expenses')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpense(context),
        child: const Icon(Icons.add),
      ),
      body: Consumer<ExpenseService>(
        builder: (context, expenseService, child) {
          if (expenseService.dailyExpenses.isEmpty) return const Center(child: Text('No expenses recorded for this supplier today.'));
          
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: expenseService.dailyExpenses.length,
            itemBuilder: (context, index) {
              final exp = expenseService.dailyExpenses[index];
              final isSettled = exp.status == 'settled';

              return Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(exp.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Paid: KES ${exp.settledAmount.toStringAsFixed(0)} of ${exp.amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12)),
                        Text('Method: ${exp.paymentMethod.toUpperCase()}', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSettled ? Colors.green.shade100 : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isSettled ? 'SETTLED' : 'UNSETTLED',
                            style: TextStyle(
                              color: isSettled ? Colors.green.shade800 : Colors.red.shade800,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!isSettled) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                            tooltip: 'Pay Off Balance',
                            onPressed: () => _showSettleExpenseDialog(context, exp),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showSettleExpenseDialog(BuildContext context, Expense exp) {
    final payController = TextEditingController();
    String method = 'cash';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Settle ${exp.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Outstanding balance: KES ${(exp.amount - exp.settledAmount).toStringAsFixed(0)}'),
              const SizedBox(height: 8),
              TextField(
                controller: payController,
                decoration: const InputDecoration(labelText: 'Amount to Pay (KES)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Method: '),
                  ChoiceChip(
                    label: const Text('Cash'),
                    selected: method == 'cash',
                    onSelected: (val) => setDialogState(() => method = 'cash'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('M-Pesa'),
                    selected: method == 'mpesa',
                    onSelected: (val) => setDialogState(() => method = 'mpesa'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (payController.text.isNotEmpty) {
                  context.read<ExpenseService>().settleExpense(
                    exp.id!,
                    double.parse(payController.text),
                    method,
                    supplierId: widget.supplier.id,
                  );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Pay'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddExpense(BuildContext context) {
    final nameController = TextEditingController();
    final amtController = TextEditingController();
    bool withSettlement = true;
    String method = 'cash';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New Expense'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Item Name')),
                TextField(controller: amtController, decoration: const InputDecoration(labelText: 'Amount (KES)'), keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('With Settlement?'),
                    Switch(
                      value: withSettlement,
                      onChanged: (val) => setDialogState(() => withSettlement = val),
                    ),
                  ],
                ),
                if (withSettlement) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Payment Method: '),
                      ChoiceChip(
                        label: const Text('Cash'),
                        selected: method == 'cash',
                        onSelected: (val) => setDialogState(() => method = 'cash'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('M-Pesa'),
                        selected: method == 'mpesa',
                        onSelected: (val) => setDialogState(() => method = 'mpesa'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && amtController.text.isNotEmpty) {
                  final amt = double.parse(amtController.text);
                  context.read<ExpenseService>().addExpense(
                    nameController.text,
                    amt,
                    supplierId: widget.supplier.id,
                    status: withSettlement ? 'settled' : 'unsettled',
                    paymentMethod: method,
                    settledAmount: withSettlement ? amt : 0.0,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
