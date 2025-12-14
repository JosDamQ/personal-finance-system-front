import '../../../core/enums/app_enums.dart';
import '../../models/expense_model.dart';

abstract class IExpenseRepository {
  // Basic CRUD operations
  Future<ExpenseModel> create(ExpenseModel expense);
  Future<ExpenseModel> update(String id, ExpenseModel expense);
  Future<void> delete(String id);
  Future<ExpenseModel?> findById(String id);
  Future<List<ExpenseModel>> findByUser(String userId);
  
  // Filtering operations
  Future<List<ExpenseModel>> findByCategory(String categoryId);
  Future<List<ExpenseModel>> findByCreditCard(String creditCardId);
  Future<List<ExpenseModel>> findByDateRange(DateTime startDate, DateTime endDate);
  Future<List<ExpenseModel>> findByBudgetPeriod(String budgetPeriodId);
  
  // Sync operations
  Future<List<ExpenseModel>> findPendingSync();
  Future<void> markAsSynced(String id);
  Future<void> markAsConflict(String id);
  Future<void> updateSyncStatus(String id, SyncStatus status);
  
  // Aggregation operations
  Future<double> getTotalByCategory(String categoryId);
  Future<double> getTotalByCreditCard(String creditCardId);
  Future<double> getTotalByDateRange(DateTime startDate, DateTime endDate);
  Future<Map<String, double>> getTotalsByCategory(String userId, DateTime startDate, DateTime endDate);
}