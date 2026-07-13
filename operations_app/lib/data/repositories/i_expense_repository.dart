import '../models/expense.dart';

abstract class IExpenseRepository {
  Future<String> insertExpense(Expense expense);
  Future<List<Expense>> getDailyExpenses(String date);
  Future<List<Expense>> getExpensesBetween(DateTime start, DateTime end);
}
