import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/kiosk_services.dart';

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BillService>().loadBills();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Utility Bills')),
      body: Consumer<BillService>(
        builder: (context, billService, child) {
          if (billService.bills.isEmpty) return const Center(child: Text('No bills found.'));
          
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: billService.bills.length,
            itemBuilder: (context, index) {
              final bill = billService.bills[index];
              return Card(
                child: ListTile(
                  title: Text(bill.name),
                  subtitle: Text('Current Balance: KES ${bill.balance.toStringAsFixed(0)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.green),
                        onPressed: () => _updateBalance(context, bill, true),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => _updateBalance(context, bill, false),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _updateBalance(BuildContext context, dynamic bill, bool isAdding) {
    final amtController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAdding ? 'Top-up ${bill.name}' : 'Use from ${bill.name}'),
        content: TextField(
          controller: amtController,
          decoration: const InputDecoration(labelText: 'Amount'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (amtController.text.isNotEmpty) {
                final double amount = double.parse(amtController.text);
                final double newBalance = isAdding 
                    ? bill.balance + amount 
                    : bill.balance - amount;
                context.read<BillService>().updateBalance(bill.id!, newBalance);
                Navigator.pop(context);
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
