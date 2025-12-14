import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';
import '../models/sync_queue_model.dart';
import '../../core/enums/app_enums.dart';
import 'database_service.dart';
import 'api_service.dart';

/// Service to handle offline synchronization
/// Manages the sync queue and handles data synchronization when connectivity is restored
class OfflineSyncService {
  static final OfflineSyncService _instance = OfflineSyncService._internal();

  final DatabaseService _databaseService = DatabaseService();
  final ApiService _apiService = ApiService();
  final Connectivity _connectivity = Connectivity();
  final Uuid _uuid = const Uuid();

  bool _isSyncing = false;

  OfflineSyncService._internal();

  factory OfflineSyncService() => _instance;

  /// Queue an operation for synchronization
  Future<void> queueOperation({
    required String userId,
    required SyncOperation operation,
    required EntityType entityType,
    required String entityId,
    required Map<String, dynamic> data,
  }) async {
    final syncItem = SyncQueueModel(
      id: _uuid.v4(),
      userId: userId,
      operation: operation,
      entityType: entityType,
      entityId: entityId,
      data: data,
      retryCount: 0,
      maxRetries: 3,
      status: SyncQueueStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _databaseService.syncQueue.create(syncItem);
  }

  /// Check connectivity and sync if online
  Future<void> syncIfOnline(String userId) async {
    if (_isSyncing) return;

    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return; // No internet connection
    }

    await _performSync(userId);
  }

  /// Force sync regardless of connectivity status
  Future<SyncResult> forceSync(String userId) async {
    return await _performSync(userId);
  }

  /// Perform the actual synchronization
  Future<SyncResult> _performSync(String userId) async {
    if (_isSyncing) {
      return SyncResult(
        success: false,
        message: 'Sync already in progress',
        syncedCount: 0,
        failedCount: 0,
      );
    }

    _isSyncing = true;
    int syncedCount = 0;
    int failedCount = 0;

    try {
      final pendingItems = await _databaseService.syncQueue.findPendingItems(
        userId,
      );

      for (final item in pendingItems) {
        try {
          await _databaseService.syncQueue.markAsProcessing(item.id);

          final success = await _syncItem(item);

          if (success) {
            await _databaseService.syncQueue.markAsCompleted(item.id);
            syncedCount++;
          } else {
            await _databaseService.syncQueue.incrementRetryCount(item.id);
            if (item.retryCount >= item.maxRetries) {
              await _databaseService.syncQueue.markAsFailed(
                item.id,
                'Max retries exceeded',
              );
            }
            failedCount++;
          }
        } catch (e) {
          await _databaseService.syncQueue.markAsFailed(item.id, e.toString());
          failedCount++;
        }
      }

      // Clean up completed items
      await _databaseService.syncQueue.clearCompletedItems(userId);

      return SyncResult(
        success: failedCount == 0,
        message: failedCount == 0
            ? 'Sync completed successfully'
            : 'Sync completed with $failedCount failures',
        syncedCount: syncedCount,
        failedCount: failedCount,
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync a single item
  Future<bool> _syncItem(SyncQueueModel item) async {
    try {
      switch (item.entityType) {
        case EntityType.expense:
          return await _syncExpense(item);
        case EntityType.budget:
          return await _syncBudget(item);
        case EntityType.creditCard:
          return await _syncCreditCard(item);
        case EntityType.category:
          return await _syncCategory(item);
        case EntityType.budgetPeriod:
          return await _syncBudgetPeriod(item);
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> _syncExpense(SyncQueueModel item) async {
    switch (item.operation) {
      case SyncOperation.create:
        final response = await _apiService.post(
          '/expenses',
          body: jsonEncode(item.data),
        );
        return response.statusCode == 201;
      case SyncOperation.update:
        final response = await _apiService.put(
          '/expenses/${item.entityId}',
          body: jsonEncode(item.data),
        );
        return response.statusCode == 200;
      case SyncOperation.delete:
        final response = await _apiService.delete('/expenses/${item.entityId}');
        return response.statusCode == 200;
    }
  }

  Future<bool> _syncBudget(SyncQueueModel item) async {
    switch (item.operation) {
      case SyncOperation.create:
        final response = await _apiService.post(
          '/budgets',
          body: jsonEncode(item.data),
        );
        return response.statusCode == 201;
      case SyncOperation.update:
        final response = await _apiService.put(
          '/budgets/${item.entityId}',
          body: jsonEncode(item.data),
        );
        return response.statusCode == 200;
      case SyncOperation.delete:
        final response = await _apiService.delete('/budgets/${item.entityId}');
        return response.statusCode == 200;
    }
  }

  Future<bool> _syncCreditCard(SyncQueueModel item) async {
    switch (item.operation) {
      case SyncOperation.create:
        final response = await _apiService.post(
          '/credit-cards',
          body: jsonEncode(item.data),
        );
        return response.statusCode == 201;
      case SyncOperation.update:
        final response = await _apiService.put(
          '/credit-cards/${item.entityId}',
          body: jsonEncode(item.data),
        );
        return response.statusCode == 200;
      case SyncOperation.delete:
        final response = await _apiService.delete(
          '/credit-cards/${item.entityId}',
        );
        return response.statusCode == 200;
    }
  }

  Future<bool> _syncCategory(SyncQueueModel item) async {
    switch (item.operation) {
      case SyncOperation.create:
        final response = await _apiService.post(
          '/categories',
          body: jsonEncode(item.data),
        );
        return response.statusCode == 201;
      case SyncOperation.update:
        final response = await _apiService.put(
          '/categories/${item.entityId}',
          body: jsonEncode(item.data),
        );
        return response.statusCode == 200;
      case SyncOperation.delete:
        final response = await _apiService.delete(
          '/categories/${item.entityId}',
        );
        return response.statusCode == 200;
    }
  }

  Future<bool> _syncBudgetPeriod(SyncQueueModel item) async {
    // Budget periods are typically synced as part of budget sync
    return true;
  }

  /// Get sync status for a user
  Future<SyncStatus> getSyncStatus(String userId) async {
    final pendingCount = await _databaseService.getPendingSyncCount(userId);
    final failedItems = await _databaseService.syncQueue.findFailedItems(
      userId,
    );

    if (_isSyncing) {
      return SyncStatus.pending;
    } else if (failedItems.isNotEmpty) {
      return SyncStatus.error;
    } else if (pendingCount > 0) {
      return SyncStatus.pending;
    } else {
      return SyncStatus.synced;
    }
  }

  /// Clear all sync data for a user
  Future<void> clearSyncData(String userId) async {
    await _databaseService.clearUserSyncQueue(userId);
  }
}

/// Result of a sync operation
class SyncResult {
  final bool success;
  final String message;
  final int syncedCount;
  final int failedCount;

  SyncResult({
    required this.success,
    required this.message,
    required this.syncedCount,
    required this.failedCount,
  });
}
