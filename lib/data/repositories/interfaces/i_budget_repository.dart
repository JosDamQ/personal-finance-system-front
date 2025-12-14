import '../../../core/enums/app_enums.dart';
import '../../models/budget_model.dart';

abstract class IBudgetRepository {
  // Basic CRUD operations
  Future<BudgetModel> create(BudgetModel budget);
  Future<BudgetModel> update(String id, BudgetModel budget);
  Future<void> delete(String id);
  Future<BudgetModel?> findById(String id);
  Future<List<BudgetModel>> findByUser(String userId);

  // Specific queries
  Future<BudgetModel?> findByUserAndPeriod(String userId, int month, int year);
  Future<List<BudgetModel>> findByYear(String userId, int year);

  // Sync operations
  Future<List<BudgetModel>> findPendingSync();
  Future<void> markAsSynced(String id);
  Future<void> markAsConflict(String id);
  Future<void> updateSyncStatus(String id, SyncStatus status);
}
