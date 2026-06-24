import 'package:flutter/material.dart';
import '../../data/db/database_helper.dart';
import 'package:intl/intl.dart';

class ReportProvider with ChangeNotifier {
  double _totalSales = 0;
  double _totalExpenses = 0;
  int _orderCount = 0;

  double get totalSales => _totalSales;
  double get totalExpenses => _totalExpenses;
  double get netProfit => _totalSales - _totalExpenses;
  int get orderCount => _orderCount;

  Future<void> refreshReports() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    final orders = await DatabaseHelper.instance.getDailyOrders(today);
    final expenses = await DatabaseHelper.instance.getDailyExpenses(today);

    _totalSales = orders.fold(0.0, (sum, o) => sum + o.total);
    _totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);
    _orderCount = orders.length;

    notifyListeners();
  }
}
