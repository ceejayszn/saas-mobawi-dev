import '../db/database_helper.dart';
import '../models/order.dart';
import '../models/outside_order.dart';
import '../models/expense.dart';
import 'i_report_repository.dart';

class LocalReportRepository implements IReportRepository {
  @override
  Future<List<Order>> getOrdersBetween(DateTime start, DateTime end) async {
    return await DatabaseHelper.instance.getOrdersBetween(start, end);
  }

  @override
  Future<List<OutsideOrder>> getOutsideOrdersBetween(DateTime start, DateTime end) async {
    return await DatabaseHelper.instance.getOutsideOrdersBetween(start, end);
  }

  @override
  Future<List<Expense>> getExpensesBetween(DateTime start, DateTime end) async {
    return await DatabaseHelper.instance.getExpensesBetween(start, end);
  }

  @override
  Future<List<Map<String, dynamic>>> getSalesSummaryBetween(DateTime start, DateTime end) async {
    return await DatabaseHelper.instance.getSalesSummaryBetween(start, end);
  }
}
