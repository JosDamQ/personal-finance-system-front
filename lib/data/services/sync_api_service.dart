import 'dart:convert';
import '../models/sync_queue_model.dart';
import '../../core/enums/app_enums.dart';
import 'api_service.dart';

/// API service for synchronization-related operations
class SyncApiService {
  static final SyncApiService _instance = SyncApiService._internal();
  factory SyncApiService() => _instance;
  SyncApiService._internal();

  final ApiService _apiService = ApiService();

  /// Sync operations in batch
  Future<Map<String, dynamic>> syncBatch(
    List<SyncQueueModel> operations,
  ) async {
    final body = jsonEncode({
      'operations': operations.map((op) => op.toJson()).toList(),
    });

    final response = await _apiService.post('/api/v1/sync/batch', body: body);
    return _apiService.parseResponse(response);
  }

  /// Get sync status for user
  Future<Map<String, dynamic>> getSyncStatus() async {
    final response = await _apiService.get('/api/v1/sync/status');
    return _apiService.parseResponse(response);
  }

  /// Resolve sync conflicts
  Future<Map<String, dynamic>> resolveConflicts(
    List<Map<String, dynamic>> resolutions,
  ) async {
    final body = jsonEncode({'resolutions': resolutions});

    final response = await _apiService.post('/api/v1/sync/resolve', body: body);
    return _apiService.parseResponse(response);
  }

  /// Get pending conflicts
  Future<List<Map<String, dynamic>>> getConflicts() async {
    final response = await _apiService.get('/api/v1/sync/conflicts');
    final data = _apiService.parseResponse(response);
    return List<Map<String, dynamic>>.from(data['data']);
  }

  /// Force full sync (download all data from server)
  Future<Map<String, dynamic>> forceFullSync() async {
    final response = await _apiService.post('/api/v1/sync/full');
    return _apiService.parseResponse(response);
  }

  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTime() async {
    final response = await _apiService.get('/api/v1/sync/last-sync');
    final data = _apiService.parseResponse(response);

    if (data['data']['lastSync'] != null) {
      return DateTime.parse(data['data']['lastSync']);
    }
    return null;
  }

  /// Sync specific entity type
  Future<Map<String, dynamic>> syncEntityType(EntityType entityType) async {
    final body = jsonEncode({'entityType': entityType.name.toUpperCase()});

    final response = await _apiService.post('/api/v1/sync/entity', body: body);
    return _apiService.parseResponse(response);
  }

  /// Get sync statistics
  Future<Map<String, dynamic>> getSyncStats() async {
    final response = await _apiService.get('/api/v1/sync/stats');
    return _apiService.parseResponse(response);
  }

  /// Push local changes to server
  Future<Map<String, dynamic>> pushChanges(
    List<Map<String, dynamic>> changes,
  ) async {
    final body = jsonEncode({'changes': changes});

    final response = await _apiService.post('/api/v1/sync/push', body: body);
    return _apiService.parseResponse(response);
  }

  /// Pull changes from server
  Future<Map<String, dynamic>> pullChanges({
    DateTime? since,
    List<EntityType>? entityTypes,
  }) async {
    final queryParams = <String>[];
    if (since != null) {
      queryParams.add('since=${since.toIso8601String()}');
    }
    if (entityTypes != null) {
      queryParams.add(
        'types=${entityTypes.map((e) => e.name.toUpperCase()).join(',')}',
      );
    }

    final queryString = queryParams.isNotEmpty
        ? '?${queryParams.join('&')}'
        : '';
    final response = await _apiService.get('/api/v1/sync/pull$queryString');
    return _apiService.parseResponse(response);
  }

  /// Check for server changes
  Future<Map<String, dynamic>> checkForChanges({DateTime? since}) async {
    final queryParams = <String>[];
    if (since != null) {
      queryParams.add('since=${since.toIso8601String()}');
    }

    final queryString = queryParams.isNotEmpty
        ? '?${queryParams.join('&')}'
        : '';
    final response = await _apiService.get('/api/v1/sync/check$queryString');
    return _apiService.parseResponse(response);
  }

  /// Reset sync state (clear all sync metadata)
  Future<Map<String, dynamic>> resetSyncState() async {
    final response = await _apiService.post('/api/v1/sync/reset');
    return _apiService.parseResponse(response);
  }

  /// Validate data integrity
  Future<Map<String, dynamic>> validateIntegrity() async {
    final response = await _apiService.post('/api/v1/sync/validate');
    return _apiService.parseResponse(response);
  }

  /// Get sync queue status
  Future<Map<String, dynamic>> getQueueStatus() async {
    final response = await _apiService.get('/api/v1/sync/queue');
    return _apiService.parseResponse(response);
  }

  /// Clear sync queue
  Future<Map<String, dynamic>> clearQueue() async {
    final response = await _apiService.delete('/api/v1/sync/queue');
    return _apiService.parseResponse(response);
  }

  /// Retry failed sync operations
  Future<Map<String, dynamic>> retryFailedOperations() async {
    final response = await _apiService.post('/api/v1/sync/retry');
    return _apiService.parseResponse(response);
  }

  /// Get sync logs
  Future<List<Map<String, dynamic>>> getSyncLogs({
    int? limit,
    DateTime? since,
  }) async {
    final queryParams = <String>[];
    if (limit != null) queryParams.add('limit=$limit');
    if (since != null) queryParams.add('since=${since.toIso8601String()}');

    final queryString = queryParams.isNotEmpty
        ? '?${queryParams.join('&')}'
        : '';
    final response = await _apiService.get('/api/v1/sync/logs$queryString');
    final data = _apiService.parseResponse(response);
    return List<Map<String, dynamic>>.from(data['data']);
  }

  /// Mark sync operation as completed
  Future<void> markOperationCompleted(String operationId) async {
    await _apiService.put('/api/v1/sync/operations/$operationId/complete');
  }

  /// Mark sync operation as failed
  Future<void> markOperationFailed(String operationId, String error) async {
    final body = jsonEncode({'error': error});
    await _apiService.put(
      '/api/v1/sync/operations/$operationId/failed',
      body: body,
    );
  }

  /// Get server timestamp for sync coordination
  Future<DateTime> getServerTimestamp() async {
    final response = await _apiService.get('/api/v1/sync/timestamp');
    final data = _apiService.parseResponse(response);
    return DateTime.parse(data['data']['timestamp']);
  }
}
