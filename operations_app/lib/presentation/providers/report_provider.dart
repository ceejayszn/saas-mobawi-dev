import 'package:flutter/material.dart';
import '../../data/models/expense.dart';
import '../../data/models/order.dart';
import '../../data/models/outside_order.dart';
import '../../data/repositories/i_report_repository.dart';

class ReportProvider with ChangeNotifier {
  final IReportRepository _repository;

  double _totalSales = 0;
  double _totalExpenses = 0;
  int _orderCount = 0;
  double _mpesaIncome = 0;
  double _cashOnHand = 0;
  double _eatInRevenue = 0;
  double _deliveryRevenue = 0;
  List<Map<String, dynamic>> _salesSummary = [];
  List<Expense> _expenses = [];

  double get totalSales => _totalSales;
  double get totalExpenses => _totalExpenses;
  double get netProfit => _totalSales - _totalExpenses;
  int get orderCount => _orderCount;
  double get mpesaIncome => _mpesaIncome;
  double get cashOnHand => _cashOnHand;
  double get eatInRevenue => _eatInRevenue;
  double get deliveryRevenue => _deliveryRevenue;
  List<Map<String, dynamic>> get salesSummary => _salesSummary;
  List<Expense> get expenses => _expenses;

  ReportProvider(this._repository);

  Future<void> refreshReports() async {
    final now = DateTime.now();
    await loadRange(_rangeForTab(0, now), notify: true);
  }

  Future<void> loadForTab(int selectedTab) async {
    await loadRange(_rangeForTab(selectedTab, DateTime.now()), notify: true);
  }

  Future<void> loadRange(DateTimeRange range, {bool notify = false}) async {
    final orders = await _repository.getOrdersBetween(range.start, range.end);
    final outsideOrders = await _repository.getOutsideOrdersBetween(range.start, range.end);
    _expenses = await _repository.getExpensesBetween(range.start, range.end);
    _salesSummary = await _repository.getSalesSummaryBetween(range.start, range.end);

    _applyMetrics(
      orders: orders,
      outsideOrders: outsideOrders,
      expenses: _expenses,
      salesSummary: _salesSummary,
    );

    if (notify) {
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> get topItems {
    final totalQuantity = salesSummary.fold<int>(
      0,
      (sum, row) => sum + ((row['quantity'] ?? 0) as num).toInt(),
    );

    return salesSummary.take(5).map((row) {
      final quantity = ((row['quantity'] ?? 0) as num).toInt();
      final percent = totalQuantity == 0 ? 0.0 : quantity / totalQuantity;
      return {
        ...row,
        'percent': percent,
      };
    }).toList();
  }

  void _applyMetrics({
    required List<Order> orders,
    required List<OutsideOrder> outsideOrders,
    required List<Expense> expenses,
    required List<Map<String, dynamic>> salesSummary,
  }) {
    final paidOutsideOrders = outsideOrders.where((order) => order.status.toLowerCase() == 'paid').toList();
    final combinedSales = [
      ...orders.map((order) => order.total),
      ...paidOutsideOrders.map((order) => order.total),
    ];

    _totalSales = combinedSales.fold(0.0, (sum, total) => sum + total);
    _totalExpenses = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    _orderCount = orders.length + paidOutsideOrders.length;
    _deliveryRevenue = paidOutsideOrders.fold(0.0, (sum, order) => sum + order.total);
    _eatInRevenue = _totalSales - _deliveryRevenue;
    _mpesaIncome = [
      ...orders.where((order) => order.paymentMethod.toLowerCase() == 'm-pesa').map((order) => order.total),
      ...paidOutsideOrders.where((order) => order.paymentMethod.toLowerCase() == 'm-pesa').map((order) => order.total),
    ].fold(0.0, (sum, total) => sum + total);
    _cashOnHand = orders
        .where((order) => order.paymentMethod.toLowerCase() == 'cash')
        .fold(0.0, (sum, order) => sum + order.total);
    _salesSummary = salesSummary;
    _expenses = expenses;
  }

  DateTimeRange _rangeForTab(int selectedTab, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    switch (selectedTab) {
      case 1:
        final start = today.subtract(Duration(days: today.weekday - 1));
        final end = start.add(const Duration(days: 7)).subtract(const Duration(milliseconds: 1));
        return DateTimeRange(start: start, end: end);
      case 2:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 1).subtract(const Duration(milliseconds: 1));
        return DateTimeRange(start: start, end: end);
      case 0:
      default:
        return DateTimeRange(
          start: today,
          end: today.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1)),
        );
    }
  }
}
