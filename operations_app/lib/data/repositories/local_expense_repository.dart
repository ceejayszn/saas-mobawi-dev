import '../db/database_helper.dart';
import '../models/expense.dart';
import 'i_expense_repository.dart';

class LocalExpenseRepository implements IExpenseRepository {
  @override
  Future<int> insertExpense(Expense expense) async {
    return await DatabaseHelper.instance.insertExpense(expense);
  }

  @override
  Future<List<Expense>> getDailyExpenses(String date) async {
    return await DatabaseHelper.instance.getDailyExpenses(date);
  }

  @override
  Future<List<Expense>> getExpensesBetween(DateTime start, DateTime end) async {
    return await DatabaseHelper.instance.getExpensesBetween(start, end);
  }
}
