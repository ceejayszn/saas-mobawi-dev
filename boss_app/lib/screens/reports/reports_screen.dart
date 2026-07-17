import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';

class BossReportsScreen extends StatefulWidget {
  const BossReportsScreen({super.key});

  @override
  State<BossReportsScreen> createState() => _BossReportsScreenState();
}

class _BossReportsScreenState extends State<BossReportsScreen> {
  final String _businessName = 'Natty Gym';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: Text('$_businessName Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Net profit / Overview
            _buildProfitLossCard(isDark),
            const SizedBox(height: 20),

            _sectionTitle('Stats Grid'),
            const SizedBox(height: 10),
            _buildCompactStatsGrid(isDark),
            const SizedBox(height: 24),

            _sectionTitle('Weekly Attendance Trends'),
            const SizedBox(height: 10),
            _buildChartCard(isDark),
            const SizedBox(height: 24),

            _sectionTitle('Reports & Drilldown'),
            const SizedBox(height: 10),
            _buildReportCategoryList(isDark),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
  }

  Widget _buildProfitLossCard(bool isDark) {
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('NET GYM PROFIT', style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1)),
              Spacer(),
              Icon(Icons.trending_up, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            '\$9,540',
            style: TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _netStatItem('Revenue', '\$12,400', Icons.arrow_upward, Colors.greenAccent),
              _netStatItem('Expenses', '\$2,860', Icons.arrow_downward, Colors.redAccent),
              _netStatItem('Cash Flow', '\$8,400', Icons.account_balance_wallet, Colors.amberAccent),
            ],
          ),
        ],
      ),
    );
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
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCompactStatsGrid(bool isDark) {
    final stats = [
      _StatCard("Today's Sales", '\$1,240', Icons.today, AppColors.success, AppColors.successLight),
      _StatCard('Weekly Sales', '\$6,420', Icons.calendar_view_week, AppColors.info, AppColors.infoLight),
      _StatCard('Active Plans', '342 Members', Icons.people, AppColors.purple, AppColors.purpleLight),
      _StatCard('Monthly Profit', '\$9,540', Icons.trending_up, AppColors.teal, AppColors.tealLight),
      _StatCard('Check Ins Today', '162 Visits', Icons.login, AppColors.orange, AppColors.orangeLight),
      _StatCard('Low Stock Products', '2 items', Icons.inventory, AppColors.warning, AppColors.warningLight),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(color: stat.bgColor, borderRadius: BorderRadius.circular(7)),
                child: Icon(stat.icon, color: stat.color, size: 13),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stat.value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                  Text(stat.label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 9), overflow: TextOverflow.ellipsis),
                ],
              ),
            ],
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
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  if (v >= 0 && v < days.length) {
                    return Text(days[v.toInt()], style: const TextStyle(color: AppColors.textSecondary, fontSize: 9));
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
                FlSpot(0, 110), FlSpot(1, 130), FlSpot(2, 125),
                FlSpot(3, 145), FlSpot(4, 160), FlSpot(5, 175), FlSpot(6, 120),
              ],
              isCurved: true,
              color: AppColors.primaryGreen,
              barWidth: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCategoryList(bool isDark) {
    final categories = [
      _ReportCat('Membership Growth', Icons.trending_up, AppColors.success),
      _ReportCat('Revenue Analysis', Icons.attach_money, AppColors.primaryGreen),
      _ReportCat('Peak Gym Hours', Icons.access_time, AppColors.info),
      _ReportCat('Inventory & Sales', Icons.storefront, AppColors.warning),
      _ReportCat('Staff Audits', Icons.people, AppColors.purple),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: categories.asMap().entries.map((entry) {
          final cat = entry.value;
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: cat.color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(cat.icon, color: cat.color, size: 18),
            ),
            title: Text(cat.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Detailed view for ${cat.title} exported to PDF/CSV')),
              );
            },
          );
        }).toList(),
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
