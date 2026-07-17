import 'package:flutter/material.dart';

class ProductsPOSScreen extends StatefulWidget {
  const ProductsPOSScreen({super.key});

  @override
  State<ProductsPOSScreen> createState() => _ProductsPOSScreenState();
}

class _ProductsPOSScreenState extends State<ProductsPOSScreen> {
  final List<Map<String, dynamic>> _cart = [];
  
  final List<Map<String, dynamic>> _products = [
    {'id': 'P-01', 'name': 'Mineral Water (500ml)', 'price': 1.00, 'stock': 120, 'category': 'Drinks'},
    {'id': 'P-02', 'name': 'Whey Protein Shake', 'price': 3.50, 'stock': 45, 'category': 'Supplements'},
    {'id': 'P-03', 'name': 'Natty Gym T-Shirt', 'price': 15.00, 'stock': 20, 'category': 'Apparel'},
    {'id': 'P-04', 'name': 'Lifting Straps', 'price': 8.00, 'stock': 15, 'category': 'Accessories'},
  ];

  double get _total => _cart.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      final index = _cart.indexWhere((item) => item['id'] == product['id']);
      if (index >= 0) {
        if (_cart[index]['quantity'] < product['stock']) {
          _cart[index]['quantity']++;
        }
      } else {
        _cart.add({...product, 'quantity': 1});
      }
    });
  }

  void _removeFromCart(Map<String, dynamic> item) {
    setState(() {
      final index = _cart.indexWhere((product) => product['id'] == item['id']);
      if (index >= 0) {
        if (_cart[index]['quantity'] > 1) {
          _cart[index]['quantity']--;
        } else {
          _cart.removeAt(index);
        }
      }
    });
  }

  void _checkout() {
    if (_cart.isEmpty) return;
    
    // Simulate updating inventory
    for (var cartItem in _cart) {
      final product = _products.firstWhere((p) => p['id'] == cartItem['id']);
      product['stock'] -= cartItem['quantity'];
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sale Complete'),
        content: Text('Processed sale for \$${_total.toStringAsFixed(2)} successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _cart.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Gym Store POS')),
      body: Row(
        children: [
          // Product List
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product['category'], style: TextStyle(color: colorScheme.secondary, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(product['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 8),
                          Text('\$${product['price'].toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)),
                          Text('Stock: ${product['stock']}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: product['stock'] > 0 ? () => _addToCart(product) : null,
                            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(36)),
                            icon: const Icon(Icons.add_shopping_cart, size: 16),
                            label: const Text('Add to Cart'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Cart Column
          Container(
            width: 320,
            color: Colors.grey[100],
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Active Cart', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const Divider(),
                Expanded(
                  child: _cart.isEmpty
                      ? const Center(child: Text('Cart is empty', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          itemCount: _cart.length,
                          itemBuilder: (context, index) {
                            final item = _cart[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(item['name'], maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Text('\$${item['price'].toStringAsFixed(2)} x ${item['quantity']}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(icon: const Icon(Icons.remove), onPressed: () => _removeFromCart(item)),
                                  IconButton(icon: const Icon(Icons.add), onPressed: () => _addToCart(item)),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('\$${_total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _cart.isEmpty ? null : _checkout,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    child: const Text('Checkout Sale', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
