import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/kiosk_services.dart';
import '../../models/kiosk_models.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    Future.microtask(() => context.read<DeliveryService>().loadOrders());
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('📦 Outside Orders'),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: const Color(0xFF1B5E20),
          labelColor: const Color(0xFF1B5E20),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'PENDING'),
            Tab(text: 'PAID'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1B5E20),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Order', style: TextStyle(color: Colors.white)),
        onPressed: () => _showNewOrderSheet(context),
      ),
      body: Consumer<DeliveryService>(
        builder: (context, svc, _) {
          return TabBarView(
            controller: _tab,
            children: [
              _buildOrderList(svc.pendingOrders, svc),
              _buildOrderList(svc.paidOrders, svc),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderList(List<DeliveryOrder> orders, DeliveryService svc) {
    if (orders.isEmpty) {
      return const Center(child: Text('No orders here.', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: orders.length,
      itemBuilder: (context, i) => _OrderCard(order: orders[i], svc: svc),
    );
  }

  void _showNewOrderSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NewOrderSheet(),
    );
  }
}

// ─── ORDER CARD ───────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final DeliveryOrder order;
  final DeliveryService svc;
  const _OrderCard({required this.order, required this.svc});

  @override
  Widget build(BuildContext context) {
    final isPending = order.status == 'pending';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order, svc: svc))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: (isPending ? Colors.orange : Colors.green).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(isPending ? Icons.hourglass_top : Icons.check_circle,
                    color: isPending ? Colors.orange : Colors.green),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 2),
                    Row(children: [
                      const Icon(Icons.location_on, size: 13, color: Colors.grey),
                      const SizedBox(width: 2),
                      Text(order.location, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ]),
                    const SizedBox(height: 2),
                    Text(order.createdAt.toString().split('T')[0], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('KES ${order.total.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B5E20))),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isPending ? Colors.orange.withOpacity(0.12) : Colors.green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(isPending ? 'PENDING' : 'PAID',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isPending ? Colors.orange : Colors.green)),
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

// ─── ORDER DETAIL SCREEN ──────────────────────────────────────────────────────

class OrderDetailScreen extends StatefulWidget {
  final DeliveryOrder order;
  final DeliveryService svc;
  const OrderDetailScreen({super.key, required this.order, required this.svc});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  List<DeliveryItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await widget.svc.getOrderItems(widget.order.id!);
    setState(() { _items = items; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final isPending = widget.order.status == 'pending';
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text(widget.order.customerName),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'delete') {
                await widget.svc.deleteOrder(widget.order.id!);
                if (context.mounted) Navigator.pop(context);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text('Delete Order'))),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1B5E20),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Order', style: TextStyle(color: Colors.white)),
        onPressed: () {
          Navigator.pop(context);
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const _NewOrderSheet(),
          );
        },
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Info Card
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _infoRow(Icons.person, 'Customer', widget.order.customerName),
                          const Divider(),
                          _infoRow(Icons.location_on, 'Location', widget.order.location),
                          const Divider(),
                          _infoRow(Icons.schedule, 'Date', widget.order.createdAt.toString().split('T')[0]),
                          const Divider(),
                          _infoRow(Icons.payments, 'Total', 'KES ${widget.order.total.toStringAsFixed(0)}'),
                          if (!isPending) ...[
                            const Divider(),
                            _infoRow(Icons.check_circle, 'Payment', widget.order.paymentMethod.toUpperCase(), valueColor: Colors.green),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Items List
                  const Text('Order Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    child: Column(
                      children: _items.asMap().entries.map((entry) {
                        final item = entry.value;
                        final isLast = entry.key == _items.length - 1;
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Text('${item.quantity}×', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20), fontSize: 15)),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(item.itemName, style: const TextStyle(fontSize: 15))),
                                  Text('KES ${item.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            if (!isLast) const Divider(height: 1),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Action Buttons
                  if (isPending) ...[
                    Row(children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                          icon: const Icon(Icons.phone_android),
                          label: const Text('Paid — M-Pesa', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () async {
                            await widget.svc.markOrderPaid(widget.order.id!, method: 'mpesa');
                            if (context.mounted) Navigator.pop(context);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                          icon: const Icon(Icons.money),
                          label: const Text('Paid — Cash', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () async {
                            await widget.svc.markOrderPaid(widget.order.id!, method: 'cash');
                            if (context.mounted) Navigator.pop(context);
                          },
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Order'),
                        onPressed: () async {
                          await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => _EditOrderSheet(order: widget.order, existingItems: _items, svc: widget.svc),
                          );
                          _loadItems();
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const Spacer(),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: valueColor ?? Colors.black87)),
        ],
      ),
    );
  }
}

// ─── NEW ORDER BOTTOM SHEET ───────────────────────────────────────────────────

class _NewOrderSheet extends StatefulWidget {
  const _NewOrderSheet();
  @override
  State<_NewOrderSheet> createState() => _NewOrderSheetState();
}

class _NewOrderSheetState extends State<_NewOrderSheet> {
  final _nameCtrl = TextEditingController();
  final _locCtrl = TextEditingController();
  final Map<KioskItem, int> _cart = {};

  double get _total => _cart.entries.fold(0.0, (s, e) => s + e.key.price * e.value);

  @override
  Widget build(BuildContext context) {
    final items = context.read<SalesService>().items;
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const Text('New Outside Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(children: [
              TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Customer Name', prefixIcon: Icon(Icons.person), border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: _locCtrl, decoration: const InputDecoration(labelText: 'Location / Area', prefixIcon: Icon(Icons.location_on), border: OutlineInputBorder())),
            ]),
          ),
          const SizedBox(height: 12),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Align(alignment: Alignment.centerLeft, child: Text('Select Items:', style: TextStyle(fontWeight: FontWeight.bold)))),
          const SizedBox(height: 8),
          SizedBox(
            height: 130,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: items.map((item) {
                final qty = _cart[item] ?? 0;
                return Container(
                  width: 110,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: qty > 0 ? const Color(0xFF1B5E20).withOpacity(0.08) : Colors.grey.shade100,
                    border: Border.all(color: qty > 0 ? const Color(0xFF1B5E20) : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center),
                      Text('KES ${item.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () { if (qty > 0) setState(() { if (qty == 1) _cart.remove(item); else _cart[item] = qty - 1; }); },
                            child: const Icon(Icons.remove_circle_outline, size: 20),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                          InkWell(
                            onTap: () => setState(() => _cart[item] = qty + 1),
                            child: const Icon(Icons.add_circle, size: 20, color: Color(0xFF1B5E20)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          if (_cart.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  ..._cart.entries.map((e) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${e.value}× ${e.key.name}'),
                      Text('KES ${(e.key.price * e.value).toStringAsFixed(0)}'),
                    ],
                  )),
                  const Divider(),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('KES ${_total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          const Spacer(),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20), foregroundColor: Colors.white),
                onPressed: _cart.isEmpty || _nameCtrl.text.isEmpty ? null : () async {
                  final cartItems = _cart.entries.map((e) => {
                    'itemId': e.key.id!,
                    'itemName': e.key.name,
                    'quantity': e.value,
                    'unitPrice': e.key.price,
                    'total': e.key.price * e.value,
                  }).toList();
                  await context.read<DeliveryService>().createOrder(_nameCtrl.text, _locCtrl.text, cartItems);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('SAVE ORDER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── EDIT ORDER SHEET ─────────────────────────────────────────────────────────

class _EditOrderSheet extends StatefulWidget {
  final DeliveryOrder order;
  final List<DeliveryItem> existingItems;
  final DeliveryService svc;
  const _EditOrderSheet({required this.order, required this.existingItems, required this.svc});
  @override
  State<_EditOrderSheet> createState() => _EditOrderSheetState();
}

class _EditOrderSheetState extends State<_EditOrderSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _locCtrl;
  late Map<KioskItem, int> _cart;

  double get _total => _cart.entries.fold(0.0, (s, e) => s + e.key.price * e.value);

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.order.customerName);
    _locCtrl = TextEditingController(text: widget.order.location);
    final items = context.read<SalesService>().items;
    _cart = {};
    for (final di in widget.existingItems) {
      final ki = items.firstWhere((i) => i.id == di.itemId, orElse: () => KioskItem(id: di.itemId, name: di.itemName, price: di.unitPrice));
      _cart[ki] = di.quantity;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = context.read<SalesService>().items;
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const Text('Edit Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(children: [
              TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Customer Name', prefixIcon: Icon(Icons.person), border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: _locCtrl, decoration: const InputDecoration(labelText: 'Location', prefixIcon: Icon(Icons.location_on), border: OutlineInputBorder())),
            ]),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: items.map((item) {
                final qty = _cart[item] ?? 0;
                return Container(
                  width: 110,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: qty > 0 ? const Color(0xFF1B5E20).withOpacity(0.08) : Colors.grey.shade100,
                    border: Border.all(color: qty > 0 ? const Color(0xFF1B5E20) : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center),
                      Text('KES ${item.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () { if (qty > 0) setState(() { if (qty == 1) _cart.remove(item); else _cart[item] = qty - 1; }); },
                            child: const Icon(Icons.remove_circle_outline, size: 20),
                          ),
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                          InkWell(onTap: () => setState(() => _cart[item] = qty + 1), child: const Icon(Icons.add_circle, size: 20, color: Color(0xFF1B5E20))),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20), foregroundColor: Colors.white),
                onPressed: _cart.isEmpty ? null : () async {
                  final cartItems = _cart.entries.map((e) => {
                    'itemId': e.key.id!,
                    'itemName': e.key.name,
                    'quantity': e.value,
                    'unitPrice': e.key.price,
                    'total': e.key.price * e.value,
                  }).toList();
                  await widget.svc.updateOrder(widget.order.id!, _nameCtrl.text, _locCtrl.text, cartItems);
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text('SAVE — KES ${_total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
