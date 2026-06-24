import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/kiosk_services.dart';

class ProductionScreen extends StatefulWidget {
  const ProductionScreen({super.key});

  @override
  State<ProductionScreen> createState() => _ProductionScreenState();
}

class _ProductionScreenState extends State<ProductionScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SalesService>().loadItems();
    context.read<ProductionService>().loadDailyProduction();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Production Tracker'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'add') {
                _showAddItemDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'add', child: Text('Add New Product')),
            ],
          )
        ],
      ),
      body: Consumer2<SalesService, ProductionService>(
        builder: (context, sales, prod, child) {
          if (sales.isLoading) return const Center(child: CircularProgressIndicator());
          
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: sales.items.length,
            itemBuilder: (context, index) {
              final item = sales.items[index];
              final produced = prod.getProducedCount(item.id!);
              final sold = sales.dailySales
                  .where((s) => s.itemId == item.id)
                  .fold(0, (sum, s) => sum + s.quantity);
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${index + 1}. ${item.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () => _showAddProduction(context, item),
                                icon: const Icon(Icons.add),
                                label: const Text('Record Cooking'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_vert),
                                tooltip: 'Manage Product',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (c) => AlertDialog(
                                      title: Text('Manage ${item.name}'),
                                      content: const Text('Choose whether you want to edit this product\'s details or permanently delete it.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(c);
                                            _showEditItemDialog(context, item);
                                          },
                                          child: const Text('Edit Details'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(c);
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (dc) => AlertDialog(
                                                title: const Text('Permanently Delete?'),
                                                content: Text('Are you sure you want to permanently delete ${item.name}? This action cannot be undone.'),
                                                actions: [
                                                  TextButton(onPressed: () => Navigator.pop(dc, false), child: const Text('Cancel')),
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(dc, true),
                                                    child: const Text('Permanently Delete', style: TextStyle(color: Colors.red)),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirm == true && context.mounted) {
                                              context.read<SalesService>().deleteMenuItem(item.id!);
                                            }
                                          },
                                          child: const Text('Permanently Delete', style: TextStyle(color: Colors.red)),
                                        ),
                                        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(label: 'Produced', value: '$produced', color: Colors.blue),
                          _StatItem(label: 'Sold', value: '$sold', color: Colors.green),
                          _StatItem(label: 'Balance', value: '${produced - sold}', color: Colors.orange),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Price: KES ${item.price.toStringAsFixed(0)}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                            Text('Cooked: KES ${(produced * item.price).toStringAsFixed(0)}', style: TextStyle(fontSize: 11, color: Colors.blue.shade700, fontWeight: FontWeight.w600)),
                            Text('Sales: KES ${(sold * item.price).toStringAsFixed(0)}', style: TextStyle(fontSize: 11, color: Colors.green.shade700, fontWeight: FontWeight.w600)),
                            Text('Rem: KES ${((produced - sold) * item.price).toStringAsFixed(0)}', style: TextStyle(fontSize: 11, color: Colors.orange.shade700, fontWeight: FontWeight.w600)),
                          ],
                        ),
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

  void _showAddProduction(BuildContext context, dynamic item) {
    final qtyController = TextEditingController();
    String session = 'morning';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Record ${item.name} Cooking'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: qtyController,
                decoration: const InputDecoration(labelText: 'Quantity Produced'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Session: '),
                  ChoiceChip(
                    label: const Text('Morning'),
                    selected: session == 'morning',
                    onSelected: (val) => setDialogState(() => session = 'morning'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Evening'),
                    selected: session == 'evening',
                    onSelected: (val) => setDialogState(() => session = 'evening'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (qtyController.text.isNotEmpty) {
                  context.read<ProductionService>().addProduction(
                    item.id,
                    int.parse(qtyController.text),
                    session,
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
  void _showAddItemDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Product Name')),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Default Price'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                context.read<SalesService>().addMenuItem(
                  nameController.text,
                  double.parse(priceController.text),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save Product'),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(BuildContext context, dynamic item) {
    final nameController = TextEditingController(text: item.name);
    final priceController = TextEditingController(text: item.price.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${item.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Product Name')),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Default Price'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                context.read<SalesService>().updateMenuItem(
                  item.id,
                  nameController.text,
                  double.parse(priceController.text),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
