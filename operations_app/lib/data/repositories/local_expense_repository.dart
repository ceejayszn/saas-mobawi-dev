import '../db/database_helper.dart';
import '../models/expense.dart';
import '../services/sync_service.dart';
import 'i_expense_repository.dart';

class LocalExpenseRepository implements IExpenseRepository {
  @override
  Future<String> insertExpense(Expense expense) async {
    final id = await DatabaseHelper.instance.insertExpense(expense);
    
    // Auto-enqueue expense creation for backend sync
    await SyncService.instance.enqueue('/api/expenses', 'POST', {
      ...expense.toMap(),
      'id': id,
    });
    
    return id;
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
