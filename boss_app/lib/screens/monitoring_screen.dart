import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../data/models/audit_log.dart';
import '../providers/report_provider.dart';
import 'package:provider/provider.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  AuditModule? _moduleFilter;
  AuditSeverity? _severityFilter;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final reportProvider = context.read<ReportProvider>();
      final range = reportProvider.dateRange;
      await reportProvider.loadSummary(range.start, range.end);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AuditLog> _filteredLogs(List<AuditLog> logs) {
    return logs.where((log) {
      if (_moduleFilter != null && log.module != _moduleFilter) return false;
      if (_severityFilter != null && log.severity != _severityFilter) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return log.description.toLowerCase().contains(q) ||
            log.user.toLowerCase().contains(q) ||
            log.entity.toLowerCase().contains(q) ||
            (log.entityId?.toLowerCase().contains(q) ?? false);
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        title: const Text('Audit Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () async {
              final reportProvider = context.read<ReportProvider>();
              final range = reportProvider.dateRange;
              await reportProvider.loadSummary(range.start, range.end);
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterSheet(context, isDark),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Consumer<ReportProvider>(
        builder: (context, reportProvider, _) {
          final allLogs = reportProvider.recentLogs;
          final filtered = _filteredLogs(allLogs);

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search logs...',
                      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, color: AppColors.textHint, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),

              // Active filters
              if (_moduleFilter != null || _severityFilter != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      if (_moduleFilter != null)
                        _filterChip(
                          _moduleFilter!.name.toUpperCase(),
                          () => setState(() => _moduleFilter = null),
                        ),
                      if (_severityFilter != null)
                        _filterChip(
                          _severityFilter!.name.toUpperCase(),
                          () => setState(() => _severityFilter = null),
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // Summary stat row
              if (allLogs.isNotEmpty)
                _buildStatRow(allLogs, isDark),

              const SizedBox(height: 8),

              // Logs list
              Expanded(
                child: reportProvider.isLoading
                    ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                    : filtered.isEmpty
                        ? _buildEmptyState(allLogs.isEmpty)
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) =>
                                _buildLogCard(filtered[index], isDark),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatRow(List<AuditLog> logs, bool isDark) {
    final errors = logs.where((l) => l.severity == AuditSeverity.error).length;
    final warnings = logs.where((l) => l.severity == AuditSeverity.warning).length;
    final revenue = logs
        .where((l) => l.module == AuditModule.payment)
        .fold<double>(0, (sum, l) => sum + (l.amount ?? 0));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _miniStat('${logs.length}', 'Events', AppColors.info, isDark),
          const SizedBox(width: 8),
          _miniStat('$errors', 'Errors', AppColors.error, isDark),
          const SizedBox(width: 8),
          _miniStat('$warnings', 'Warnings', AppColors.warning, isDark),
          const SizedBox(width: 8),
          _miniStat('KES ${revenue.toStringAsFixed(0)}', 'Payments', AppColors.success, isDark),
        ],
      ),
    );
  }

  Widget _miniStat(String value, String label, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: const TextStyle(color: AppColors.textHint, fontSize: 9, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogCard(AuditLog log, bool isDark) {
    final color = _severityColor(log.severity);
    final timeStr = _formatTime(log.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Module + Action badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${log.moduleLabel} · ${log.actionLabel}',
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                timeStr,
                style: const TextStyle(color: AppColors.textHint, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.description,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 12, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text(log.user, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                        if (log.entityId != null) ...[
                          const SizedBox(width: 12),
                          const Icon(Icons.tag_rounded, size: 12, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          Text(log.entityId!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (log.amount != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'KES ${log.amount!.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: log.module == AuditModule.expense
                            ? AppColors.error
                            : AppColors.success,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool noLogs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shield_outlined,
                size: 48,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              noLogs ? 'No audit logs yet' : 'No matching logs',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              noLogs
                  ? 'Audit logs will appear here as your team uses the POS system.'
                  : 'Try adjusting your search or filters.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, VoidCallback onDelete) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
      backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
      labelStyle: const TextStyle(color: AppColors.primaryGreen),
      deleteIcon: const Icon(Icons.close_rounded, size: 14, color: AppColors.primaryGreen),
      onDeleted: onDelete,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  void _showFilterSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.dividerLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Filter Logs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                const Text('MODULE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AuditModule.values.map((m) {
                    final selected = _moduleFilter == m;
                    return GestureDetector(
                      onTap: () {
                        setSheetState(() {});
                        setState(() => _moduleFilter = selected ? null : m);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primaryGreen : AppColors.primaryGreen.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          m.name.toUpperCase(),
                          style: TextStyle(
                            color: selected ? Colors.white : AppColors.primaryGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Text('SEVERITY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: AuditSeverity.values.map((s) {
                    final color = _severityColor(s);
                    final selected = _severityFilter == s;
                    return GestureDetector(
                      onTap: () {
                        setSheetState(() {});
                        setState(() => _severityFilter = selected ? null : s);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? color : color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          s.name.toUpperCase(),
                          style: TextStyle(
                            color: selected ? Colors.white : color,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _moduleFilter = null;
                        _severityFilter = null;
                      });
                      Navigator.pop(ctx);
                    },
                    child: const Text('Clear All Filters', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _severityColor(AuditSeverity severity) {
    switch (severity) {
      case AuditSeverity.info: return AppColors.info;
      case AuditSeverity.success: return AppColors.success;
      case AuditSeverity.warning: return AppColors.warning;
      case AuditSeverity.error: return AppColors.error;
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
