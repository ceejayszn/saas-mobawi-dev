import 'i_report_repository.dart';

class ApiReportRepository implements IReportRepository {
  @override
  Future<ReportSummary> getSummary({required DateTime from, required DateTime to}) {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<List<DailySaleItem>> getDailyItemSales(DateTime date) {
    throw UnimplementedError('API implementation pending');
  }
}
