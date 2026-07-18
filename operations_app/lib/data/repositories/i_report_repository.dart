import '../models/sale.dart';
import '../models/expense.dart';

abstract class IReportRepository {
  Future<List<Sale>> getOrdersBetween(DateTime start, DateTime end);
  Future<List<Sale>> getSalesBetween(DateTime start, DateTime end);
  Future<List<Expense>> getExpensesBetween(DateTime start, DateTime end);
  Future<List<Map<String, dynamic>>> getSalesSummaryBetween(DateTime start, DateTime end);
}
