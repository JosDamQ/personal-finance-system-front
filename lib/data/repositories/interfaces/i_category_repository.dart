import '../../../core/enums/app_enums.dart';
import '../../models/category_model.dart';

abstract class ICategoryRepository {
  // Basic CRUD operations
  Future<CategoryModel> create(CategoryModel category);
  Future<CategoryModel> update(String id, CategoryModel category);
  Future<void> delete(String id);
  Future<CategoryModel?> findById(String id);
  Future<List<CategoryModel>> findByUser(String userId);

  // Specific queries
  Future<CategoryModel?> findDefaultCategory(String userId);
  Future<List<CategoryModel>> findNonDefaultByUser(String userId);
  Future<CategoryModel?> findByName(String userId, String name);

  // Sync operations
  Future<List<CategoryModel>> findPendingSync();
  Future<void> markAsSynced(String id);
  Future<void> markAsConflict(String id);
  Future<void> updateSyncStatus(String id, SyncStatus status);
}
