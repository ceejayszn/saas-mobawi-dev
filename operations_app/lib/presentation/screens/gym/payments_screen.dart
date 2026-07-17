import 'package:flutter/material.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final _amountController = TextEditingController();
  final _memberIdController = TextEditingController();
  final _notesController = TextEditingController();
  String _paymentMethod = 'M-Pesa';

  void _processPayment() {
    final amount = _amountController.text.trim();
    final memberId = _memberIdController.text.trim();
    if (amount.isEmpty || memberId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out Member ID and Amount')),
      );
      return;
    }

    final receiptNo = 'REC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Complete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Receipt No: $receiptNo'),
            Text('Member ID: $memberId'),
            Text('Amount Paid: \$$amount'),
            Text('Method: $_paymentMethod'),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.picture_as_pdf, color: Colors.red),
                SizedBox(width: 8),
                Text('PDF Receipt Generated', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _amountController.clear();
              _memberIdController.clear();
              _notesController.clear();
            },
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Print receipt action simulation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Receipt sent to printer...')),
              );
            },
            child: const Text('Print Receipt'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Process Gym Payment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Collect Fees', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextFormField(
              controller: _memberIdController,
              decoration: const InputDecoration(
                labelText: 'Member ID *',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (\$) *',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Text('Select Payment Method', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _paymentMethod,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: ['M-Pesa', 'Cash', 'Card', 'Bank Transfer']
                  .map((method) => DropdownMenuItem(value: method, child: Text(method)))
                  .toList(),
              onChanged: (value) => setState(() => _paymentMethod = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Payment Notes / Reference Code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: SizedBox(
                width: 250,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.check),
                  label: const Text('Submit Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
