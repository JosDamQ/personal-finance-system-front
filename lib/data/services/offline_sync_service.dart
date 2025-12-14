import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';
import '../models/sync_queue_model.dart';
import '../../core/enums/app_enums.dart';
import '../../core/constants/app_constants.dart';
import 'database_service.dart';
import 'api_service.dart';

/// Service to handle offline synchronization
class OfflineSyncService {
  static final OfflineSyncService _instance = OfflineSyncService._internal();

  final DatabaseService _databaseService = DatabaseService();
  final ApiService _apiService = ApiService();
  final Connectivity _connectivity = Connectivity();
  final Uuid _uuid = const Uuid();

  bool _isSyncing = false;
  bool _isOnline = false;
  Timer? _syncTimer;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  final StreamController<SyncStatusUpdate> _syncStatusController =
      StreamController<SyncStatusUpdate>.broadcast();
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  OfflineSyncService._internal();

  factory OfflineSyncService() => _instance;

  Stream<SyncStatusUpdate> get syncStatusStream => _syncStatusController.stream;
  Stream<bool> get connectivityStream => _connectivityController.stream;

  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;

  Future<void> initialize(String userId) async {
    await _checkInitialConnectivity();
    _startConnectivityMonitoring();
    _startPeriodicSync(userId);
  }

  void dispose() {
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();
    _syncStatusController.close();
    _connectivityController.close();
  }

  Future<void> _checkInitialConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    _updateConnectivityStatus(connectivityResult);
  }

  void _startConnectivityMonitoring() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectivityStatus,
    );
  }

  void _updateConnectivityStatus(ConnectivityResult result) {
    final wasOnline = _isOnline;
    _isOnline = result != ConnectivityResult.none;

    _connectivityController.add(_isOnline);

    if (!wasOnline && _isOnline) {
      _syncStatusController.add(
        SyncStatusUpdate(
          status: SyncStatus.pending,
          message: 'Connection restored, starting sync...',
        ),
      );
    }
  }

  void _startPeriodicSync(String userId) {
    _syncTimer = Timer.periodic(AppConstants.syncInterval, (timer) {
      if (_isOnline && !_isSyncing) {
        syncIfOnline(userId);
      }
    });
  }

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
      maxRetries: AppConstants.maxRetryAttempts,
      status: SyncQueueStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _databaseService.syncQueue.create(syncItem);

    _syncStatusController.add(
      SyncStatusUpdate(
        status: SyncStatus.pending,
        message: 'Operation queued for sync',
        pendingCount: await _databaseService.getPendingSyncCount(userId),
      ),
    );

    if (_isOnline) {
      syncIfOnline(userId);
    }
  }

  Future<void> syncIfOnline(String userId) async {
    if (_isSyncing || !_isOnline) return;
    await _performSync(userId);
  }

  Future<SyncResult> forceSync(String userId) async {
    return await _performSync(userId);
  }

  Future<SyncResult> _performSync(String userId) async {
    if (_isSyncing) {
      return SyncResult(
        success: false,
        message: 'Sync already in progress',
        syncedCount: 0,
        failedCount: 0,
        conflicts: [],
      );
    }

    _isSyncing = true;
    int syncedCount = 0;
    int failedCount = 0;
    List<ConflictItem> conflicts = [];

    try {
      _syncStatusController.add(
        SyncStatusUpdate(
          status: SyncStatus.pending,
          message: 'Synchronizing...',
        ),
      );

      final pendingItems = await _databaseService.syncQueue.findPendingItems(
        userId,
      );

      if (pendingItems.isEmpty) {
        _syncStatusController.add(
          SyncStatusUpdate(
            status: SyncStatus.synced,
            message: 'All data synchronized',
          ),
        );
        return SyncResult(
          success: true,
          message: 'No pending items to sync',
          syncedCount: 0,
          failedCount: 0,
          conflicts: [],
        );
      }

      for (final item in pendingItems) {
        try {
          await _databaseService.syncQueue.markAsProcessing(item.id);
          final syncItemResult = await _syncItem(item);

          if (syncItemResult.success) {
            await _databaseService.syncQueue.markAsCompleted(item.id);
            syncedCount++;
          } else if (syncItemResult.isConflict) {
            conflicts.add(syncItemResult.conflict!);
            await _databaseService.syncQueue.markAsFailed(
              item.id,
              'Conflict detected',
            );
            failedCount++;
          } else {
            await _databaseService.syncQueue.incrementRetryCount(item.id);
            if (item.retryCount >= item.maxRetries) {
              await _databaseService.syncQueue.markAsFailed(
                item.id,
                syncItemResult.errorMessage ?? 'Max retries exceeded',
              );
            }
            failedCount++;
          }
        } catch (e) {
          await _databaseService.syncQueue.markAsFailed(item.id, e.toString());
          failedCount++;
        }
      }

      await _databaseService.syncQueue.clearCompletedItems(userId);

      final finalStatus = conflicts.isNotEmpty
          ? SyncStatus.conflict
          : (failedCount == 0 ? SyncStatus.synced : SyncStatus.error);

      _syncStatusController.add(
        SyncStatusUpdate(
          status: finalStatus,
          message: _getSyncMessage(syncedCount, failedCount, conflicts.length),
          syncedCount: syncedCount,
          failedCount: failedCount,
          conflictCount: conflicts.length,
        ),
      );

      return SyncResult(
        success: failedCount == 0 && conflicts.isEmpty,
        message: _getSyncMessage(syncedCount, failedCount, conflicts.length),
        syncedCount: syncedCount,
        failedCount: failedCount,
        conflicts: conflicts,
      );
    } finally {
      _isSyncing = false;
    }
  }

  String _getSyncMessage(int synced, int failed, int conflicts) {
    if (conflicts > 0) {
      return 'Sync completed with $conflicts conflicts requiring resolution';
    } else if (failed == 0) {
      return 'Sync completed successfully ($synced items)';
    } else {
      return 'Sync completed with $failed failures ($synced successful)';
    }
  }

  Future<SyncItemResult> _syncItem(SyncQueueModel item) async {
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
          return SyncItemResult.success();
      }
    } catch (e) {
      return SyncItemResult.error(e.toString());
    }
  }

  Future<SyncItemResult> _syncExpense(SyncQueueModel item) async {
    try {
      switch (item.operation) {
        case SyncOperation.create:
          final response = await _apiService.post(
            '/api/v1/expenses',
            body: jsonEncode(item.data),
          );
          return response.statusCode == 201
              ? SyncItemResult.success()
              : SyncItemResult.error('Failed to create expense');
        case SyncOperation.update:
          final response = await _apiService.put(
            '/api/v1/expenses/${item.entityId}',
            body: jsonEncode(item.data),
          );
          return response.statusCode == 200
              ? SyncItemResult.success()
              : SyncItemResult.error('Failed to update expense');
        case SyncOperation.delete:
          final response = await _apiService.delete(
            '/api/v1/expenses/${item.entityId}',
          );
          return (response.statusCode == 200 || response.statusCode == 404)
              ? SyncItemResult.success()
              : SyncItemResult.error('Failed to delete expense');
      }
    } catch (e) {
      return SyncItemResult.error(e.toString());
    }
  }

  Future<SyncItemResult> _syncBudget(SyncQueueModel item) async {
    try {
      switch (item.operation) {
        case SyncOperation.create:
          final response = await _apiService.post(
            '/api/v1/budgets',
            body: jsonEncode(item.data),
          );
          return response.statusCode == 201
              ? SyncItemResult.success()
              : SyncItemResult.error('Failed to create budget');
        case SyncOperation.update:
          final response = await _apiService.put(
            '/api/v1/budgets/${item.entityId}',
            body: jsonEncode(item.data),
          );
          return response.statusCode == 200
              ? SyncItemResult.success()
              : SyncItemResult.error('Failed to update budget');
        case SyncOperation.delete:
          final response = await _apiService.delete(
            '/api/v1/budgets/${item.entityId}',
          );
          return (response.statusCode == 200 || response.statusCode == 404)
              ? SyncItemResult.success()
              : SyncItemResult.error('Failed to delete budget');
      }
    } catch (e) {
      return SyncItemResult.error(e.toString());
    }
  }

  Future<SyncItemResult> _syncCreditCard(SyncQueueModel item) async {
    try {
      switch (item.operation) {
        case SyncOperation.create:
          final response = await _apiService.post(
            '/api/v1/credit-cards',
            body: jsonEncode(item.data),
          );
          return response.statusCode == 201
              ? SyncItemResult.success()
              : SyncItemResult.error('Failed to create credit card');
        case SyncOperation.update:
          final response = await _apiService.put(
            '/api/v1/credit-cards/${item.entityId}',
            body: jsonEncode(item.data),
          );
          return response.statusCode == 200
              ? SyncItemResult.success()
              : SyncItemResult.error('Failed to update credit card');
        case SyncOperation.delete:
          final response = await _apiService.delete(
            '/api/v1/credit-cards/${item.entityId}',
          );
          return (response.statusCode == 200 || response.statusCode == 404)
              ? SyncItemResult.success()
              : SyncItemResult.error('Failed to delete credit card');
      }
    } catch (e) {
      return SyncItemResult.error(e.toString());
    }
  }

  Future<SyncItemResult> _syncCategory(SyncQueueModel item) async {
    try {
      switch (item.operation) {
        case SyncOperation.create:
          final response = await _apiService.post(
            '/api/v1/categories',
            body: jsonEncode(item.data),
          );
          return response.statusCode == 201
              ? SyncItemResult.success()
              : SyncItemResult.error('Failed to create category');
        case SyncOperation.update:
          final response = await _apiService.put(
            '/api/v1/categories/${item.entityId}',
            body: jsonEncode(item.data),
          );
          return response.statusCode == 200
              ? SyncItemResult.success()
              : SyncItemResult.error('Failed to update category');
        case SyncOperation.delete:
          final response = await _apiService.delete(
            '/api/v1/categories/${item.entityId}',
          );
          return (response.statusCode == 200 || response.statusCode == 404)
              ? SyncItemResult.success()
              : SyncItemResult.error('Failed to delete category');
      }
    } catch (e) {
      return SyncItemResult.error(e.toString());
    }
  }

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

  Future<SyncInfo> getSyncInfo(String userId) async {
    final pendingItems = await _databaseService.syncQueue.findPendingItems(
      userId,
    );
    final failedItems = await _databaseService.syncQueue.findFailedItems(
      userId,
    );

    return SyncInfo(
      isOnline: _isOnline,
      isSyncing: _isSyncing,
      pendingCount: pendingItems.length,
      failedCount: failedItems.length,
      lastSyncAttempt: pendingItems.isNotEmpty || failedItems.isNotEmpty
          ? DateTime.now()
          : null,
    );
  }

  Future<void> resolveConflict({
    required String conflictId,
    required ConflictResolution resolution,
    Map<String, dynamic>? mergedData,
  }) async {
    final syncItem = await _databaseService.syncQueue.findById(conflictId);
    if (syncItem == null) return;

    Map<String, dynamic> finalData;

    switch (resolution) {
      case ConflictResolution.useLocal:
        finalData = syncItem.data;
        break;
      case ConflictResolution.useServer:
        finalData = mergedData ?? syncItem.data;
        break;
      case ConflictResolution.merge:
        finalData = mergedData ?? syncItem.data;
        break;
    }

    final updatedItem = syncItem.copyWith(
      data: finalData,
      status: SyncQueueStatus.pending,
      retryCount: 0,
      errorMessage: null,
    );

    await _databaseService.syncQueue.update(conflictId, updatedItem);
  }

  Future<void> clearSyncData(String userId) async {
    await _databaseService.clearUserSyncQueue(userId);
  }

  Future<void> retryFailedItems(String userId) async {
    final failedItems = await _databaseService.syncQueue.findFailedItems(
      userId,
    );

    for (final item in failedItems) {
      final updatedItem = item.copyWith(
        status: SyncQueueStatus.pending,
        retryCount: 0,
        errorMessage: null,
      );
      await _databaseService.syncQueue.update(item.id, updatedItem);
    }

    if (_isOnline) {
      await syncIfOnline(userId);
    }
  }
}

class SyncResult {
  final bool success;
  final String message;
  final int syncedCount;
  final int failedCount;
  final List<ConflictItem> conflicts;

  SyncResult({
    required this.success,
    required this.message,
    required this.syncedCount,
    required this.failedCount,
    required this.conflicts,
  });
}

class SyncItemResult {
  final bool success;
  final bool isConflict;
  final String? errorMessage;
  final ConflictItem? conflict;

  SyncItemResult._({
    required this.success,
    required this.isConflict,
    this.errorMessage,
    this.conflict,
  });

  factory SyncItemResult.success() =>
      SyncItemResult._(success: true, isConflict: false);
  factory SyncItemResult.error(String message) => SyncItemResult._(
    success: false,
    isConflict: false,
    errorMessage: message,
  );
  factory SyncItemResult.conflict(ConflictItem conflict) =>
      SyncItemResult._(success: false, isConflict: true, conflict: conflict);
}

class ConflictItem {
  final String id;
  final EntityType entityType;
  final String entityId;
  final SyncOperation operation;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> serverData;
  final String conflictReason;

  ConflictItem({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.localData,
    required this.serverData,
    required this.conflictReason,
  });
}

class SyncStatusUpdate {
  final SyncStatus status;
  final String message;
  final int? pendingCount;
  final int? syncedCount;
  final int? failedCount;
  final int? conflictCount;

  SyncStatusUpdate({
    required this.status,
    required this.message,
    this.pendingCount,
    this.syncedCount,
    this.failedCount,
    this.conflictCount,
  });
}

class SyncInfo {
  final bool isOnline;
  final bool isSyncing;
  final int pendingCount;
  final int failedCount;
  final DateTime? lastSyncAttempt;

  SyncInfo({
    required this.isOnline,
    required this.isSyncing,
    required this.pendingCount,
    required this.failedCount,
    this.lastSyncAttempt,
  });
}

enum ConflictResolution { useLocal, useServer, merge }
