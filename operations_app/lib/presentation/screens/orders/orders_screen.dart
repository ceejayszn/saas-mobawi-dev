import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/product.dart';
import '../../providers/product_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/report_provider.dart';

import '../../widgets/global_header.dart';
import '../../../data/models/sale.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SaleProvider>().loadSales();
      context.read<ProductProvider>().loadMenu();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showFrequentCustomersDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Consumer<SaleProvider>(
          builder: (context, provider, _) {
            final list = provider.frequentCustomers;
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Frequent Customers',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: list.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: Text(
                            'No customer history recorded yet',
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final customer = list[index];
                          final name =
                              customer['customer_name'] as String? ?? 'Unknown';
                          final lastLoc =
                              customer['last_location'] as String? ?? 'N/A';
                          final count = customer['amount_orders'] as int? ?? 0;
                          final spent = ((customer['amount_spent'] ?? 0) as num)
                              .toDouble();
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFE8F5E9),
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              'Last location: $lastLoc\nTotal sales: $count',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 12,
                              ),
                            ),
                            trailing: Text(
                              'KES ${spent.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                                fontSize: 15,
                              ),
                            ),
                            isThreeLine: true,
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'CLOSE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const GlobalHeader(
        title: 'Outside Orders',
        showBackButton: false,
      ),
      body: Container(
        color: const Color(0xFFF2F5FB),
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: theme.primaryColor,
                unselectedLabelColor: const Color(0xFFA8A8A8),
                indicatorColor: theme.primaryColor,
                indicatorWeight: 4,
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                tabs: const [
                  Tab(text: 'PENDING'),
                  Tab(text: 'DELIVERING'),
                  Tab(text: 'PAID'),
                ],
              ),
            ),
            Expanded(
              child: Consumer<SaleProvider>(
                builder: (context, sales, child) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOrdersList(
                        [
                          ...sales.pendingSales,
                          ...sales.readySales,
                        ]..sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now())),
                        emptyMessage: 'No pending or ready sales.',
                        onOrderTap: (sale) => _showPendingOrderAction(sale),
                      ),
                      _buildOrdersList(
                        sales.deliveringSales,
                        emptyMessage: 'No sales out for delivery.',
                        onOrderTap: (sale) =>
                            _showDeliveringOrderAction(sale),
                      ),
                      _buildOrdersList(
                        sales.paidSales,
                        emptyMessage: 'No paid sales.',
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
              heroTag: 'frequent_customers_fab',
              onPressed: _showFrequentCustomersDialog,
              elevation: 4,
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1B5E20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF1B5E20), width: 1.5),
              ),
              icon: const Icon(Icons.people_alt_rounded, size: 20),
              label: const Text(
                'Frequent Customers',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            FloatingActionButton.extended(
              heroTag: 'new_order_fab',
              onPressed: _showNewOrderSheet,
              elevation: 10,
              extendedPadding: const EdgeInsets.symmetric(
                horizontal: 34,
                vertical: 20,
              ),
              backgroundColor: const Color(0xFF1B5E20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              icon: const Icon(Icons.add, color: Colors.white, size: 34),
              label: const Text(
                'New Sale',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(
    List<Sale> sales, {
    required String emptyMessage,
    void Function(Sale)? onOrderTap,
  }) {
    if (sales.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(color: Color(0xFFB4B4B4), fontSize: 18),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        18,
        20,
        18,
        180,
      ), // extra padding for multiple FABs
      itemCount: sales.length,
      separatorBuilder: (_, index) => const SizedBox(height: 18),
      itemBuilder: (context, index) => _OrderCard(
        sale: sales[index],
        onTap: onOrderTap != null ? () => onOrderTap(sales[index]) : null,
      ),
    );
  }

  Future<void> _showPendingOrderAction(Sale sale) async {
    if (sale.status.toLowerCase() == 'pending') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sale is still being prepared by the Kitchen.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Outside Sale Action'),
        content: Text(
          'Mark sale for ${sale.customerName} as Out for Delivery?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final orderProvider = context.read<SaleProvider>();
              Navigator.pop(dialogContext);
              await orderProvider.markSaleDelivering(sale.id!);
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF57C00),
            ),
            child: const Text('Out for Delivery'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeliveringOrderAction(Sale sale) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Mark as paid'),
        content: Text(
          'Choose payment method to complete the delivery for ${sale.customerName}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final orderProvider = context.read<SaleProvider>();
              final reportProvider = context.read<ReportProvider>();
              Navigator.pop(dialogContext);
              await orderProvider.markSalePaid(
                sale.id!,
                paymentMethod: 'Cash',
              );
              await reportProvider.refreshReports();
            },
            child: const Text('Cash'),
          ),
          FilledButton(
            onPressed: () async {
              final orderProvider = context.read<SaleProvider>();
              final reportProvider = context.read<ReportProvider>();
              Navigator.pop(dialogContext);
              await orderProvider.markSalePaid(
                sale.id!,
                paymentMethod: 'M-Pesa',
              );
              await reportProvider.refreshReports();
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            child: const Text('M-Pesa'),
          ),
        ],
      ),
    );
  }

  Future<void> _showNewOrderSheet() async {
    final formKey = GlobalKey<FormState>();
    final customerController = TextEditingController();
    final locationController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.95,
          minChildSize: 0.7,
          expand: false,
          builder: (sheetDraggableContext, controller) {
            return Consumer2<ProductProvider, SaleProvider>(
              builder: (context, menu, sales, child) {
                final items = menu.activeItems;
                final amount = sales.calculateOutsideTotal(items);

                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(36),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          width: 86,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3E3E3),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'New Outside Sale',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Expanded(
                          child: SingleChildScrollView(
                            controller: controller,
                            padding: EdgeInsets.only(
                              left: 20,
                              right: 20,
                              bottom:
                                  MediaQuery.of(context).viewInsets.bottom + 24,
                            ),
                            child: Form(
                              key: formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FormFieldCard(
                                    controller: customerController,
                                    icon: Icons.person,
                                    hintText: 'Customer Name',
                                    validator: (value) =>
                                        value == null || value.trim().isEmpty
                                        ? 'Enter customer name'
                                        : null,
                                  ),
                                  const SizedBox(height: 18),
                                  _FormFieldCard(
                                    controller: locationController,
                                    icon: Icons.location_on,
                                    hintText: 'Location / Area',
                                    validator: (value) =>
                                        value == null || value.trim().isEmpty
                                        ? 'Enter location / area'
                                        : null,
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Select Items:',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 235,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: items.length,
                                      separatorBuilder: (_, index) =>
                                          const SizedBox(width: 18),
                                      itemBuilder: (context, index) {
                                        final item = items[index];
                                        final quantity =
                                            sales.outsideCart[item.id] ?? 0;
                                        return _OutsideMenuCard(
                                          item: item,
                                          quantity: quantity,
                                          onAdd: () =>
                                              sales.addToOutsideCart(item),
                                          onRemove: () => sales
                                              .removeFromOutsideCart(item),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  PrimaryActionButton(
                                    label: amount > 0
                                        ? 'SAVE ORDER · KES ${amount.toStringAsFixed(0)}'
                                        : 'SAVE ORDER',
                                    enabled: amount > 0,
                                    onTap: amount <= 0
                                        ? null
                                        : () async {
                                            if (!formKey.currentState!
                                                .validate()) {
                                              return;
                                            }
                                            final orderProvider = context
                                                .read<SaleProvider>();
                                            final messenger =
                                                ScaffoldMessenger.of(
                                                  this.context,
                                                );
                                            final navigator = Navigator.of(
                                              sheetContext,
                                            );
                                            final success = await orderProvider
                                                .createSale(
                                                  customerName:
                                                      customerController.text
                                                          .trim(),
                                                  location: locationController
                                                      .text
                                                      .trim(),
                                                  allItems: items,
                                                );
                                            if (!sheetDraggableContext
                                                    .mounted ||
                                                !mounted) {
                                              return;
                                            }
                                            if (success) {
                                              navigator.pop();
                                              _tabController.animateTo(0);
                                              messenger.showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Outside sale saved',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );

    if (mounted) {
      context.read<SaleProvider>().clearOutsideCart();
    }
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.sale, this.onTap});

  final Sale sale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('yyyy-MM-dd HH:mm').format(sale.createdAt ?? DateTime.now());
    final statusLower = sale.status.toLowerCase();
    final isPaid = statusLower == 'paid';
    final isDelivering = statusLower == 'delivering';

    Color statusBadgeColor;
    Color statusTextColor;
    IconData statusIcon;
    Color statusIconBg;

    if (isPaid) {
      statusBadgeColor = const Color(0xFFE6F7DF);
      statusTextColor = const Color(0xFF47C25A);
      statusIcon = Icons.check;
      statusIconBg = const Color(0xFF47C25A);
    } else if (isDelivering) {
      statusBadgeColor = const Color(0xFFE3F2FD);
      statusTextColor = const Color(0xFF1976D2);
      statusIcon = Icons.delivery_dining_rounded;
      statusIconBg = const Color(0xFF1976D2);
    } else if (statusLower == 'ready') {
      statusBadgeColor = const Color(0xFFE8F5E9);
      statusTextColor = const Color(0xFF2E7D32);
      statusIcon = Icons.fastfood;
      statusIconBg = const Color(0xFF2E7D32);
    } else {
      statusBadgeColor = const Color(0xFFFFF0C8);
      statusTextColor = const Color(0xFFB57A00);
      statusIcon = Icons.schedule;
      statusIconBg = const Color(0xFFFFB300);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFFFBFCF4),
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFE9F8E4),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: statusIconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(statusIcon, color: Colors.white, size: 22),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sale.customerName ?? 'Unknown',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFF9E9E9E),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            sale.location ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9E9E9E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFB1B1B1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'KES ${sale.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusBadgeColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      sale.status.toUpperCase(),
                      style: TextStyle(
                        color: statusTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormFieldCard extends StatelessWidget {
  const _FormFieldCard({
    required this.controller,
    required this.icon,
    required this.hintText,
    required this.validator,
  });

  final TextEditingController controller;
  final IconData icon;
  final String hintText;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(fontSize: 22, color: Color(0xFF4B4B4B)),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 28, color: const Color(0xFF4E4E4E)),
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 22, color: Color(0xFF6C6C6C)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 20,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD2D2D2), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1B5E20), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}

class _OutsideMenuCard extends StatelessWidget {
  const _OutsideMenuCard({
    required this.item,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  final Product item;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFD8D8D8), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.name.toLowerCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'KES ${item.price.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 16, color: Color(0xFF9E9E9E)),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CircleIconButton(
                icon: Icons.remove,
                backgroundColor: Colors.white,
                borderColor: const Color(0xFF222222),
                iconColor: const Color(0xFF222222),
                onTap: onRemove,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  '$quantity',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
              _CircleIconButton(
                icon: Icons.add,
                backgroundColor: const Color(0xFF2E7D32),
                borderColor: const Color(0xFF2E7D32),
                iconColor: Colors.white,
                onTap: onAdd,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
    );
  }
}

class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({
    super.key,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled
              ? const Color(0xFF1B5E20)
              : const Color(0xFFE7E7E7),
          foregroundColor: enabled ? Colors.white : const Color(0xFF969696),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
