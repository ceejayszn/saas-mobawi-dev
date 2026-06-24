import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../services/kiosk_services.dart';
import '../../../models/kiosk_models.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesService>().loadDailySales();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<SalesService>().loadDailySales();
            },
          )
        ],
      ),
      body: Consumer<SalesService>(
        builder: (context, salesService, child) {
          final orders = salesService.dailyOrders;

          if (orders.isEmpty) {
            return const Center(child: Text('No orders found for today.'));
          }

          return ListView.builder(
            itemCount: orders.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final order = orders[index];
              final isPaid = order.status.toLowerCase() == 'paid';
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    'Order #${order.sequenceId}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Total: KES ${order.total.toStringAsFixed(2)}'),
                      Text('Cashier: ${order.cashierName}'),
                      Text('Payment: ${order.paymentMethod.toUpperCase()}'),
                      Text(DateFormat('hh:mm a • MMM dd, yyyy').format(order.createdAt)),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(
                      order.status.toUpperCase(),
                      style: TextStyle(
                        color: isPaid ? Colors.green[800] : Colors.orange[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: isPaid ? Colors.green[50] : Colors.orange[50],
                  ),
                  onTap: () {
                    // Show order details
                    _showOrderDetails(context, order, salesService);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showOrderDetails(BuildContext context, KioskOrder order, SalesService salesService) async {
    final sales = await salesService.getOrderSales(order.sequenceId);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Order Details - ${order.sequenceId}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: sales.length,
                  itemBuilder: (context, idx) {
                    final sale = sales[idx];
                    // Find item name
                    final item = salesService.items.firstWhere(
                      (i) => i.id == sale.itemId,
                      orElse: () => KioskItem(name: 'Item #${sale.itemId}', price: sale.total / sale.quantity),
                    );
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.name),
                      subtitle: Text('${sale.quantity} x KES ${item.price.toStringAsFixed(0)}'),
                      trailing: Text('KES ${sale.total.toStringAsFixed(0)}'),
                    );
                  },
                ),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Grand Total', style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Text(
                  'KES ${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
