import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/kiosk_services.dart';
import '../../models/kiosk_models.dart';

class POSScreenV2 extends StatefulWidget {
  const POSScreenV2({super.key});

  @override
  State<POSScreenV2> createState() => _POSScreenV2State();
}

class _POSScreenV2State extends State<POSScreenV2> {
  @override
  void initState() {
    super.initState();
    context.read<SalesService>().loadItems();
    context.read<SalesService>().loadDailySales();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tap to Sell'),
        actions: [
          Consumer<SalesService>(
            builder: (context, sales, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Center(
                  child: Text(
                    'DAILY: KES ${sales.dailySales.fold(0.0, (sum, s) => sum + s.total).toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<SalesService>(
        builder: (context, sales, child) {
          if (sales.isLoading) return const Center(child: CircularProgressIndicator());
          
          return Column(
            children: [
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: sales.items.length,
                  itemBuilder: (context, index) {
                    final item = sales.items[index];
                    return _TapButton(
                      label: item.name,
                      price: item.price,
                      onTap: () {
                        sales.addToCart(item);
                        Feedback.forTap(context);
                      },
                      onLongPress: () {
                        _showEditProductDialog(context, item, sales);
                      },
                    );
                  },
                ),
              ),
              if (sales.cart.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 150),
                        child: ListView(
                          shrinkWrap: true,
                          children: sales.cart.entries.map((entry) {
                            return ListTile(
                              dense: false,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              title: Text(
                                '${entry.value}×  ${entry.key.name}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'KES ${(entry.key.price * entry.value).toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1B5E20)),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle, color: Colors.red, size: 28),
                                    onPressed: () => sales.removeFromCart(entry.key),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('KES ${sales.cartTotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20)),
                          onPressed: () async {
                            await sales.checkout();
                            if (context.mounted) {
                              context.read<SummaryService>().refreshSummary();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Order Confirmed!'), backgroundColor: Colors.green),
                              );
                            }
                          },
                          child: const Text('CONFIRM ORDER', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showEditProductDialog(BuildContext context, KioskItem item, SalesService sales) {
    final nameCtrl = TextEditingController(text: item.name);
    final priceCtrl = TextEditingController(text: item.price.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Edit Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Product Name')),
            TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price (KES)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newName = nameCtrl.text;
              final newPrice = double.tryParse(priceCtrl.text) ?? item.price;
              if (newName.isNotEmpty && item.id != null) {
                await sales.updateMenuItem(item.id!, newName, newPrice);
                if (context.mounted) Navigator.pop(c);
              }
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }
}

class _TapButton extends StatelessWidget {
  final String label;
  final double price;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _TapButton({required this.label, required this.price, required this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('KES ${price.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFF1B5E20), shape: BoxShape.circle),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}
