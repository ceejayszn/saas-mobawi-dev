import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../services/kiosk_services.dart';
import '../../services/backup_service.dart';
import 'godmode_screen.dart';
import 'hired_personnel_screen.dart';
import '../../models/kiosk_models.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  int _selectedIndex = 0;
  String _timeRange = 'today';
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AnalysisService>().loadActiveDates();
      context.read<AnalysisService>().loadData(_timeRange);
      context.read<AnalysisService>().loadActiveCashiers();
    });
  }

  void _setRange(String range) {
    setState(() => _timeRange = range);
    context.read<AnalysisService>().loadData(range);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      final dateStr = selectedDay.toString().split(' ')[0];
      _timeRange = 'date:$dateStr';
    });
    context.read<AnalysisService>().loadData('date:${selectedDay.toString().split(' ')[0]}');
  }

  void _promptGodmodePassword(BuildContext context) {
    final _passCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Admin Godmode', style: TextStyle(color: Colors.red)),
        content: TextField(
          controller: _passCtrl,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              if (_passCtrl.text == '8890') { // Godmode password
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GodmodeScreen()));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incorrect password.')));
              }
            },
            child: const Text('ENTER'),
          ),
        ],
      ),
    );
  }

  void _showOrganizationDialog(BuildContext context, AnalysisService analytics) {
    analytics.loadLocalCashiers();
    analytics.loadActiveCashiers();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setState) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const Text('🏢 Organization Directory', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Active or registered cashiers in this system', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: analytics.localCashiers.length,
                    itemBuilder: (context, index) {
                      final cashier = analytics.localCashiers[index];
                      final name = cashier['cashier_name'] as String;
                      final inputCount = cashier['input_count'] as int;

                      final isOnline = analytics.activeCashiers.any(
                        (ac) => ac['cashier_name'] == name && ac['status'] == 'online'
                      );

                      int hash = 0;
                      for (int i = 0; i < name.length; i++) hash = name.codeUnitAt(i) + ((hash << 5) - hash);
                      final List<Color> colors = [Colors.green, Colors.blue, Colors.purple, Colors.orange, Colors.teal, Colors.pink, Colors.amber, Colors.indigo];
                      final color = colors[hash.abs() % colors.length];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: color.withOpacity(0.12),
                            child: Icon(Icons.person, color: color),
                          ),
                          title: Text(name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Inputs/Orders: $inputCount'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isOnline ? Colors.green.shade100 : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isOnline ? 'ACTIVE' : 'INACTIVE',
                              style: TextStyle(
                                color: isOnline ? Colors.green.shade800 : Colors.grey.shade600,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationsPanel(AnalysisService analytics) {
    final List<String> notifications = [];
    if (analytics.totalUnsettledBills > 0) {
      notifications.add('⚠️ You have KES ${analytics.totalUnsettledBills.toStringAsFixed(0)} in unsettled bills.');
    }
    final unsynced = analytics.rangeOrders.where((o) => o.status == 'unpaid').length;
    if (unsynced > 0) {
      notifications.add('🔔 $unsynced orders are unpaid/pending payment.');
    }

    if (notifications.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_active, color: Colors.amber.shade900, size: 20),
              const SizedBox(width: 8),
              Text(
                'Actions Needed',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade900, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...notifications.map((n) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 6, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(child: Text(n, style: const TextStyle(fontSize: 12, color: Colors.black87))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('⚡ Boss Analytics'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'godmode') {
                _promptGodmodePassword(context);
              } else if (value == 'calendar') {
                _showCalendarPicker(context);
              } else {
                final backup = BackupService.instance;
                if (value == 'export_db') {
                  await backup.exportDatabase(context);
                } else if (value == 'import_db') {
                  await backup.importDatabase(context);
                } else if (value == 'export_csv') {
                  await backup.exportDataToCsv(context);
                } else if (value == 'share_report') {
                  _shareTextReport(context);
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'godmode', child: ListTile(leading: Icon(Icons.admin_panel_settings, color: Colors.red), title: Text('Godmode'))),
              const PopupMenuItem(value: 'calendar', child: ListTile(leading: Icon(Icons.calendar_month, color: Colors.teal), title: Text('Pick Date (Calendar)'))),
              const PopupMenuItem(value: 'share_report', child: ListTile(leading: Icon(Icons.share), title: Text('Share Text Report'))),
              const PopupMenuItem(value: 'export_csv', child: ListTile(leading: Icon(Icons.table_chart, color: Colors.green), title: Text('Export CSV (Excel)'))),
              const PopupMenuItem(value: 'export_db', child: ListTile(leading: Icon(Icons.save_alt, color: Colors.blue), title: Text('🔒 Backup Database (Encrypted)'))),
              const PopupMenuItem(value: 'import_db', child: ListTile(leading: Icon(Icons.upload_file, color: Colors.orange), title: Text('Restore Database (from Euton Data)'))),
            ],
          ),
        ],
      ),
      body: _buildDashboard(context),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    return Consumer<AnalysisService>(
      builder: (context, analytics, child) {
        if (analytics.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final eatInRevenue = analytics.totalRevenue;
        final deliveryRevenue = analytics.deliveryRevenue;
        final grossRevenue = eatInRevenue + deliveryRevenue;
        final totalCosts = analytics.totalExpenses;
        final netRevenue = grossRevenue - totalCosts;
        final isProfit = netRevenue >= 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notifications panel
              _buildNotificationsPanel(analytics),

              // Time range toggle
              _buildTimeRangeToggle(),
              const SizedBox(height: 16),

              // Hero card
              _buildHeroCard(grossRevenue, totalCosts, netRevenue, isProfit),
              const SizedBox(height: 16),

              // Stat Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _buildStatCard('Eat In Revenue', 'KES ${eatInRevenue.toStringAsFixed(0)}', Icons.restaurant, Colors.green,
                      onTap: () => _showRevenueDetails(context, 'Eat In', analytics)),
                  _buildStatCard('Delivery Revenue', 'KES ${deliveryRevenue.toStringAsFixed(0)}', Icons.delivery_dining, Colors.purple,
                      onTap: () => _showRevenueDetails(context, 'Delivery', analytics)),
                  _buildStatCard('M-Pesa', 'KES ${analytics.totalMpesa.toStringAsFixed(0)}', Icons.phone_android, Colors.teal,
                      onTap: () => _showRevenueDetails(context, 'M-Pesa', analytics)),
                  _buildStatCard('Cash', 'KES ${analytics.totalCash.toStringAsFixed(0)}', Icons.payments, Colors.blue,
                      onTap: () => _showRevenueDetails(context, 'Cash', analytics)),
                  _buildStatCard('Items Sold', '${analytics.totalSold}', Icons.shopping_basket, Colors.orange,
                      onTap: () => _showRevenueDetails(context, 'Items Sold', analytics)),
                  _buildStatCard('Unsettled Bills', 'KES ${analytics.totalUnsettledBills.toStringAsFixed(0)}', Icons.warning_amber, Colors.red,
                      onTap: () => _showRevenueDetails(context, 'Unsettled bills', analytics)),
                  _buildStatCard('Unpaid Deni', 'KES ${analytics.totalDeni.toStringAsFixed(0)}', Icons.person_off, Colors.pink,
                      onTap: () => _showRevenueDetails(context, 'Unpaid Deni', analytics)),
                  _buildStatCard('Organisation', '${analytics.localCashiers.length} users', Icons.people_alt, Colors.indigo,
                      onTap: () => _showOrganizationDialog(context, analytics)),
                ],
              ),
              const SizedBox(height: 20),

              // Manage Hired Personnel button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HiredPersonnelScreen())),
                  icon: const Icon(Icons.engineering, color: Color(0xFF1B5E20)),
                  label: const Text('Manage Hired Personnel', style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1B5E20)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Hourly sales chart
              _buildSectionHeader('📈 Hourly Sales', Icons.show_chart),
              const SizedBox(height: 12),
              _buildSalesLineChart(analytics.hourlySales),
              const SizedBox(height: 24),

              // Sales table
              _buildSectionHeader('🛒 Sales Breakdown', Icons.table_rows),
              const SizedBox(height: 12),
              _buildSalesTable(analytics.fullSales),
              const SizedBox(height: 24),

              // Expenditure by supplier
              _buildSectionHeader('💸 Expenditure by Supplier', Icons.store),
              const SizedBox(height: 12),
              _buildSupplierTable(analytics.supplierExpenses),
              const SizedBox(height: 24),

              // TOP ITEMS BARS
              _buildSectionHeader('🏆 Top Items', Icons.bar_chart),
              const SizedBox(height: 12),
              if (analytics.topItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No sales data for this period.', style: TextStyle(color: Colors.grey)),
                ),
              ...analytics.topItems.map((item) {
                final double percent = analytics.totalSold > 0 ? (item['qty'] / analytics.totalSold) : 0.0;
                return _buildProgressBar(item['name'], '${item['qty']} sold', percent);
              }),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }




  Widget _buildHeroCard(double gross, double costs, double net, bool isProfit) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isProfit
              ? [const Color(0xFF1B5E20), const Color(0xFF388E3C)]
              : [Colors.red.shade900, Colors.red.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isProfit ? Colors.green : Colors.red).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isProfit ? Icons.trending_up : Icons.trending_down, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              const Text('NET PROFIT / LOSS', style: TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: 1.2, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Text('KES ${net.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniStat('Gross Revenue', gross, Colors.white),
              _buildMiniStat('Total Costs', costs, Colors.white70),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalesLineChart(Map<String, double> hourlySales) {
    if (hourlySales.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: const Center(child: Text('No sales recorded yet today.', style: TextStyle(color: Colors.grey))),
      );
    }

    // Build spots for all 24 hours
    final List<FlSpot> spots = [];
    for (int h = 0; h < 24; h++) {
      final key = h.toString().padLeft(2, '0');
      spots.add(FlSpot(h.toDouble(), hourlySales[key] ?? 0));
    }

    final maxY = hourlySales.values.fold(0.0, (a, b) => a > b ? a : b) * 1.3;

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY > 0 ? maxY / 4 : 100,
            getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 4,
                getTitlesWidget: (value, meta) {
                  final h = value.toInt();
                  if (h % 4 != 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('${h}h', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  return Text('${(value / 1000).toStringAsFixed(1)}k', style: const TextStyle(fontSize: 9, color: Colors.grey));
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 23,
          minY: 0,
          maxY: maxY > 0 ? maxY : 500,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFF1B5E20),
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) {
                  if (spot.y == 0) return FlDotCirclePainter(radius: 0, color: Colors.transparent, strokeColor: Colors.transparent);
                  return FlDotCirclePainter(radius: 4, color: Colors.white, strokeColor: const Color(0xFF1B5E20), strokeWidth: 2);
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [const Color(0xFF1B5E20).withOpacity(0.3), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesTable(List<Map<String, dynamic>> fullSales) {
    if (fullSales.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: const Center(child: Text('No sales data.', style: TextStyle(color: Colors.grey))),
      );
    }

    final totalQty = fullSales.fold<int>(0, (s, e) => s + (e['qty'] as int));
    final totalRev = fullSales.fold<double>(0, (s, e) => s + (e['rev'] as double));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1B5E20),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 4, child: Text('Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 2, child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 3, child: Text('Revenue', textAlign: TextAlign.right, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
              ],
            ),
          ),
          ...fullSales.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Container(
              color: i % 2 == 0 ? Colors.grey.shade50 : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(flex: 4, child: Text(item['name'], style: const TextStyle(fontSize: 13))),
                  Expanded(flex: 2, child: Text('${item['qty']}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                  Expanded(flex: 3, child: Text('KES ${(item['rev'] as double).toStringAsFixed(0)}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1B5E20)))),
                ],
              ),
            );
          }),
          // Totals
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1B5E20).withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Expanded(flex: 4, child: Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 2, child: Text('$totalQty', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 3, child: Text('KES ${totalRev.toStringAsFixed(0)}', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1B5E20)))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierTable(List<Map<String, dynamic>> supplierExpenses) {
    if (supplierExpenses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: const Center(child: Text('No expenses recorded.', style: TextStyle(color: Colors.grey))),
      );
    }

    final totalExp = supplierExpenses.fold<double>(0, (s, e) => s + (e['total'] as double));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 4, child: Text('Supplier / Shop', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 3, child: Text('Amount Spent', textAlign: TextAlign.right, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
              ],
            ),
          ),
          ...supplierExpenses.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Container(
              color: i % 2 == 0 ? Colors.grey.shade50 : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(flex: 4, child: Text(item['supplier'], style: const TextStyle(fontSize: 13))),
                  Expanded(flex: 3, child: Text('KES ${(item['total'] as double).toStringAsFixed(0)}', textAlign: TextAlign.right, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.red.shade700))),
                ],
              ),
            );
          }),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Expanded(flex: 4, child: Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 3, child: Text('KES ${totalExp.toStringAsFixed(0)}', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, String sub, double percent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(sub, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1B5E20))),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: Colors.grey.shade200,
                color: const Color(0xFF1B5E20),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 4),
            Text('${(percent * 100).toStringAsFixed(1)}% of total sold', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeToggle() {
    final ranges = [
      ('today', 'Today', Icons.today),
      ('week', 'This Week', Icons.date_range),
      ('month', 'This Month', Icons.calendar_view_month),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
      ),
      child: Row(
        children: ranges.map((r) {
          final isActive = _timeRange == r.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => _setRange(r.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF1B5E20) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(r.$3, size: 18, color: isActive ? Colors.white : Colors.grey.shade600),
                    const SizedBox(height: 4),
                    Text(r.$2, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isActive ? Colors.white : Colors.grey.shade600)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showCalendarPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const Text('📅 Pick a Date', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Tap a highlighted date to view that day\'s analytics', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(height: 12),
              Consumer<AnalysisService>(
                builder: (context, analytics, _) => _buildCalendar(analytics.activeDates),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check),
                  label: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  void _showRevenueDetails(BuildContext context, String type, AnalysisService analytics) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              Text('$type Breakdown', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: _buildDetailsList(type, analytics, context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailsList(String type, AnalysisService analytics, BuildContext context) {
    if (type == 'Eat In' || type == 'Gross') return _buildSalesTable(analytics.fullSales);
    if (type == 'Delivery') return _buildDeliveryList(analytics);
    if (type == 'Costs') return _buildExpenseList(analytics);
    if (type == 'M-Pesa') return _buildPaymentList(analytics, 'mpesa');
    if (type == 'Cash') return _buildPaymentList(analytics, 'cash');
    if (type == 'Items Sold') return _buildSalesTable(analytics.fullSales);
    if (type == 'Unsettled bills' || type == 'Unpaid Deni') return _buildUnsettledBillsList(analytics);
    return const Center(child: Text('Data not available.'));
  }

  Widget _buildExpenseList(AnalysisService analytics) {
    final expenses = analytics.rangeExpenses;
    if (expenses.isEmpty) return const Center(child: Text('No expenses recorded.'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: expenses.length,
      itemBuilder: (context, i) {
        final e = expenses[i];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.money_off, color: Colors.red),
            title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Settled: KES ${e.settledAmount.toStringAsFixed(0)} / ${e.amount.toStringAsFixed(0)}'),
            trailing: Text('KES ${e.amount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  Widget _buildPaymentList(AnalysisService analytics, String method) {
    final orders = analytics.rangeOrders.where((o) => o.status == 'paid' && o.paymentMethod == method).toList();
    if (orders.isEmpty) return Center(child: Text('No $method payments recorded.'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, i) {
        final o = orders[i];
        return Card(
          child: ListTile(
            leading: Icon(method == 'mpesa' ? Icons.phone_android : Icons.money, color: method == 'mpesa' ? Colors.green : Colors.blue),
            title: Text('Order #${o.sequenceId}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(o.createdAt.toString().split('.')[0]),
            trailing: Text('KES ${o.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  Widget _buildUnsettledBillsList(AnalysisService analytics) {
    final credits = analytics.rangeCredits;
    final unsettledExpenses = analytics.rangeExpenses.where((e) => e.status == 'unsettled').toList();
    final unsettledJobs = analytics.personnelJobs.where((j) => j.status == 'unsettled').toList();

    if (credits.isEmpty && unsettledExpenses.isEmpty && unsettledJobs.isEmpty) {
      return const Center(child: Text('No unsettled bills. All clear!'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (credits.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Deni / Customer Credits:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          ),
          ...credits.map((c) => Card(
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.red),
              title: Text(c.customerName ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(c.createdAt.toString().split('.')[0]),
              trailing: Text('KES ${c.amount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          )),
        ],
        if (unsettledExpenses.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Unsettled Supplier Bills:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
          ),
          ...unsettledExpenses.map((e) => Card(
            child: ListTile(
              leading: const Icon(Icons.store, color: Colors.orange),
              title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Balance: KES ${(e.amount - e.settledAmount).toStringAsFixed(0)} (Total: ${e.amount.toStringAsFixed(0)})'),
              trailing: Text('KES ${(e.amount - e.settledAmount).toStringAsFixed(0)}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            ),
          )),
        ],
        if (unsettledJobs.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Hired Personnel Jobs Pending:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
          ...unsettledJobs.map((j) {
            final staffName = analytics.personnel.any((p) => p.id == j.personnelId)
                ? analytics.personnel.firstWhere((p) => p.id == j.personnelId).name
                : 'Unknown';
            return Card(
              child: ListTile(
                leading: const Icon(Icons.work, color: Colors.blue),
                title: Text(j.jobTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Staff: $staffName • Duration: ${j.duration}'),
                trailing: Text('KES ${j.amount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildDeliveryList(AnalysisService analytics) {
    final deliveries = analytics.rangeDeliveries.where((d) => d.status == 'paid').toList();
    if (deliveries.isEmpty) return const Center(child: Text('No paid deliveries found for this period.'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: deliveries.length,
      itemBuilder: (context, i) {
        final d = deliveries[i];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.delivery_dining, color: Colors.purple),
            title: Text(d.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${d.location}\n${d.createdAt.toString().split('.')[0]}'),
            trailing: Text('KES ${d.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildCalendar(Set<DateTime> activeDates) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: _onDaySelected,
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {CalendarFormat.month: 'Month'},
        headerStyle: const HeaderStyle(titleCentered: true),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            for (DateTime d in activeDates) {
              if (isSameDay(d, day)) {
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.green.shade200, shape: BoxShape.circle),
                  child: Text(day.day.toString(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                );
              }
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 12)),
        Text('KES ${amount.toStringAsFixed(0)}', style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _shareTextReport(BuildContext context) {
    final analytics = context.read<AnalysisService>();
    final profit = analytics.totalRevenue - analytics.totalExpenses;
    String report = '=== EUTON HOTEL REPORT ===\n';
    report += 'Date: ${DateTime.now().toString().split('.')[0]}\n';
    report += 'Period: $_timeRange\n';
    report += '--------------------------\n';
    report += 'Gross Revenue: KES ${analytics.totalRevenue.toStringAsFixed(0)}\n';
    report += 'Total Expenses: KES ${analytics.totalExpenses.toStringAsFixed(0)}\n';
    report += 'NET PROFIT: KES ${profit.toStringAsFixed(0)}\n';
    report += '--------------------------\n';
    report += 'M-Pesa: KES ${analytics.totalMpesa.toStringAsFixed(0)}\n';
    report += 'Cash: KES ${analytics.totalCash.toStringAsFixed(0)}\n';
    report += 'Unpaid Deni: KES ${analytics.totalDeni.toStringAsFixed(0)}\n';
    report += '\n=== TOP ITEMS ===\n';
    for (var i in analytics.topItems) {
      report += '- ${i['name']}: ${i['qty']} sold\n';
    }
    report += '\n=== EXPENSES BY SUPPLIER ===\n';
    for (var s in analytics.supplierExpenses) {
      report += '- ${s['supplier']}: KES ${(s['total'] as double).toStringAsFixed(0)}\n';
    }
    Share.share(report);
  }
}
