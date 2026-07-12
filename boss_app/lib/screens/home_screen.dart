import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../core/storage/secure_storage.dart';
import '../theme/app_colors.dart';
import '../data/models/audit_log.dart';
import '../providers/report_provider.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int)? onNavigate;
  const HomeScreen({super.key, this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _adminName = 'Admin';

  @override
  void initState() {
    super.initState();
    _loadAdminName();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final range = context.read<ReportProvider>().dateRange;
      await context.read<ReportProvider>().loadSummary(range.start, range.end);
    });
  }

  Future<void> _loadAdminName() async {
    final name = await SecureStorage.getString(AppConstants.keyProfileName);
    if (name != null && name.isNotEmpty && mounted) {
      setState(() => _adminName = name);
    }
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.scaffoldBackground,
      body: Consumer<ReportProvider>(
        builder: (context, reportProvider, _) {
          final logs = reportProvider.recentLogs.take(4).toList();
          final summary = reportProvider.summary;

          return Column(
            children: [
              // Fixed Header with rounded corners
              Container(
                padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 4, 16, 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/hotel_logo.jpg',
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.hotel,
                            color: AppColors.primaryGreen,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${_greeting()}, $_adminName',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Euton Hotel',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary cards
                      _sectionTitle('Today\'s Summary'),
                      const SizedBox(height: 8),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 1.8,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        children: [
                          _buildStatCard('KES ${summary.todaySales.toStringAsFixed(0)}', "Today's Sales", Icons.trending_up_rounded, AppColors.success, AppColors.successLight),
                          _buildStatCard('${summary.totalOrders}', 'Total Orders', Icons.receipt_long_rounded, AppColors.info, AppColors.infoLight),
                          _buildStatCard('KES ${summary.totalExpenses.toStringAsFixed(0)}', 'Expenses', Icons.money_off_rounded, AppColors.error, AppColors.errorLight),
                          _buildStatCard('KES ${summary.netProfit.toStringAsFixed(0)}', 'Net Profit', Icons.account_balance_wallet_rounded, AppColors.orange, AppColors.orangeLight),
                          _buildStatCard('${summary.paidOrders} / ${summary.pendingOrders}', 'Paid / Pending', Icons.table_restaurant_rounded, AppColors.purple, AppColors.purpleLight),
                          _buildStatCard('${summary.staffOnDuty}', 'Staff on Duty', Icons.people_alt_rounded, AppColors.teal, AppColors.tealLight),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Quick Actions
                      _sectionTitle('Quick Actions'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _buildActionCard('View Reports', Icons.bar_chart_rounded, AppColors.success, () => widget.onNavigate?.call(AppConstants.navReports))),
                          const SizedBox(width: 8),
                          Expanded(child: _buildActionCard('Monitor Activity', Icons.monitor_heart_rounded, AppColors.info, () => widget.onNavigate?.call(AppConstants.navMonitoring))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _buildActionCard('Manage Staff', Icons.people_rounded, AppColors.purple, () => widget.onNavigate?.call(AppConstants.navStaff))),
                          const SizedBox(width: 8),
                          Expanded(child: _buildActionCard('Settings', Icons.settings_rounded, AppColors.textSecondary, () => widget.onNavigate?.call(AppConstants.navSettings))),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Recent Activity
                      _sectionTitle('Recent Activity'),
                      const SizedBox(height: 8),
                      logs.isEmpty
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkCard : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Center(
                                child: Text(
                                  'No recent activity logs',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                ),
                              ),
                            )
                          : Column(
                              children: logs.map((log) => _buildActivityItem(log, isDark)).toList(),
                            ),

                      const SizedBox(height: 16),

                      // System Status
                      _sectionTitle('System Status'),
                      const SizedBox(height: 8),
                      _buildStatusContainer(isDark),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCard
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkCard
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(AuditLog log, bool isDark) {
    Color severityColor;
    switch (log.severity) {
      case AuditSeverity.info:
        severityColor = AppColors.info;
        break;
      case AuditSeverity.success:
        severityColor = AppColors.success;
        break;
      case AuditSeverity.warning:
        severityColor = AppColors.warning;
        break;
      case AuditSeverity.error:
        severityColor = AppColors.error;
        break;
    }

    final timeStr = _formatTime(log.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: severityColor, width: 3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${log.moduleLabel} · ${log.actionLabel}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  log.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeStr,
                style: const TextStyle(color: AppColors.textHint, fontSize: 11),
              ),
              if (log.amount != null)
                Text(
                  '${log.module == AuditModule.expense ? "-" : "+"}KES ${log.amount!.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: log.module == AuditModule.expense ? AppColors.error : AppColors.success,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Widget _buildStatusContainer(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _statusRow('System', 'Operational', true, isDark),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _statusRow('Database API', 'Connected', true, isDark),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _statusRow('Sync Status', 'Synchronized', true, isDark),
        ],
      ),
    );
  }

  Widget _statusRow(String label, String value, bool isOk, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(
            isOk ? Icons.check_circle_rounded : Icons.warning_rounded,
            color: isOk ? AppColors.success : AppColors.warning,
            size: 18,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: isOk ? AppColors.success : AppColors.warning,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
