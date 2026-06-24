import 'package:flutter/material.dart';
import '../../database/database_service.dart';
import 'package:intl/intl.dart';

class GodmodeScreen extends StatefulWidget {
  const GodmodeScreen({super.key});

  @override
  State<GodmodeScreen> createState() => _GodmodeScreenState();
}

class _GodmodeScreenState extends State<GodmodeScreen> with SingleTickerProviderStateMixin {
  final DatabaseService _db = DatabaseService.instance;

  // --- Summary data ---
  Map<String, double> _yesterday = {};
  Map<String, double> _today = {};
  Map<String, double> _allTime = {};
  bool _isLoading = true;

  // --- Raw data table ---
  List<Map<String, dynamic>> _rawData = [];
  String _selectedTable = 'sales';

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSummary();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSummary() async {
    setState(() => _isLoading = true);
    final db = await _db.database;

    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final yesterdayStr = DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 1)));

    // --- YESTERDAY ---
    final yRevData = await db.rawQuery(
        "SELECT COALESCE(SUM(total),0) as t FROM orders WHERE date(created_at) = '$yesterdayStr' AND status = 'paid'");
    final yExpData = await db.rawQuery(
        "SELECT COALESCE(SUM(amount),0) as t FROM expenses WHERE date(created_at) = '$yesterdayStr'");
    final yDelData = await db.rawQuery(
        "SELECT COALESCE(SUM(total),0) as t FROM delivery_orders WHERE date(created_at) = '$yesterdayStr' AND status = 'paid'");
    final yRev = (yRevData.first['t'] as num?)?.toDouble() ?? 0;
    final yDel = (yDelData.first['t'] as num?)?.toDouble() ?? 0;
    final yExp = (yExpData.first['t'] as num?)?.toDouble() ?? 0;

    // --- TODAY ---
    final tRevData = await db.rawQuery(
        "SELECT COALESCE(SUM(total),0) as t FROM orders WHERE date(created_at) = '$todayStr' AND status = 'paid'");
    final tExpData = await db.rawQuery(
        "SELECT COALESCE(SUM(amount),0) as t FROM expenses WHERE date(created_at) = '$todayStr'");
    final tDelData = await db.rawQuery(
        "SELECT COALESCE(SUM(total),0) as t FROM delivery_orders WHERE date(created_at) = '$todayStr' AND status = 'paid'");
    final tUnpaidData = await db.rawQuery(
        "SELECT COALESCE(SUM(total),0) as t FROM orders WHERE date(created_at) = '$todayStr' AND status = 'unpaid'");
    final tDeniData = await db.rawQuery(
        "SELECT COALESCE(SUM(amount),0) as t FROM credits WHERE status = 'unpaid'");
    final tRev = (tRevData.first['t'] as num?)?.toDouble() ?? 0;
    final tDel = (tDelData.first['t'] as num?)?.toDouble() ?? 0;
    final tExp = (tExpData.first['t'] as num?)?.toDouble() ?? 0;
    final tUnpaid = (tUnpaidData.first['t'] as num?)?.toDouble() ?? 0;
    final tDeni = (tDeniData.first['t'] as num?)?.toDouble() ?? 0;

    // --- ALL TIME ---
    final aRevData = await db.rawQuery(
        "SELECT COALESCE(SUM(total),0) as t FROM orders WHERE status = 'paid'");
    final aExpData = await db.rawQuery(
        "SELECT COALESCE(SUM(amount),0) as t FROM expenses");
    final aDelData = await db.rawQuery(
        "SELECT COALESCE(SUM(total),0) as t FROM delivery_orders WHERE status = 'paid'");
    final aDeniData = await db.rawQuery(
        "SELECT COALESCE(SUM(amount),0) as t FROM credits WHERE status = 'unpaid'");
    final aOrderCount = await db.rawQuery(
        "SELECT COUNT(*) as c FROM orders WHERE status = 'paid'");
    final aRev = (aRevData.first['t'] as num?)?.toDouble() ?? 0;
    final aDel = (aDelData.first['t'] as num?)?.toDouble() ?? 0;
    final aExp = (aExpData.first['t'] as num?)?.toDouble() ?? 0;
    final aDeni = (aDeniData.first['t'] as num?)?.toDouble() ?? 0;
    final aCount = (aOrderCount.first['c'] as num?)?.toInt() ?? 0;

    setState(() {
      _yesterday = {
        'eatIn': yRev,
        'delivery': yDel,
        'gross': yRev + yDel,
        'expenses': yExp,
        'net': (yRev + yDel) - yExp,
      };
      _today = {
        'eatIn': tRev,
        'delivery': tDel,
        'gross': tRev + tDel,
        'expenses': tExp,
        'net': (tRev + tDel) - tExp,
        'unpaid': tUnpaid,
        'deni': tDeni,
      };
      _allTime = {
        'eatIn': aRev,
        'delivery': aDel,
        'gross': aRev + aDel,
        'expenses': aExp,
        'net': (aRev + aDel) - aExp,
        'deni': aDeni,
        'orderCount': aCount.toDouble(),
      };
      _isLoading = false;
    });
  }

  Future<void> _loadRawData() async {
    final data = await _db.queryAll(_selectedTable);
    setState(() => _rawData = data);
  }

  Future<void> _deleteRecord(int id) async {
    await _db.delete(_selectedTable, id);
    _loadRawData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record deleted forever.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final todayStr = DateFormat('EEE, MMM d').format(DateTime.now());
    final yesterdayStr = DateFormat('EEE, MMM d').format(DateTime.now().subtract(const Duration(days: 1)));
    final tomorrowStr = DateFormat('EEE, MMM d').format(DateTime.now().add(const Duration(days: 1)));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.red),
        title: const Text(
          'GODMODE — Financial Command',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.red),
            onPressed: _loadSummary,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.red,
          labelColor: Colors.red,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'SUMMARY', icon: Icon(Icons.bar_chart, size: 16)),
            Tab(text: 'TIMELINE', icon: Icon(Icons.timeline, size: 16)),
            Tab(text: 'DATA MGR', icon: Icon(Icons.storage, size: 16)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSummaryTab(yesterdayStr, todayStr, tomorrowStr),
                _buildTimelineTab(yesterdayStr, todayStr, tomorrowStr),
                _buildDataManagerTab(),
              ],
            ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // TAB 1 — SUMMARY (3-column: yesterday / today / all-time)
  // ══════════════════════════════════════════════════════════════
  Widget _buildSummaryTab(String yesterday, String today, String tomorrow) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Header banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade900.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.red, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ADMIN VIEW — All figures in KES. Refreshed: ${DateFormat('HH:mm').format(DateTime.now())}',
                    style: const TextStyle(color: Colors.red, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // TODAY hero card
          _buildDayHeroCard(
            label: '📍 TODAY',
            dateStr: today,
            data: _today,
            color: Colors.green.shade700,
            isToday: true,
          ),
          const SizedBox(height: 12),

          // Yesterday card
          _buildDayHeroCard(
            label: '◀ YESTERDAY CLOSED',
            dateStr: yesterday,
            data: _yesterday,
            color: Colors.blue.shade700,
            isToday: false,
          ),
          const SizedBox(height: 12),

          // Tomorrow preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade700),
            ),
            child: Row(
              children: [
                const Icon(Icons.arrow_forward, color: Colors.grey, size: 18),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('▶ TOMORROW — $tomorrow', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    const Text('Slate starts fresh at midnight. Keep pushing! 💪', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // All-time totals
          _buildAllTimeSummary(),
        ],
      ),
    );
  }

  Widget _buildDayHeroCard({
    required String label,
    required String dateStr,
    required Map<String, double> data,
    required Color color,
    required bool isToday,
  }) {
    final net = data['net'] ?? 0;
    final isProfit = net >= 0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
                  child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                Text(dateStr, style: TextStyle(color: color, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'KES ${net.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: isProfit ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    isProfit ? '▲ PROFIT' : '▼ LOSS',
                    style: TextStyle(color: isProfit ? Colors.greenAccent : Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _miniStatDark('Eat-In', data['eatIn'] ?? 0, Colors.teal),
                const SizedBox(width: 8),
                _miniStatDark('Delivery', data['delivery'] ?? 0, Colors.purple),
                const SizedBox(width: 8),
                _miniStatDark('Expenses', data['expenses'] ?? 0, Colors.red),
              ],
            ),
            if (isToday && (data['unpaid'] ?? 0) > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  _miniStatDark('Unpaid Orders', data['unpaid'] ?? 0, Colors.orange),
                  const SizedBox(width: 8),
                  _miniStatDark('Deni (Credit)', data['deni'] ?? 0, Colors.red.shade300),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _miniStatDark(String label, double value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 9, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text('KES ${value.toStringAsFixed(0)}', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildAllTimeSummary() {
    final net = _allTime['net'] ?? 0;
    final isProfit = net >= 0;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.yellow.shade900.withOpacity(0.2), Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.yellow.shade700.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.yellow.shade700, borderRadius: BorderRadius.circular(6)),
                child: const Text('⚡ ALL-TIME ACCUMULATED', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              Text('${_allTime['orderCount']?.toInt() ?? 0} orders total', style: const TextStyle(color: Colors.yellow, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'NET: KES ${net.toStringAsFixed(0)}',
            style: TextStyle(
              color: isProfit ? Colors.greenAccent : Colors.redAccent,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _miniStatDark('All Eat-In', _allTime['eatIn'] ?? 0, Colors.teal),
              const SizedBox(width: 8),
              _miniStatDark('All Delivery', _allTime['delivery'] ?? 0, Colors.purple),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _miniStatDark('All Expenses', _allTime['expenses'] ?? 0, Colors.red),
              const SizedBox(width: 8),
              _miniStatDark('Pending Deni', _allTime['deni'] ?? 0, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // TAB 2 — TIMELINE (running flow from yesterday to tomorrow)
  // ══════════════════════════════════════════════════════════════
  Widget _buildTimelineTab(String yesterday, String today, String tomorrow) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _timelineItem(
            icon: Icons.history,
            color: Colors.blue,
            label: yesterday,
            title: 'CLOSED — Yesterday',
            subtitle: 'Gross: KES ${(_yesterday['gross'] ?? 0).toStringAsFixed(0)}   Net: KES ${(_yesterday['net'] ?? 0).toStringAsFixed(0)}',
            isActive: false,
            isDone: true,
          ),
          _timelineConnector(),
          _timelineItem(
            icon: Icons.play_circle,
            color: Colors.green,
            label: today,
            title: '▶ LIVE — Today',
            subtitle: 'Revenue so far: KES ${(_today['gross'] ?? 0).toStringAsFixed(0)}\nExpenses: KES ${(_today['expenses'] ?? 0).toStringAsFixed(0)}\nNet: KES ${(_today['net'] ?? 0).toStringAsFixed(0)}',
            isActive: true,
            isDone: false,
          ),
          _timelineConnector(),
          _timelineItem(
            icon: Icons.upcoming,
            color: Colors.grey,
            label: tomorrow,
            title: 'UP NEXT — Tomorrow',
            subtitle: 'Fresh start. Carry forward: KES ${(_today['net'] ?? 0).toStringAsFixed(0)} net from today.',
            isActive: false,
            isDone: false,
          ),
          const SizedBox(height: 24),
          // Running grand total bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.yellow.shade700.withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📊 RUNNING GRAND TOTAL', style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 12),
                _grandTotalRow('All-time Gross Revenue', _allTime['gross'] ?? 0, Colors.greenAccent),
                _grandTotalRow('All-time Expenses', _allTime['expenses'] ?? 0, Colors.redAccent),
                const Divider(color: Colors.grey, height: 24),
                _grandTotalRow('ALL-TIME NET PROFIT', _allTime['net'] ?? 0, (_allTime['net'] ?? 0) >= 0 ? Colors.greenAccent : Colors.redAccent, large: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineItem({
    required IconData icon,
    required Color color,
    required String label,
    required String title,
    required String subtitle,
    required bool isActive,
    required bool isDone,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.15) : Colors.grey.shade900,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isActive ? color : Colors.grey.shade800),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
                    const Spacer(),
                    Text(label, style: TextStyle(color: color, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade400, fontSize: 12, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineConnector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 22),
      child: Column(
        children: List.generate(4, (_) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              SizedBox(width: 16),
              Icon(Icons.more_vert, color: Colors.grey, size: 16),
            ],
          ),
        )),
      ),
    );
  }

  Widget _grandTotalRow(String label, double value, Color color, {bool large = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: Colors.grey.shade400, fontSize: large ? 13 : 12, fontWeight: large ? FontWeight.bold : FontWeight.normal))),
          Text(
            'KES ${value.toStringAsFixed(0)}',
            style: TextStyle(color: color, fontSize: large ? 18 : 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // TAB 3 — DATA MANAGER (raw table viewer with delete)
  // ══════════════════════════════════════════════════════════════
  Widget _buildDataManagerTab() {
    return Column(
      children: [
        Container(
          color: Colors.red.shade900.withOpacity(0.2),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.warning, color: Colors.red, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'DANGER ZONE: Deleting records here is permanent.',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
              DropdownButton<String>(
                dropdownColor: Colors.black,
                style: const TextStyle(color: Colors.red),
                value: _selectedTable,
                items: const [
                  DropdownMenuItem(value: 'sales', child: Text('Sales')),
                  DropdownMenuItem(value: 'orders', child: Text('Orders')),
                  DropdownMenuItem(value: 'expenses', child: Text('Expenses')),
                  DropdownMenuItem(value: 'delivery_orders', child: Text('Deliveries')),
                  DropdownMenuItem(value: 'credits', child: Text('Credits')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() { _selectedTable = val; });
                    _loadRawData();
                  }
                },
              ),
            ],
          ),
        ),
        if (_rawData.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox, color: Colors.grey, size: 48),
                  const SizedBox(height: 12),
                  Text('Tap a table above to load records', style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    onPressed: _loadRawData,
                    child: const Text('Load Records'),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: _rawData.length,
              itemBuilder: (context, index) {
                final row = _rawData[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade800),
                  ),
                  child: ListTile(
                    dense: true,
                    title: Text(
                      'ID: ${row['id']} | ${(row['created_at'] ?? '').toString().split('.')[0]}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white70),
                    ),
                    subtitle: Text(
                      row.toString().replaceAll(RegExp(r'[{}]'), ''),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_forever, color: Colors.red, size: 20),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: Colors.grey.shade900,
                            title: const Text('Confirm Delete', style: TextStyle(color: Colors.red)),
                            content: const Text('This record will be permanently deleted.', style: TextStyle(color: Colors.white70)),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.grey))),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deleteRecord(row['id']);
                                },
                                child: const Text('DELETE'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
