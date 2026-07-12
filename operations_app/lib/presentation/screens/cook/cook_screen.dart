import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import '../../../data/models/outside_order.dart';

class CookScreen extends StatefulWidget {
  const CookScreen({super.key});

  @override
  State<CookScreen> createState() => _CookScreenState();
}

class _CookScreenState extends State<CookScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOutsideOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitchen Display'),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/logo.png'),
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orders, child) {
          // In the kitchen, we show Pending and Preparing orders
          // pendingOutsideOrders from provider contains 'Pending'
          // We might need to modify provider to load 'Preparing' as well, or just show pending for now
          // Actually, let's just fetch all uncompleted orders and filter locally for the kitchen.
          
          List<OutsideOrder> activeOrders = [
            ...orders.pendingOutsideOrders,
          ];

          if (activeOrders.isEmpty) {
            return const Center(child: Text('No active orders in the kitchen.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeOrders.length,
            itemBuilder: (context, index) {
              final order = activeOrders[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(order.customerName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            Text('Time: ${DateFormat('HH:mm').format(order.createdAt)}', style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 8),
                            Text('Status: ${order.status}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          // Complete order / Mark as Ready
                          await context.read<OrderProvider>().updateOutsideOrderStatus(order.id!, 'Ready');
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('Mark Ready'),
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
}
