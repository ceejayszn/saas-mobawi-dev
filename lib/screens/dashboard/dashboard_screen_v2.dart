import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/kiosk_services.dart';
import '../../services/receipt_printer.dart';
import '../../services/sync_service.dart';
// import '../../services/mpesa_service.dart'; // M-Pesa: uncomment when live credentials are ready
import '../../services/backup_service.dart';
import '../pos/pos_screen_v2.dart';
import '../production/production_screen.dart';
import '../expenses/expenses_screen_v2.dart';
import '../analysis/analysis_screen.dart';
import '../../presentation/screens/orders/orders_screen.dart';
import '../../models/kiosk_models.dart';
import '../../utils/color_utils.dart';

class DashboardScreenV2 extends StatefulWidget {
  const DashboardScreenV2({super.key});

  @override
  State<DashboardScreenV2> createState() => _DashboardScreenV2State();
}

class _DashboardScreenV2State extends State<DashboardScreenV2> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    SyncService.instance.startAutoSync();
    // Trigger immediate backup on startup
    BackupService.instance.autoBackupDatabase();
  }

  @override
  void dispose() {
    SyncService.instance.stopAutoSync();
    super.dispose();
  }

  late final List<Widget> _screens = [
    _HomeSummary(onNavigate: (index) => setState(() => _selectedIndex = index)),
    const POSScreenV2(),
    const ProductionScreen(),
    const ExpensesScreenV2(),
    OrdersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1B5E20),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.touch_app), label: 'Sell'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Cook'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Expenses'),
          BottomNavigationBarItem(icon: Icon(Icons.delivery_dining), label: 'Orders'),
        ],
      ),
    );
  }
}

// ─── HOME SUMMARY ─────────────────────────────────────────────────────────────

class _HomeSummary extends StatefulWidget {
  final Function(int)? onNavigate;
  const _HomeSummary({this.onNavigate});

  @override
  State<_HomeSummary> createState() => _HomeSummaryState();
}

class _HomeSummaryState extends State<_HomeSummary> {
  String _cashierName = '';
  List<Map<String, dynamic>> _onlineCashiers = [];
  Timer? _cashierPollTimer;

  @override
  void initState() {
    super.initState();
    _loadCashierName();
    _refresh();
    _pollOnlineCashiers();
    // Poll online cashiers every 60 seconds
    _cashierPollTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _pollOnlineCashiers(),
    );
  }

  @override
  void dispose() {
    _cashierPollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCashierName() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _cashierName = prefs.getString('cashier_username') ?? 'Staff';
      });
    }
  }

  Future<void> _pollOnlineCashiers() async {
    final cashiers = await SyncService.instance.getOnlineCashiers();
    if (mounted) {
      setState(() => _onlineCashiers = cashiers);
    }
  }

  void _refresh() {
    context.read<SummaryService>().refreshSummary();
    context.read<ExpenseService>().loadDailyExpenses();
    context.read<SalesService>().loadDailySales();
  }

  Future<void> _manualBackupAndSync() async {
    // 1. Run local backup
    await BackupService.instance.autoBackupDatabase();

    // 2. Check for internet connectivity
    bool hasInternet = false;
    try {
      final host = Uri.parse(await SyncService.instance.getBaseUrl()).host;
      if (host.isNotEmpty) {
        final result = await InternetAddress.lookup(host).timeout(const Duration(seconds: 4));
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          hasInternet = true;
        }
      }
    } catch (_) {}

    if (!hasInternet) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(children: [
              Icon(Icons.error_outline, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Error: No internet'),
            ]),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // 3. Trigger cloud sync
    try {
      final syncSuccess = await SyncService.instance.syncData();
      await _pollOnlineCashiers();
      if (mounted) {
        if (syncSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(children: [
                Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Backup Done'),
              ]),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(children: [
                Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Error: Problem interfering with backup'),
              ]),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text('Error: $e')),
            ]),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _printReceipt(BuildContext context, KioskOrder order, SalesService svc) async {
    final items = await svc.getOrderSales(order.sequenceId);
    await ReceiptPrinterService.printOrderReceipt(order, items);
  }

  @override
  Widget build(BuildContext context) {
    // Other cashiers online (exclude self)
    final otherOnline = _onlineCashiers
        .where((c) => (c['cashier_name'] ?? '') != _cashierName && c['status'] == 'online')
        .toList();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Image.asset('assets/logo.png', height: 38),
        centerTitle: false,
        actions: [
          // Circular arrow backup & sync button
          Tooltip(
            message: 'Backup & Sync',
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1B5E20).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.sync, color: Color(0xFF1B5E20)),
                onPressed: _manualBackupAndSync,
              ),
            ),
          ),
          // Refresh
          Tooltip(
            message: 'Refresh',
            child: IconButton(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh, color: Colors.grey),
            ),
          ),
        ],
      ),
      body: Consumer2<SummaryService, ExpenseService>(
        builder: (context, summary, expense, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Other cashiers online banner ──────────────────────────────
                if (otherOnline.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.indigo.shade700, Colors.indigo.shade400],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.people_alt_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${otherOnline.map((c) => c['cashier_name']).join(', ')} also online on another device',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF69F0AE),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // ── Premium Welcome Card ──────────────────────────────────────
                _PremiumWelcomeCard(
                  cashierName: _cashierName,
                  totalRevenue: summary.totalRevenue,
                  onBossArea: () => _requirePin(context, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AnalysisScreen()),
                    );
                  }),
                ),

                const SizedBox(height: 20),

                // ── Recent Orders ─────────────────────────────────────────────
                const Text(
                  'Recent Orders',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Consumer<SalesService>(
                  builder: (context, salesService, child) {
                    if (salesService.dailyOrders.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: const Text(
                          'No orders yet today.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                    final count = salesService.dailyOrders.length > 8
                        ? 8
                        : salesService.dailyOrders.length;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: count,
                      itemBuilder: (context, index) {
                        final order = salesService.dailyOrders[index];
                        return _buildOrderCard(context, order, salesService);
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(
      BuildContext context, KioskOrder order, SalesService salesService) {
    final color = ColorUtils.getColorForUser(order.cashierName);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Dismissible(
        key: Key(order.sequenceId),
        direction: DismissDirection.horizontal,
        background: Container(
          decoration: BoxDecoration(
            color: Colors.deepOrange,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          child: const Icon(Icons.print, color: Colors.white),
        ),
        secondaryBackground: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.edit, color: Colors.white),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            await context.read<SalesService>().loadOrderIntoCart(order);
            widget.onNavigate?.call(1);
          } else {
            _printReceipt(context, order, salesService);
          }
          return false;
        },
        child: ListTile(
          onTap: () => _showOrderDialog(context, order, salesService),
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.12),
            child: Icon(Icons.receipt_long, color: color, size: 20),
          ),
          title: Row(
            children: [
              Text('Order #${order.sequenceId}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              if (order.isModified) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Edited',
                      style: TextStyle(fontSize: 9, color: Colors.black54)),
                ),
              ],
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order.cashierName,
                  style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
              Text(
                salesService.dailySales
                    .where((s) => s.sequenceId == order.sequenceId)
                    .map((s) {
                  final item = salesService.items.firstWhere(
                      (i) => i.id == s.itemId,
                      orElse: () => KioskItem(name: 'Unknown', price: 0));
                  return '${s.quantity}x ${item.name}';
                }).join(', '),
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          trailing: InkWell(
            onTap: order.status == 'unpaid'
                ? () => _showOrderDialog(context, order, salesService)
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: order.status == 'unpaid'
                    ? Colors.orange.shade600
                    : Colors.green.shade600,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    order.status == 'unpaid' ? 'UNPAID' : 'PAID',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11),
                  ),
                  Text(
                    'KES ${order.total.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Order payment dialog ─────────────────────────────────────────────────────
  Future<void> _showOrderDialog(
      BuildContext context, KioskOrder order, SalesService salesService) async {
    final sales = await salesService.getOrderSales(order.sequenceId);
    final items = salesService.items;
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.receipt_long, color: Color(0xFF1B5E20)),
            const SizedBox(width: 8),
            Text('Order #${order.sequenceId}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...sales.map((s) {
              final itemName = items
                  .firstWhere((i) => i.id == s.itemId,
                      orElse: () => KioskItem(name: 'Unknown', price: 0))
                  .name;
              return ListTile(
                dense: true,
                title: Text('${s.quantity}x $itemName'),
                trailing: Text('KES ${s.total.toStringAsFixed(0)}'),
              );
            }),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('KES ${order.total.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1B5E20))),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close')),
          if (order.status == 'unpaid') ...[
            // ── Mpesa Manual Confirm (STK Push hidden, manual confirm visible) ──
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.phone_android, size: 16),
              label: const Text('M-Pesa'),
              onPressed: () {
                Navigator.pop(ctx);
                _confirmMpesaManually(context, order, salesService);
              },
            ),
            // ── Cash payment ──────────────────────────────────────────────────
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.payments, size: 16),
              label: const Text('Cash'),
              onPressed: () async {
                Navigator.pop(ctx);
                await context
                    .read<SalesService>()
                    .markOrderPaid(order.sequenceId, method: 'cash');
                if (context.mounted) {
                  context.read<SummaryService>().refreshSummary();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Order marked as paid — Cash'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  // ── M-Pesa manual confirm (no STK push) ────────────────────────────────────
  Future<void> _confirmMpesaManually(
      BuildContext context, KioskOrder order, SalesService salesService) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.phone_android, color: Colors.green),
            SizedBox(width: 8),
            Text('Confirm M-Pesa Payment'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order #${order.sequenceId}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              'Amount: KES ${order.total.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Text(
                '✅ Confirm the customer has paid via M-Pesa.\nCheck your till for the M-Pesa message.',
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Not Yet')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Yes, Received'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await salesService.markOrderPaid(order.sequenceId, method: 'mpesa');
      if (context.mounted) {
        context.read<SummaryService>().refreshSummary();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('✅ Order marked as paid — M-Pesa'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  // ── Boss PIN lock ────────────────────────────────────────────────────────────
  void _requirePin(BuildContext context, VoidCallback onSuccess) {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Color(0xFF1B5E20)),
            SizedBox(width: 8),
            Text('Boss Area'),
          ],
        ),
        content: TextField(
          controller: pinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Enter PIN',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white),
            onPressed: () {
              if (pinController.text == '8890') {
                Navigator.pop(c);
                onSuccess();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Incorrect PIN')));
              }
            },
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
  }
}

// ─── PREMIUM WELCOME CARD ─────────────────────────────────────────────────────

class _PremiumWelcomeCard extends StatelessWidget {
  final String cashierName;
  final double totalRevenue;
  final VoidCallback onBossArea;

  const _PremiumWelcomeCard({
    required this.cashierName,
    required this.totalRevenue,
    required this.onBossArea,
  });

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? '🌅 Good Morning'
        : hour < 17
            ? '☀️ Good Afternoon'
            : '🌙 Good Evening';

    return GestureDetector(
      onTap: onBossArea,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F3014), Color(0xFF1B5E20), Color(0xFF0B2E14)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B5E20).withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cashierName.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: const Icon(Icons.admin_panel_settings,
                      color: Colors.white, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 1,
              color: Colors.white.withOpacity(0.2),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Revenue",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'KES ${totalRevenue.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock_open_rounded,
                          color: Colors.white, size: 13),
                      SizedBox(width: 4),
                      Text('Boss Area',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* ─── M-PESA STK PUSH SECTION: COMMENTED OUT UNTIL LIVE SAFARICOM CREDENTIALS ─
   To reactivate:
   1. Uncomment 'import mpesa_service.dart' at the top
   2. Replace _confirmMpesaManually with _handleMpesaPayment below
   3. Uncomment the STK Push button in _showOrderDialog

  void _handleMpesaPayment(BuildContext context, KioskOrder order, SalesService salesService) {
    // STK Push flow — requires live Daraja credentials
    // See mpesa_service.dart for implementation
  }

  Future<void> _sendStkPush(BuildContext context, KioskOrder order,
      SalesService salesService, String phone, Color primaryColor) async {
    // final result = await MpesaService.instance.triggerStkPush(
    //   phoneNumber: phone,
    //   amount: order.total,
    //   accountReference: order.sequenceId,
    //   transactionDesc: 'Payment for order #${order.sequenceId}',
    // );
  }
─────────────────────────────────────────────────────────────────────────── */
