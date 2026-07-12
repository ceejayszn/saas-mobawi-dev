import '../models/order.dart';
import '../models/outside_order.dart';
import '../models/expense.dart';

abstract class IReportRepository {
  Future<List<Order>> getOrdersBetween(DateTime start, DateTime end);
  Future<List<OutsideOrder>> getOutsideOrdersBetween(DateTime start, DateTime end);
  Future<List<Expense>> getExpensesBetween(DateTime start, DateTime end);
  Future<List<Map<String, dynamic>>> getSalesSummaryBetween(DateTime start, DateTime end);
}
