import 'package:flutter/material.dart';
import '../../data/models/expense.dart';
import '../../data/models/sale.dart';
import '../../data/repositories/i_report_repository.dart';

class ReportProvider with ChangeNotifier {
  final IReportRepository _repository;

  double _amountSales = 0;
  double _amountExpenses = 0;
  int _orderCount = 0;
  double _mpesaIncome = 0;
  double _cashOnHand = 0;
  double _eatInRevenue = 0;
  double _deliveryRevenue = 0;
  List<Map<String, dynamic>> _salesSummary = [];
  List<Expense> _expenses = [];

  double get amountSales => _amountSales;
  double get amountExpenses => _amountExpenses;
  double get netProfit => _amountSales - _amountExpenses;
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
    final sales = await _repository.getOrdersBetween(range.start, range.end);
    final outsideOrders = await _repository.getSalesBetween(range.start, range.end);
    _expenses = await _repository.getExpensesBetween(range.start, range.end);
    _salesSummary = await _repository.getSalesSummaryBetween(range.start, range.end);

    _applyMetrics(
      sales: sales,
      outsideOrders: outsideOrders,
      expenses: _expenses,
      salesSummary: _salesSummary,
    );

    if (notify) {
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> get topItems {
    final amountQuantity = salesSummary.fold<int>(
      0,
      (sum, row) => sum + ((row['quantity'] ?? 0) as num).toInt(),
    );

    return salesSummary.take(5).map((row) {
      final quantity = ((row['quantity'] ?? 0) as num).toInt();
      final percent = amountQuantity == 0 ? 0.0 : quantity / amountQuantity;
      return {
        ...row,
        'percent': percent,
      };
    }).toList();
  }

  void _applyMetrics({
    required List<Sale> sales,
    required List<Sale> outsideOrders,
    required List<Expense> expenses,
    required List<Map<String, dynamic>> salesSummary,
  }) {
    final paidSales = outsideOrders.where((sale) => sale.status.toLowerCase() == 'paid').toList();
    final combinedSales = [
      ...sales.map((sale) => sale.amount),
      ...paidSales.map((sale) => sale.amount),
    ];

    _amountSales = combinedSales.fold(0.0, (sum, amount) => sum + amount);
    _amountExpenses = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    _orderCount = sales.length + paidSales.length;
    _deliveryRevenue = paidSales.fold(0.0, (sum, sale) => sum + sale.amount);
    _eatInRevenue = _amountSales - _deliveryRevenue;
    _mpesaIncome = [
      ...sales.where((sale) => sale.paymentMethod.toLowerCase() == 'm-pesa').map((sale) => sale.amount),
      ...paidSales.where((sale) => sale.paymentMethod.toLowerCase() == 'm-pesa').map((sale) => sale.amount),
    ].fold(0.0, (sum, amount) => sum + amount);
    _cashOnHand = sales
        .where((sale) => sale.paymentMethod.toLowerCase() == 'cash')
        .fold(0.0, (sum, sale) => sum + sale.amount);
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
