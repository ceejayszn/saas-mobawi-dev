// ReportProvider — sits between ReportRepository and UI
// UI observes this provider; business logic stays here, not in widgets.

import 'package:flutter/material.dart';
import '../../data/models/audit_log.dart';
import '../../data/repositories/i_report_repository.dart';
import '../../data/repositories/i_audit_log_repository.dart';

enum ReportPeriod { today, week, month, year }

class ReportProvider with ChangeNotifier {
  final IReportRepository _reportRepository;
  final IAuditLogRepository _auditLogRepository;

  ReportProvider(this._reportRepository, this._auditLogRepository) {
    loadSummary(DateTime.now(), DateTime.now());
  }

  ReportPeriod _period = ReportPeriod.today;
  ReportSummary _summary = const ReportSummary();
  List<DailySaleItem> _dailyItems = [];
  List<AuditLog> _recentLogs = [];
  bool _isLoading = false;
  String? _error;

  ReportPeriod get period => _period;
  ReportSummary get summary => _summary;
  List<DailySaleItem> get dailyItems => _dailyItems;
  List<AuditLog> get recentLogs => _recentLogs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  DateTimeRange get dateRange {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_period) {
      case ReportPeriod.today:
        return DateTimeRange(
          start: today,
          end: today.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1)),
        );
      case ReportPeriod.week:
        final start = today.subtract(Duration(days: today.weekday - 1));
        return DateTimeRange(start: start, end: start.add(const Duration(days: 7)));
      case ReportPeriod.month:
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 1).subtract(const Duration(milliseconds: 1)),
        );
      case ReportPeriod.year:
        return DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: DateTime(now.year + 1, 1, 1).subtract(const Duration(milliseconds: 1)),
        );
    }
  }

  Future<void> setPeriod(ReportPeriod period) async {
    _period = period;
    final range = dateRange;
    await loadSummary(range.start, range.end);
  }

  Future<void> loadSummary(DateTime from, DateTime to) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _summary = await _reportRepository.getSummary(
        from: from,
        to: to,
      );
      _dailyItems = await _reportRepository.getDailyItemSales(from);
      _recentLogs = await _auditLogRepository.getRecentAuditLogs(limit: 50);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
