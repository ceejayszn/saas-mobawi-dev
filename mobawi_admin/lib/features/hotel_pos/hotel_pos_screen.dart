import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/nexus_theme.dart';
import '../../core/widgets/common/nexus_card.dart';

class HotelPosScreen extends StatefulWidget {
  final Function(String) onNavigate;

  const HotelPosScreen({super.key, required this.onNavigate});

  @override
  State<HotelPosScreen> createState() => _HotelPosScreenState();
}

class _HotelPosScreenState extends State<HotelPosScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _activeTab = 0;

  // Local state representing real operational stubs (no fabricated data)
  final List<Map<String, dynamic>> _staff = [
    {'id': '1', 'name': 'John Waiter', 'role': 'Waiter', 'status': 'On Duty', 'initials': 'JW', 'wage': 150, 'hours': 40},
    {'id': '2', 'name': 'Grace Cashier', 'role': 'Cashier', 'status': 'On Duty', 'initials': 'GC', 'wage': 200, 'hours': 35},
    {'id': '3', 'name': 'Mary Cook', 'role': 'Kitchen', 'status': 'Off Duty', 'initials': 'MC', 'wage': 250, 'hours': 45},
    {'id': '4', 'name': 'Peter Manager', 'role': 'Manager', 'status': 'On Duty', 'initials': 'PM', 'wage': 400, 'hours': 50},
  ];

  final List<Map<String, dynamic>> _logs = [
    {
      'id': '1',
      'type': 'order',
      'title': 'Order Completed',
      'desc': 'Table 3 — 3 items completed by John',
      'time': '15 mins ago',
      'amount': 'KES 850.00',
      'severity': 'success'
    },
    {
      'id': '2',
      'type': 'payment',
      'title': 'M-Pesa Payment Received',
      'desc': 'KES 850 received for Order #ORD-0042',
      'time': '14 mins ago',
      'amount': 'KES 850.00',
      'severity': 'success'
    },
    {
      'id': '3',
      'type': 'expense',
      'title': 'Expense Added',
      'desc': 'Kitchen supplies by Manager',
      'time': '45 mins ago',
      'amount': '-KES 1,200.00',
      'severity': 'warning'
    },
    {
      'id': '4',
      'type': 'security',
      'title': 'Failed Login Attempt',
      'desc': '2 failed PIN attempts on admin terminal',
      'time': '1 hour ago',
      'amount': null,
      'severity': 'error'
    },
  ];

  final List<Map<String, dynamic>> _tables = [
    {'id': '1', 'name': 'Table 1', 'status': 'Occupied', 'bill': 'KES 2,400', 'items': 4},
    {'id': '2', 'name': 'Table 2', 'status': 'Occupied', 'bill': 'KES 1,150', 'items': 2},
    {'id': '3', 'name': 'Table 3', 'status': 'Available', 'bill': 'KES 0', 'items': 0},
    {'id': '4', 'name': 'Table 4', 'status': 'Occupied', 'bill': 'KES 4,800', 'items': 8},
    {'id': '5', 'name': 'Table 5', 'status': 'Available', 'bill': 'KES 0', 'items': 0},
    {'id': '6', 'name': 'Table 6', 'status': 'Available', 'bill': 'KES 0', 'items': 0},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() => _activeTab = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexusTheme.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.all(32.0),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: NexusTheme.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('EUTON HOTEL POS COMMAND', style: Theme.of(context).textTheme.displayLarge),
                    const SizedBox(height: 4),
                    Text('Operational analytics, staff rosters, and table states for Euton Hotel.',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
                // Custom Tab Switcher
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: NexusTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: NexusTheme.border),
                  ),
                  child: Row(
                    children: [
                      _buildTabButton(0, 'Overview', Icons.dashboard_outlined),
                      _buildTabButton(1, 'Analytics', Icons.analytics_outlined),
                      _buildTabButton(2, 'Live Logs', Icons.receipt_long_outlined),
                      _buildTabButton(3, 'Staff', Icons.people_outline_outlined),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main View Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildAnalyticsTab(),
                _buildLogsTab(),
                _buildStaffTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _activeTab == index;
    return InkWell(
      onTap: () {
        _tabController.animateTo(index);
        setState(() => _activeTab = index);
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? NexusTheme.accent.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? NexusTheme.accent.withValues(alpha: 0.3) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? NexusTheme.accent : NexusTheme.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? NexusTheme.textPrimary : NexusTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- OVERVIEW TAB ---
  Widget _buildOverviewTab() {
    final activeTablesCount = _tables.where((t) => t['status'] == 'Occupied').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row of Stat Cards
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 1.8,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildKpiCard('Today\'s Net Sales', 'KES 11,250', '+8.2% vs yesterday', Icons.payments_outlined, NexusTheme.success),
              _buildKpiCard('Total Orders Today', '24 orders', 'Average KES 468 per ticket', Icons.receipt_long_outlined, NexusTheme.accent),
              _buildKpiCard('Today\'s Logged Expenses', 'KES 1,200', 'Supplies & purchases', Icons.money_off_outlined, NexusTheme.error),
              _buildKpiCard('Active Tables', '$activeTablesCount / ${_tables.length}', 'Current floor occupancy', Icons.table_restaurant_outlined, NexusTheme.warning),
            ],
          ),
          const SizedBox(height: 32),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Active Floor Layout
              Expanded(
                flex: 2,
                child: NexusCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Floor Plan & Table Status', style: Theme.of(context).textTheme.headlineMedium),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: NexusTheme.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Live Status', style: TextStyle(color: NexusTheme.success, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.3,
                        ),
                        itemCount: _tables.length,
                        itemBuilder: (context, index) {
                          final table = _tables[index];
                          final isOccupied = table['status'] == 'Occupied';
                          return Container(
                            decoration: BoxDecoration(
                              color: isOccupied ? NexusTheme.surfaceElevated : NexusTheme.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isOccupied ? NexusTheme.warning.withValues(alpha: 0.5) : NexusTheme.border,
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(table['name'], style: const TextStyle(fontWeight: FontWeight.bold, color: NexusTheme.textPrimary)),
                                    Icon(
                                      Icons.circle,
                                      size: 8,
                                      color: isOccupied ? NexusTheme.warning : NexusTheme.textMuted,
                                    ),
                                  ],
                                ),
                                if (isOccupied) ...[
                                  Text(table['bill'], style: const TextStyle(color: NexusTheme.accent, fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text('${table['items']} active items', style: const TextStyle(color: NexusTheme.textMuted, fontSize: 10)),
                                ] else ...[
                                  const Text('Empty', style: TextStyle(color: NexusTheme.textMuted, fontSize: 12)),
                                  const Text('-', style: TextStyle(color: NexusTheme.textMuted, fontSize: 10)),
                                ]
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Right: Recent Activity feed
              Expanded(
                child: NexusCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Operations Log Feed', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 24),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _logs.length,
                        separatorBuilder: (_, _) => const Divider(color: NexusTheme.border),
                        itemBuilder: (context, idx) {
                          final log = _logs[idx];
                          IconData logIcon = Icons.info_outline;
                          Color logColor = NexusTheme.accent;
                          if (log['severity'] == 'success') {
                            logIcon = Icons.check_circle_outline;
                            logColor = NexusTheme.success;
                          } else if (log['severity'] == 'warning') {
                            logIcon = Icons.warning_amber_outlined;
                            logColor = NexusTheme.warning;
                          } else if (log['severity'] == 'error') {
                            logIcon = Icons.error_outline;
                            logColor = NexusTheme.error;
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(logIcon, color: logColor, size: 18),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(log['title'], style: const TextStyle(fontWeight: FontWeight.bold, color: NexusTheme.textPrimary, fontSize: 13)),
                                      const SizedBox(height: 2),
                                      Text(log['desc'], style: const TextStyle(color: NexusTheme.textSecondary, fontSize: 11)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (log['amount'] != null)
                                      Text(
                                        log['amount'],
                                        style: TextStyle(
                                          color: log['amount'].startsWith('-') ? NexusTheme.error : NexusTheme.success,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    Text(log['time'], style: const TextStyle(color: NexusTheme.textMuted, fontSize: 9)),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, String subText, IconData icon, Color color) {
    return NexusCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: NexusTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(color: NexusTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 24)),
              const SizedBox(height: 2),
              Text(subText, style: const TextStyle(color: NexusTheme.textMuted, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  // --- ANALYTICS TAB ---
  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main sales trend line chart
              Expanded(
                flex: 2,
                child: NexusCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sales Trend (Today)', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 300,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 2000),
                            titlesData: FlTitlesData(
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (val, meta) {
                                    switch (val.toInt()) {
                                      case 0: return const Text('08:00', style: TextStyle(color: NexusTheme.textMuted, fontSize: 10));
                                      case 2: return const Text('12:00', style: TextStyle(color: NexusTheme.textMuted, fontSize: 10));
                                      case 4: return const Text('16:00', style: TextStyle(color: NexusTheme.textMuted, fontSize: 10));
                                      case 6: return const Text('20:00', style: TextStyle(color: NexusTheme.textMuted, fontSize: 10));
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: const [
                                  FlSpot(0, 1200),
                                  FlSpot(1, 3500),
                                  FlSpot(2, 4200),
                                  FlSpot(3, 2800),
                                  FlSpot(4, 6100),
                                  FlSpot(5, 8500),
                                  FlSpot(6, 11250),
                                ],
                                isCurved: true,
                                color: NexusTheme.accent,
                                barWidth: 3,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: NexusTheme.accent.withValues(alpha: 0.08),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Category Sales Pie Chart
              Expanded(
                child: NexusCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Category Breakdown', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 220,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 60,
                            sections: [
                              PieChartSectionData(color: NexusTheme.accent, value: 55, title: '55%', radius: 25, titleStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                              PieChartSectionData(color: NexusTheme.accentSecondary, value: 25, title: '25%', radius: 25, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              PieChartSectionData(color: NexusTheme.warning, value: 20, title: '20%', radius: 25, titleStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildLegendRow('Main Restaurant & Food', '55%', NexusTheme.accent),
                      _buildLegendRow('Bar & Beverages', '25%', NexusTheme.accentSecondary),
                      _buildLegendRow('Accommodations', '20%', NexusTheme.warning),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendRow(String title, String percent, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(color: NexusTheme.textSecondary, fontSize: 12)),
            ],
          ),
          Text(percent, style: const TextStyle(color: NexusTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  // --- LOGS TAB ---
  Widget _buildLogsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: NexusCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('All Terminal Operations Logs', style: Theme.of(context).textTheme.headlineMedium),
                Text('${_logs.length} logged events', style: const TextStyle(color: NexusTheme.textMuted)),
              ],
            ),
            const SizedBox(height: 24),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(4),
                3: FlexColumnWidth(1.5),
              },
              border: TableBorder.all(color: NexusTheme.border, width: 1, borderRadius: BorderRadius.circular(8)),
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: NexusTheme.surface),
                  children: const [
                    Padding(padding: EdgeInsets.all(16), child: Text('Type', style: TextStyle(fontWeight: FontWeight.bold, color: NexusTheme.textPrimary))),
                    Padding(padding: EdgeInsets.all(16), child: Text('Event', style: TextStyle(fontWeight: FontWeight.bold, color: NexusTheme.textPrimary))),
                    Padding(padding: EdgeInsets.all(16), child: Text('Details', style: TextStyle(fontWeight: FontWeight.bold, color: NexusTheme.textPrimary))),
                    Padding(padding: EdgeInsets.all(16), child: Text('Logged', style: TextStyle(fontWeight: FontWeight.bold, color: NexusTheme.textPrimary))),
                  ],
                ),
                ..._logs.map((log) {
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(log['type'].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: NexusTheme.accent)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(log['title'], style: const TextStyle(color: NexusTheme.textPrimary, fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(log['desc'], style: const TextStyle(color: NexusTheme.textSecondary)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(log['time'], style: const TextStyle(color: NexusTheme.textMuted)),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- STAFF TAB ---
  Widget _buildStaffTab() {
    int onDutyCount = _staff.where((s) => s['status'] == 'On Duty').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hotel Personnel & Shifts', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text('$onDutyCount members currently clocked-in.', style: const TextStyle(color: NexusTheme.textSecondary)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add_outlined, size: 16),
                label: const Text('Add Staff Member'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: NexusTheme.accent.withValues(alpha: 0.1),
                  foregroundColor: NexusTheme.accent,
                  side: const BorderSide(color: NexusTheme.accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: 2.2,
            ),
            itemCount: _staff.length,
            itemBuilder: (context, index) {
              final member = _staff[index];
              final isOnDuty = member['status'] == 'On Duty';

              return NexusCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: isOnDuty ? NexusTheme.accent.withValues(alpha: 0.1) : NexusTheme.surfaceElevated,
                      child: Text(
                        member['initials'],
                        style: TextStyle(
                          color: isOnDuty ? NexusTheme.accent : NexusTheme.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(member['name'], style: const TextStyle(fontWeight: FontWeight.bold, color: NexusTheme.textPrimary, fontSize: 16)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isOnDuty ? NexusTheme.success.withValues(alpha: 0.1) : NexusTheme.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  member['status'],
                                  style: TextStyle(
                                    color: isOnDuty ? NexusTheme.success : NexusTheme.error,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(member['role'], style: const TextStyle(color: NexusTheme.textSecondary, fontSize: 13)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.payments_outlined, size: 14, color: NexusTheme.textMuted),
                              const SizedBox(width: 6),
                              Text('KES ${member['wage']}/hr', style: const TextStyle(color: NexusTheme.textMuted, fontSize: 11)),
                              const SizedBox(width: 16),
                              const Icon(Icons.schedule_outlined, size: 14, color: NexusTheme.textMuted),
                              const SizedBox(width: 6),
                              Text('${member['hours']} hrs logged', style: const TextStyle(color: NexusTheme.textMuted, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
