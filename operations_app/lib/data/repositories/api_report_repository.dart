import '../models/sale.dart';
import '../models/expense.dart';
import 'i_report_repository.dart';

class ApiReportRepository implements IReportRepository {
  @override
  Future<List<Sale>> getOrdersBetween(DateTime start, DateTime end) {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<List<Sale>> getSalesBetween(DateTime start, DateTime end) {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<List<Expense>> getExpensesBetween(DateTime start, DateTime end) {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<List<Map<String, dynamic>>> getSalesSummaryBetween(DateTime start, DateTime end) {
    throw UnimplementedError('API implementation pending');
  }
}
