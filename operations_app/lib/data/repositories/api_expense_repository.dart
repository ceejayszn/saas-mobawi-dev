import '../models/expense.dart';
import 'i_expense_repository.dart';

class ApiExpenseRepository implements IExpenseRepository {
  @override
  Future<int> insertExpense(Expense expense) {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<List<Expense>> getDailyExpenses(String date) {
    throw UnimplementedError('API implementation pending');
  }

  @override
  Future<List<Expense>> getExpensesBetween(DateTime start, DateTime end) {
    throw UnimplementedError('API implementation pending');
  }
}
