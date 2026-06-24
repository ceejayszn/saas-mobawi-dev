import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/menu_provider.dart';
import '../../widgets/custom_widgets.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Management'),
        actions: [
          IconButton(
            onPressed: () => _showAddDialog(context),
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
        ],
      ),
      body: Consumer<MenuProvider>(
        builder: (context, menu, child) {
          if (menu.isLoading) return const Center(child: CircularProgressIndicator());
          
          if (menu.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('No items in your menu yet', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Add First Item',
                    width: 200,
                    onTap: () => _showAddDialog(context),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemCount: menu.items.length,
            itemBuilder: (context, index) {
              final item = menu.items[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.fastfood_rounded, color: Theme.of(context).primaryColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 1.2),
                          ),
                          Text(
                            'KES ${item.price.toStringAsFixed(0)}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: item.isActive,
                            activeThumbColor: Theme.of(context).primaryColor,
                            onChanged: (val) => menu.toggleStatus(item),
                          ),
                        ),
                        Text(
                          item.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 10,
                            color: item.isActive ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Add New Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Item Name (e.g. Ugali Nyama)',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              decoration: InputDecoration(
                hintText: 'Price (KES)',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 8),
            child: PrimaryButton(
              label: 'SAVE ITEM',
              width: 120,
              onTap: () {
                if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                  context.read<MenuProvider>().addMenuItem(
                    nameController.text,
                    double.parse(priceController.text),
                  );
                  Navigator.pop(context);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

