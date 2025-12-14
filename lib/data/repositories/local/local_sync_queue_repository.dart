import 'dart:convert';
import '../../../core/enums/app_enums.dart';
import '../../database/database_helper.dart';
import '../../models/sync_queue_model.dart';
import '../interfaces/i_sync_queue_repository.dart';

class LocalSyncQueueRepository implements ISyncQueueRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  Future<SyncQueueModel> create(SyncQueueModel syncItem) async {
    final db = await _databaseHelper.database;

    final syncMap = <String, dynamic>{
      'id': syncItem.id,
      'user_id': syncItem.userId,
      'operation': syncItem.operation.value,
      'entity_type': syncItem.entityType.value,
      'entity_id': syncItem.entityId,
      'data': jsonEncode(syncItem.data),
      'retry_count': syncItem.retryCount,
      'max_retries': syncItem.maxRetries,
      'status': syncItem.status.value,
      'error_message': syncItem.errorMessage,
      'created_at': syncItem.createdAt.toIso8601String(),
      'updated_at': syncItem.updatedAt.toIso8601String(),
    };

    await db.insert('sync_queue', syncMap);
    return syncItem;
  }

  @override
  Future<SyncQueueModel> update(String id, SyncQueueModel syncItem) async {
    final db = await _databaseHelper.database;

    final syncMap = <String, dynamic>{
      'id': syncItem.id,
      'user_id': syncItem.userId,
      'operation': syncItem.operation.value,
      'entity_type': syncItem.entityType.value,
      'entity_id': syncItem.entityId,
      'data': jsonEncode(syncItem.data),
      'retry_count': syncItem.retryCount,
      'max_retries': syncItem.maxRetries,
      'status': syncItem.status.value,
      'error_message': syncItem.errorMessage,
      'updated_at': DateTime.now().toIso8601String(),
    };

    await db.update('sync_queue', syncMap, where: 'id = ?', whereArgs: [id]);

    return syncItem.copyWith(updatedAt: DateTime.now());
  }

  @override
  Future<void> delete(String id) async {
    final db = await _databaseHelper.database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<SyncQueueModel?> findById(String id) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'sync_queue',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;
    return _mapToSyncQueueModel(results.first);
  }

  @override
  Future<List<SyncQueueModel>> findByUser(String userId) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'sync_queue',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at ASC',
    );

    return results.map(_mapToSyncQueueModel).toList();
  }

  @override
  Future<List<SyncQueueModel>> findPendingItems(String userId) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'sync_queue',
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, SyncQueueStatus.pending.value],
      orderBy: 'created_at ASC',
    );

    return results.map(_mapToSyncQueueModel).toList();
  }

  @override
  Future<List<SyncQueueModel>> findFailedItems(String userId) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'sync_queue',
      where: 'user_id = ? AND status = ? AND retry_count < max_retries',
      whereArgs: [userId, SyncQueueStatus.failed.value],
      orderBy: 'created_at ASC',
    );

    return results.map(_mapToSyncQueueModel).toList();
  }

  @override
  Future<void> markAsProcessing(String id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'sync_queue',
      {
        'status': SyncQueueStatus.processing.value,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> markAsCompleted(String id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'sync_queue',
      {
        'status': SyncQueueStatus.completed.value,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> markAsFailed(String id, String errorMessage) async {
    final db = await _databaseHelper.database;
    await db.update(
      'sync_queue',
      {
        'status': SyncQueueStatus.failed.value,
        'error_message': errorMessage,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> incrementRetryCount(String id) async {
    final db = await _databaseHelper.database;
    await db.rawUpdate(
      'UPDATE sync_queue SET retry_count = retry_count + 1, updated_at = ? WHERE id = ?',
      [DateTime.now().toIso8601String(), id],
    );
  }

  @override
  Future<void> clearCompletedItems(String userId) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'sync_queue',
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, SyncQueueStatus.completed.value],
    );
  }

  @override
  Future<void> clearAllItems(String userId) async {
    final db = await _databaseHelper.database;
    await db.delete('sync_queue', where: 'user_id = ?', whereArgs: [userId]);
  }

  SyncQueueModel _mapToSyncQueueModel(Map<String, dynamic> map) {
    Map<String, dynamic> data;
    try {
      data = jsonDecode(map['data'] as String) as Map<String, dynamic>;
    } catch (e) {
      data = {};
    }

    return SyncQueueModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      operation: SyncOperation.values.firstWhere(
        (e) => e.value == map['operation'],
      ),
      entityType: EntityType.values.firstWhere(
        (e) => e.value == map['entity_type'],
      ),
      entityId: map['entity_id'] as String,
      data: data,
      retryCount: map['retry_count'] as int,
      maxRetries: map['max_retries'] as int,
      status: SyncQueueStatus.values.firstWhere(
        (e) => e.value == map['status'],
      ),
      errorMessage: map['error_message'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
