import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/enums/app_enums.dart';
import '../../data/services/offline_sync_service.dart';
import '../../data/services/connectivity_service.dart';

/// Provider to manage sync state across the app
class SyncProvider extends ChangeNotifier {
  final OfflineSyncService _syncService = OfflineSyncService();
  final ConnectivityService _connectivityService = ConnectivityService();

  StreamSubscription<SyncStatusUpdate>? _syncStatusSubscription;
  StreamSubscription<bool>? _connectivitySubscription;

  bool _isOnline = false;
  bool _isSyncing = false;
  SyncStatus _syncStatus = SyncStatus.synced;
  String _syncMessage = '';
  int _pendingCount = 0;
  int _failedCount = 0;
  int _conflictCount = 0;
  String? _userId;

  // Getters
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  SyncStatus get syncStatus => _syncStatus;
  String get syncMessage => _syncMessage;
  int get pendingCount => _pendingCount;
  int get failedCount => _failedCount;
  int get conflictCount => _conflictCount;
  bool get hasIssues => _failedCount > 0 || _conflictCount > 0;
  bool get hasPendingItems => _pendingCount > 0;

  /// Initialize sync provider with user ID
  Future<void> initialize(String userId) async {
    _userId = userId;

    // Initialize services
    await _connectivityService.initialize();
    await _syncService.initialize(userId);

    // Set initial states
    _isOnline = _connectivityService.isOnline;
    _isSyncing = _syncService.isSyncing;

    // Load initial sync info
    await _loadSyncInfo();

    // Listen to connectivity changes
    _connectivitySubscription = _connectivityService.connectivityStream.listen(
      _onConnectivityChanged,
    );

    // Listen to sync status updates
    _syncStatusSubscription = _syncService.syncStatusStream.listen(
      _onSyncStatusUpdate,
    );

    notifyListeners();
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(bool isOnline) {
    _isOnline = isOnline;
    notifyListeners();

    // Trigger sync when coming online
    if (isOnline && _userId != null && _pendingCount > 0) {
      _syncService.syncIfOnline(_userId!);
    }
  }

  /// Handle sync status updates
  void _onSyncStatusUpdate(SyncStatusUpdate update) {
    _syncStatus = update.status;
    _syncMessage = update.message;
    _isSyncing = _syncService.isSyncing;

    if (update.pendingCount != null) {
      _pendingCount = update.pendingCount!;
    }

    if (update.failedCount != null) {
      _failedCount = update.failedCount!;
    }

    if (update.conflictCount != null) {
      _conflictCount = update.conflictCount!;
    }

    notifyListeners();
  }

  /// Load current sync information
  Future<void> _loadSyncInfo() async {
    if (_userId == null) return;

    final syncInfo = await _syncService.getSyncInfo(_userId!);
    _isOnline = syncInfo.isOnline;
    _isSyncing = syncInfo.isSyncing;
    _pendingCount = syncInfo.pendingCount;
    _failedCount = syncInfo.failedCount;

    // Determine sync status
    if (_isSyncing) {
      _syncStatus = SyncStatus.pending;
      _syncMessage = 'Syncing...';
    } else if (_failedCount > 0) {
      _syncStatus = SyncStatus.error;
      _syncMessage = 'Sync failed ($_failedCount items)';
    } else if (_pendingCount > 0) {
      _syncStatus = SyncStatus.pending;
      _syncMessage = 'Pending sync ($_pendingCount items)';
    } else {
      _syncStatus = SyncStatus.synced;
      _syncMessage = 'All data synced';
    }

    notifyListeners();
  }

  /// Queue an operation for sync
  Future<void> queueOperation({
    required SyncOperation operation,
    required EntityType entityType,
    required String entityId,
    required Map<String, dynamic> data,
  }) async {
    if (_userId == null) return;

    await _syncService.queueOperation(
      userId: _userId!,
      operation: operation,
      entityType: entityType,
      entityId: entityId,
      data: data,
    );
  }

  /// Force sync now
  Future<SyncResult> forceSync() async {
    if (_userId == null) {
      return SyncResult(
        success: false,
        message: 'No user logged in',
        syncedCount: 0,
        failedCount: 0,
        conflicts: [],
      );
    }

    return await _syncService.forceSync(_userId!);
  }

  /// Retry failed items
  Future<void> retryFailedItems() async {
    if (_userId == null) return;

    await _syncService.retryFailedItems(_userId!);
  }

  /// Clear all sync data
  Future<void> clearSyncData() async {
    if (_userId == null) return;

    await _syncService.clearSyncData(_userId!);
    await _loadSyncInfo();
  }

  /// Resolve a conflict
  Future<void> resolveConflict({
    required String conflictId,
    required ConflictResolution resolution,
    Map<String, dynamic>? mergedData,
  }) async {
    await _syncService.resolveConflict(
      conflictId: conflictId,
      resolution: resolution,
      mergedData: mergedData,
    );
  }

  /// Get sync service for direct access
  OfflineSyncService get syncService => _syncService;

  /// Get connectivity service for direct access
  ConnectivityService get connectivityService => _connectivityService;

  @override
  void dispose() {
    _syncStatusSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _syncService.dispose();
    _connectivityService.dispose();
    super.dispose();
  }
}
