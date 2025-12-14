import '../../../core/enums/app_enums.dart';
import '../../models/sync_queue_model.dart';

abstract class ISyncQueueRepository {
  // Basic CRUD operations
  Future<SyncQueueModel> create(SyncQueueModel syncItem);
  Future<SyncQueueModel> update(String id, SyncQueueModel syncItem);
  Future<void> delete(String id);
  Future<SyncQueueModel?> findById(String id);
  Future<List<SyncQueueModel>> findByUser(String userId);

  // Sync operations
  Future<List<SyncQueueModel>> findPendingItems(String userId);
  Future<List<SyncQueueModel>> findFailedItems(String userId);
  Future<void> markAsProcessing(String id);
  Future<void> markAsCompleted(String id);
  Future<void> markAsFailed(String id, String errorMessage);
  Future<void> incrementRetryCount(String id);
  Future<void> clearCompletedItems(String userId);
  Future<void> clearAllItems(String userId);
}
