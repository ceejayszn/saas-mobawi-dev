import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/report_provider.dart';
import '../../data/repositories/i_report_repository.dart';
import '../../core/utils/export_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/storage/secure_storage.dart';
import 'report_detail_screen.dart';

class BossReportsScreen extends StatefulWidget {
  const BossReportsScreen({super.key});

  @override
  State<BossReportsScreen> createState() => _BossReportsScreenState();
}

class _BossReportsScreenState extends State<BossReportsScreen> {
  String _adminName = 'Admin';
  String _businessName = 'Euton Hotel';

  @override
  void initState() {
    super.initState();
    _loadMeta();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final range = context.read<ReportProvider>().dateRange;
      await context.read<ReportProvider>().loadSummary(range.start, range.end);
    });
  }

  Future<void> _loadMeta() async {
    final name = await SecureStorage.getString(AppConstants.keyProfileName);
    final biz = await SecureStorage.getString(AppConstants.keyBusinessName);
    if (mounted) {
      setState(() {
        if (name != null && name.isNotEmpty) _adminName = name;
        if (biz != null && biz.isNotEmpty) _businessName = biz;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            onPressed: () => _showExportOptions(context, isDark),
            tooltip: 'Print & Export',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Consumer<ReportProvider>(
            builder: (context, reportProvider, _) => Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.scaffoldBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: ReportPeriod.values.map((period) {
                  final isSelected = reportProvider.period == period;
                  final labels = ['Today', 'Week', 'Month', 'Year'];
                  final idx = period.index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => reportProvider.setPeriod(period),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.all(4),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          labels[idx],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<ReportProvider>(
        builder: (context, reportProvider, _) {
          if (reportProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }

          final summary = reportProvider.summary;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero P&L card
                _buildProfitLossCard(summary, reportProvider.period, isDark),
                const SizedBox(height: 20),

                // Compact stats grid (50% smaller than original)
                _sectionTitle('Summary'),
                const SizedBox(height: 10),
                _buildCompactStatsGrid(summary, isDark),
                const SizedBox(height: 24),

                // Sales chart placeholder
                _sectionTitle('Sales Trend'),
                const SizedBox(height: 10),
                _buildChartCard(isDark),
                const SizedBox(height: 24),

                // Detailed report categories
                _sectionTitle('Detailed Reports'),
                const SizedBox(height: 10),
                _buildReportCategoryList(isDark),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800));
  }

  Widget _buildProfitLossCard(ReportSummary summary, ReportPeriod period, bool isDark) {
    final periodLabel = ['TODAY', 'THIS WEEK', 'THIS MONTH', 'THIS YEAR'][period.index];
    final sales = _salesForPeriod(summary, period);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  periodLabel,
                  style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1),
                ),
              ),
              const Spacer(),
              const Icon(Icons.trending_up_rounded, color: Colors.white60, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          const Text('NET PROFIT / LOSS', style: TextStyle(color: Colors.white60, fontSize: 11, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(
            'KES ${summary.netProfit.toStringAsFixed(0)}',
            style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _netStatItem('Revenue', 'KES ${sales.toStringAsFixed(0)}', Icons.arrow_upward_rounded, Colors.greenAccent),
              _netStatItem('Expenses', 'KES ${summary.totalExpenses.toStringAsFixed(0)}', Icons.arrow_downward_rounded, Colors.redAccent),
              _netStatItem('Cash', 'KES ${summary.cashRevenue.toStringAsFixed(0)}', Icons.account_balance_wallet_outlined, Colors.amberAccent),
            ],
          ),
        ],
      ),
    );
  }

  double _salesForPeriod(ReportSummary s, ReportPeriod period) {
    switch (period) {
      case ReportPeriod.today: return s.todaySales;
      case ReportPeriod.week: return s.weeklySales;
      case ReportPeriod.month: return s.monthlySales;
      case ReportPeriod.year: return s.annualSales;
    }
  }

  Widget _netStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildCompactStatsGrid(ReportSummary summary, bool isDark) {
    // Compact cards: 3 columns, smaller aspect ratio (50% of original)
    final stats = [
      _StatCard("Today's Sales", 'KES ${summary.todaySales.toStringAsFixed(0)}', Icons.today_rounded, AppColors.success, AppColors.successLight),
      _StatCard('Weekly Sales', 'KES ${summary.weeklySales.toStringAsFixed(0)}', Icons.calendar_view_week_rounded, AppColors.info, AppColors.infoLight),
      _StatCard('Monthly', 'KES ${summary.monthlySales.toStringAsFixed(0)}', Icons.calendar_view_month_rounded, AppColors.purple, AppColors.purpleLight),
      _StatCard('Annual', 'KES ${summary.annualSales.toStringAsFixed(0)}', Icons.bar_chart_rounded, AppColors.teal, AppColors.tealLight),
      _StatCard('Total Orders', '${summary.totalOrders}', Icons.receipt_long_rounded, AppColors.orange, AppColors.orangeLight),
      _StatCard('Paid Orders', '${summary.paidOrders}', Icons.check_circle_rounded, AppColors.success, AppColors.successLight),
      _StatCard('Pending', '${summary.pendingOrders}', Icons.pending_rounded, AppColors.warning, AppColors.warningLight),
      _StatCard('Deliveries', '${summary.deliveries}', Icons.delivery_dining_rounded, AppColors.info, AppColors.infoLight),
      _StatCard('Expenses', 'KES ${summary.totalExpenses.toStringAsFixed(0)}', Icons.money_off_rounded, AppColors.error, AppColors.errorLight),
      _StatCard('Net Profit', 'KES ${summary.netProfit.toStringAsFixed(0)}', Icons.trending_up_rounded, AppColors.primaryGreen, AppColors.successLight),
      _StatCard('Cash', 'KES ${summary.cashRevenue.toStringAsFixed(0)}', Icons.money_rounded, AppColors.success, AppColors.successLight),
      _StatCard('M-Pesa', 'KES ${summary.mpesaRevenue.toStringAsFixed(0)}', Icons.phone_android_rounded, AppColors.success, AppColors.successLight),
      _StatCard('Staff on Duty', '${summary.staffOnDuty}', Icons.people_rounded, AppColors.teal, AppColors.tealLight),
      _StatCard('Low Stock', '${summary.lowStockItems}', Icons.inventory_2_rounded, AppColors.warning, AppColors.warningLight),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 columns = 50% smaller effective size
        childAspectRatio: 1.3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final stat = stats[index];
        return GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ReportDetailScreen(title: stat.label)),
          ),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: stat.bgColor,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(stat.icon, color: stat.color, size: 13),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat.value,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      stat.label,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 9),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChartCard(bool isDark) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sales Overview (KES)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: isDark ? AppColors.darkBorder : AppColors.dividerLight,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: 1,
                      getTitlesWidget: (v, _) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        final i = v.toInt();
                        if (i >= 0 && i < days.length) {
                          return Text(days[i], style: const TextStyle(color: AppColors.textSecondary, fontSize: 9));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 0), FlSpot(1, 0), FlSpot(2, 0),
                      FlSpot(3, 0), FlSpot(4, 0), FlSpot(5, 0), FlSpot(6, 0),
                    ],
                    isCurved: true,
                    color: AppColors.primaryGreen,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
                        radius: 3,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: AppColors.primaryGreen,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryGreen.withValues(alpha: 0.2),
                          AppColors.primaryGreen.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCategoryList(bool isDark) {
    final categories = [
      _ReportCat('Daily Sales Report', Icons.today_rounded, AppColors.success),
      _ReportCat('Weekly Report', Icons.calendar_view_week_rounded, AppColors.info),
      _ReportCat('Monthly Report', Icons.calendar_view_month_rounded, AppColors.purple),
      _ReportCat('Annual Report', Icons.bar_chart_rounded, AppColors.teal),
      _ReportCat('Cash Flow', Icons.account_balance_wallet_rounded, AppColors.orange),
      _ReportCat('Revenue Analysis', Icons.analytics_rounded, AppColors.primaryGreen),
      _ReportCat('Expenses Breakdown', Icons.money_off_rounded, AppColors.error),
      _ReportCat('Product Performance', Icons.restaurant_menu_rounded, AppColors.warning),
      _ReportCat('M-Pesa vs Cash', Icons.compare_rounded, AppColors.info),
      _ReportCat('Inventory Reports', Icons.inventory_2_rounded, AppColors.warning),
      _ReportCat('Staff Performance', Icons.people_rounded, AppColors.purple),
      _ReportCat('Peak Hours Analysis', Icons.access_time_rounded, AppColors.success),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
      ),
      child: Column(
        children: categories.asMap().entries.map((entry) {
          final i = entry.key;
          final cat = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cat.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(cat.icon, color: cat.color, size: 18),
                ),
                title: Text(cat.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ReportDetailScreen(title: cat.title)),
                ),
              ),
              if (i < categories.length - 1)
                const Divider(height: 1, indent: 60, endIndent: 20),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showExportOptions(BuildContext context, bool isDark) {
    final reportProvider = context.read<ReportProvider>();
    final summary = reportProvider.summary;
    final items = reportProvider.dailyItems;
    final periodLabel = ['Today', 'Week', 'Month', 'Year'][reportProvider.period.index];
    final adminName = _adminName;
    final businessName = _businessName;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.dividerLight,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Print & Export',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Period: $periodLabel',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 20),

            // ── PDF Invoice (share/save)
            _exportBtn(
              ctx,
              Icons.picture_as_pdf_rounded,
              'Save / Share Invoice PDF',
              'Full invoice with all metrics and itemised list',
              AppColors.error,
              () async {
                Navigator.of(ctx).pop();
                await ExportService.shareInvoicePdf(
                  summary, periodLabel, items,
                  adminName: adminName,
                  businessName: businessName,
                );
              },
            ),
            const SizedBox(height: 10),

            // ── Print full invoice (laser/inkjet)
            _exportBtn(
              ctx,
              Icons.print_rounded,
              'Print Invoice',
              'Send to laser or inkjet printer',
              AppColors.purple,
              () async {
                Navigator.of(ctx).pop();
                await ExportService.printInvoice(
                  summary, periodLabel, items,
                  adminName: adminName,
                  businessName: businessName,
                );
              },
            ),
            const SizedBox(height: 10),

            // ── Thermal receipt
            _exportBtn(
              ctx,
              Icons.receipt_long_rounded,
              'Print Receipt (Thermal)',
              'Compact 58mm/80mm receipt printer format',
              AppColors.teal,
              () async {
                Navigator.of(ctx).pop();
                await ExportService.printThermalReceipt(
                  summary, periodLabel,
                  adminName: adminName,
                  businessName: businessName,
                );
              },
            ),
            const SizedBox(height: 10),

            // ── CSV export
            _exportBtn(
              ctx,
              Icons.table_chart_rounded,
              'Export as CSV',
              'Spreadsheet-compatible data export',
              AppColors.info,
              () async {
                Navigator.of(ctx).pop();
                await ExportService.shareCsv(summary, periodLabel);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _exportBtn(
    BuildContext ctx,
    IconData icon,
    String label,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.25)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: color,
                            fontSize: 14)),
                    Text(subtitle,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: color.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard {
  final String label, value;
  final IconData icon;
  final Color color, bgColor;
  const _StatCard(this.label, this.value, this.icon, this.color, this.bgColor);
}

class _ReportCat {
  final String title;
  final IconData icon;
  final Color color;
  const _ReportCat(this.title, this.icon, this.color);
}
