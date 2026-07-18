import 'package:flutter/material.dart' ;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/product_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/report_provider.dart';
import '../../../data/models/product.dart';
import '../../widgets/custom_widgets.dart';

import '../../widgets/global_header.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  @override
  Widget build(BuildContext context) {
    final menu = Provider.of<ProductProvider>(context);
    final sale = Provider.of<SaleProvider>(context);
    final allItems = menu.items;

    return Scaffold(
      appBar: const GlobalHeader(title: 'New Sale', showBackButton: false),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isSmallScreen = constraints.maxWidth < 700;

          if (isSmallScreen) {
            return Column(
              children: [
                Expanded(child: _buildMenuGrid(menu, sale)),
                _buildCartSummary(context, sale, allItems),
              ],
            );
          }

          return Row(
            children: [
              Expanded(flex: 3, child: _buildMenuGrid(menu, sale)),
              Container(
                width: 350,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(left: BorderSide(color: Colors.grey[200]!)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(-5, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildCartHeader(context, sale),
                    Expanded(child: _buildCartList(sale, allItems)),
                    _buildCartFooter(context, sale, allItems),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuGrid(ProductProvider menu, SaleProvider sale) {
    if (menu.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (menu.activeItems.isEmpty) {
      return const Center(child: Text('No active items in menu'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: menu.activeItems.length,
      itemBuilder: (context, index) {
        final item = menu.activeItems[index];
        return ProductButton(
          name: item.name,
          price: item.price,
          onTap: () {
            sale.addToCart(item);
            Feedback.forTap(context);
          },
        );
      },
    );
  }

  Widget _buildCartHeader(BuildContext context, SaleProvider sale) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Sale Details',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${sale.cart.length} items',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(SaleProvider sale, List<Product> allItems) {
    if (sale.cart.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Your cart is empty',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: sale.cart.length,
      itemBuilder: (context, index) {
        final itemId = sale.cart.keys.elementAt(index);
        final qty = sale.cart[itemId]!;
        final item = allItems.firstWhere((i) => i.id == itemId);
        return CartItemTile(
          name: item.name,
          price: item.price,
          quantity: qty,
          onAdd: () => sale.addToCart(item),
          onRemove: () => sale.removeFromCart(item),
          onDelete: () => sale.clearItem(item),
        );
      },
    );
  }

  Widget _buildCartFooter(
    BuildContext context,
    SaleProvider sale,
    List<Product> allItems,
  ) {
    final amount = sale.calculateTotal(allItems);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              Text(
                'KES ${amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'PROCESS PAYMENT',
                  onTap: sale.cart.isEmpty
                      ? null
                      : () => _showPayDialog(context, sale, allItems),
                  color: const Color(0xFF2E7D32),
                  icon: Icons.check_circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  label: 'FREQUENT CUST',
                  onTap: sale.cart.isEmpty
                      ? null
                      : () => _showFrequentCustomerDialog(
                          context,
                          sale,
                          allItems,
                        ),
                  color: Colors.blueAccent,
                  icon: Icons.people_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: sale.cart.isEmpty ? null : () => sale.clearCart(),
            child: const Text(
              'CANCEL ORDER',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(
    BuildContext context,
    SaleProvider sale,
    List<Product> allItems,
  ) {
    if (sale.cart.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${sale.amountItemCount} items',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  'KES ${sale.calculateTotal(allItems).toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          PrimaryButton(
            label: 'PAY',
            width: 150,
            onTap: () => _bottomSheetCart(context, sale, allItems),
            icon: Icons.shopping_basket,
          ),
        ],
      ),
    );
  }

  void _bottomSheetCart(
    BuildContext context,
    SaleProvider sale,
    List<Product> allItems,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildCartHeader(context, sale),
            Expanded(child: _buildCartList(sale, allItems)),
            _buildCartFooter(context, sale, allItems),
          ],
        ),
      ),
    );
  }

  void _showPayDialog(
    BuildContext context,
    SaleProvider sale,
    List<Product> allItems,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Complete Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose payment method'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _paymentOption(
                    context,
                    sale,
                    'Cash',
                    Icons.money,
                    Colors.green,
                    allItems,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _paymentOption(
                    context,
                    sale,
                    'M-Pesa',
                    Icons.phone_android,
                    Colors.blue,
                    allItems,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentOption(
    BuildContext context,
    SaleProvider sale,
    String type,
    IconData icon,
    Color color,
    List<Product> allItems,
  ) {
    return InkWell(
      onTap: () async {
        String finalMethod = type;
        if (type == 'M-Pesa') {
          final receipt = await _promptForReceipt(context);
          if (receipt == null) return; // Cancelled
          finalMethod = 'M-Pesa (Receipt: $receipt)';
        }

        final success = await sale.processOrder(finalMethod, allItems);
        if (success) {
          if (context.mounted) context.read<ReportProvider>().refreshReports();
          final amount = sale.calculateTotal(allItems);
          final receiptText =
              "EUTON HOTEL RECEIPT\n------------------\nMethod: $finalMethod\nDate: ${DateTime.now()}\nTotal: KES $amount\nThank you!";

          if (context.mounted) Navigator.pop(context); // Close dialog
          if (context.mounted && ModalRoute.of(context)?.settings.name != '/') {
            // If we opened this from bottom sheet, we might need to pop again
          }

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green,
                content: Text('Sale Successfully Paid via $type!'),
              ),
            );
          }

          Share.share(receiptText);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              type,
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _promptForReceipt(BuildContext context) async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('M-Pesa Receipt'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            hintText: 'Enter receipt number',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showFrequentCustomerDialog(
    BuildContext context,
    SaleProvider sale,
    List<Product> allItems,
  ) {
    final nameCtrl = TextEditingController();
    final officeCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Frequent Customer Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Customer Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: officeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Office Name / Address',
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty) return;

              // We simulate addToOutsideCart for all cart items since Frequent Customer goes through Outside Orders logic
              sale.clearOutsideCart();
              sale.cart.forEach((itemId, qty) {
                final item = allItems.firstWhere((i) => i.id == itemId);
                for (int i = 0; i < qty; i++) {
                  sale.addToOutsideCart(item);
                }
              });

              final locStr =
                  '${officeCtrl.text.trim()} | ${phoneCtrl.text.trim()}';
              final success = await sale.createSale(
                customerName: nameCtrl.text.trim(),
                location: locStr,
                allItems: allItems,
              );

              if (success) {
                sale.clearCart();
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context); // close bottom sheet if open
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sent to Kitchen for Frequent Customer'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                }
              }
            },
            child: const Text('Send to Kitchen'),
          ),
        ],
      ),
    );
  }
}
