import 'package:flutter_test/flutter_test.dart';
import 'package:finance_app/data/services/offline_sync_service.dart';
import 'package:finance_app/data/services/connectivity_service.dart';
import 'package:finance_app/core/enums/app_enums.dart';

void main() {
  group('Sync Service Tests', () {
    test('OfflineSyncService should initialize correctly', () {
      final syncService = OfflineSyncService();

      expect(syncService.isOnline, false);
      expect(syncService.isSyncing, false);
    });

    test('ConnectivityService should initialize correctly', () {
      final connectivityService = ConnectivityService();

      expect(connectivityService.isOnline, false);
    });

    test('SyncResult should be created correctly', () {
      final result = SyncResult(
        success: true,
        message: 'Test sync completed',
        syncedCount: 5,
        failedCount: 0,
        conflicts: [],
      );

      expect(result.success, true);
      expect(result.message, 'Test sync completed');
      expect(result.syncedCount, 5);
      expect(result.failedCount, 0);
      expect(result.conflicts, isEmpty);
    });

    test('SyncItemResult should handle success correctly', () {
      final result = SyncItemResult.success();

      expect(result.success, true);
      expect(result.isConflict, false);
      expect(result.errorMessage, null);
      expect(result.conflict, null);
    });

    test('SyncItemResult should handle errors correctly', () {
      final result = SyncItemResult.error('Test error');

      expect(result.success, false);
      expect(result.isConflict, false);
      expect(result.errorMessage, 'Test error');
      expect(result.conflict, null);
    });

    test('ConflictItem should be created correctly', () {
      final conflict = ConflictItem(
        id: 'test-id',
        entityType: EntityType.expense,
        entityId: 'expense-1',
        operation: SyncOperation.update,
        localData: {'amount': 100},
        serverData: {'amount': 150},
        conflictReason: 'Data mismatch',
      );

      expect(conflict.id, 'test-id');
      expect(conflict.entityType, EntityType.expense);
      expect(conflict.entityId, 'expense-1');
      expect(conflict.operation, SyncOperation.update);
      expect(conflict.localData['amount'], 100);
      expect(conflict.serverData['amount'], 150);
      expect(conflict.conflictReason, 'Data mismatch');
    });
  });
}
