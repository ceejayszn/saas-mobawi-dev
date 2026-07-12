// Local (mock/stub) implementation of ReportRepository
// Returns empty/zero values until backend is connected.
// All UI code references the abstract ReportRepository interface.

import 'i_report_repository.dart';

class LocalReportRepository implements IReportRepository {
  LocalReportRepository._();
  static final instance = LocalReportRepository._();

  @override
  Future<ReportSummary> getSummary({
    required DateTime from,
    required DateTime to,
  }) async {
    // TODO: Replace with REST API call to GET /api/reports/summary
    // Query param: ?from=<ISO>&to=<ISO>
    return const ReportSummary();
  }

  @override
  Future<List<DailySaleItem>> getDailyItemSales(DateTime date) async {
    // TODO: Replace with REST API call to GET /api/reports/daily-items
    // Query param: ?date=<ISO-date>
    return [];
  }

}
