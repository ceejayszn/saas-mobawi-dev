import 'package:flutter/material.dart';
import '../../data/db/database_helper.dart';
import '../../data/models/expense.dart';
import 'package:intl/intl.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _dailyExpenses = [];

  List<Expense> get dailyExpenses => _dailyExpenses;

  Future<void> loadDailyExpenses() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _dailyExpenses = await DatabaseHelper.instance.getDailyExpenses(today);
    notifyListeners();
  }

  Future<void> addExpense(String title, double amount) async {
    await DatabaseHelper.instance.insertExpense(Expense(
      title: title,
      amount: amount,
      date: DateTime.now(),
    ));
    await loadDailyExpenses();
  }
}
