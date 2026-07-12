import 'package:flutter/material.dart';
import '../../data/db/database_helper.dart';
import '../../data/models/expense.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/i_expense_repository.dart';

class ExpenseProvider with ChangeNotifier {
  final IExpenseRepository _repository;

  List<Expense> _dailyExpenses = [];
  final List<String> _accounts = ['General', 'Water Supplier', 'Gas Supplier', 'Market Supplies', 'Cleaning', 'Electricity'];

  List<Expense> get dailyExpenses => _dailyExpenses;
  List<String> get accounts => _accounts;

  ExpenseProvider(this._repository);

  Future<void> loadDailyExpenses() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _dailyExpenses = await _repository.getDailyExpenses(today);
    
    // Load any custom accounts from saved expenses
    for (final exp in _dailyExpenses) {
      if (!_accounts.contains(exp.accountName)) {
        _accounts.add(exp.accountName);
      }
    }
    notifyListeners();
  }

  Future<void> addAccount(String name) async {
    final cleanName = name.trim();
    if (cleanName.isNotEmpty && !_accounts.contains(cleanName)) {
      _accounts.add(cleanName);
      notifyListeners();
    }
  }

  Future<void> addExpense(String title, double amount, {String accountName = 'General', String status = 'Settled'}) async {
    await _repository.insertExpense(Expense(
      title: title,
      amount: amount,
      date: DateTime.now(),
      accountName: accountName,
      status: status,
    ));
    await loadDailyExpenses();
  }

  Future<void> updateExpenseStatus(int expenseId, String status) async {
    final db = await DatabaseHelper.instance.database;
    await db.update('expenses', {'status': status}, where: 'id = ?', whereArgs: [expenseId]);
    await loadDailyExpenses();
  }
}
