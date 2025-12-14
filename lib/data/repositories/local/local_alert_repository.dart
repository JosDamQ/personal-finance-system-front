import 'dart:convert';
import '../../../core/enums/app_enums.dart';
import '../../database/database_helper.dart';
import '../../models/alert_model.dart';
import '../interfaces/i_alert_repository.dart';

class LocalAlertRepository implements IAlertRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  Future<AlertModel> create(AlertModel alert) async {
    final db = await _databaseHelper.database;

    final alertMap = <String, dynamic>{
      'id': alert.id,
      'user_id': alert.userId,
      'type': alert.type.value,
      'title': alert.title,
      'message': alert.message,
      'is_read': alert.isRead ? 1 : 0,
      'metadata': alert.metadata != null ? jsonEncode(alert.metadata) : null,
      'created_at': alert.createdAt.toIso8601String(),
      'updated_at': alert.updatedAt.toIso8601String(),
    };

    await db.insert('alerts', alertMap);
    return alert;
  }

  @override
  Future<AlertModel> update(String id, AlertModel alert) async {
    final db = await _databaseHelper.database;

    final alertMap = <String, dynamic>{
      'id': alert.id,
      'user_id': alert.userId,
      'type': alert.type.value,
      'title': alert.title,
      'message': alert.message,
      'is_read': alert.isRead ? 1 : 0,
      'metadata': alert.metadata != null ? jsonEncode(alert.metadata) : null,
      'updated_at': DateTime.now().toIso8601String(),
    };

    await db.update('alerts', alertMap, where: 'id = ?', whereArgs: [id]);

    return alert.copyWith(updatedAt: DateTime.now());
  }

  @override
  Future<void> delete(String id) async {
    final db = await _databaseHelper.database;
    await db.delete('alerts', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<AlertModel?> findById(String id) async {
    final db = await _databaseHelper.database;
    final results = await db.query('alerts', where: 'id = ?', whereArgs: [id]);

    if (results.isEmpty) return null;
    return _mapToAlertModel(results.first);
  }

  @override
  Future<List<AlertModel>> findByUser(String userId) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'alerts',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return results.map(_mapToAlertModel).toList();
  }

  @override
  Future<List<AlertModel>> findUnreadByUser(String userId) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'alerts',
      where: 'user_id = ? AND is_read = 0',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return results.map(_mapToAlertModel).toList();
  }

  @override
  Future<List<AlertModel>> findByType(String userId, AlertType type) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'alerts',
      where: 'user_id = ? AND type = ?',
      whereArgs: [userId, type.value],
      orderBy: 'created_at DESC',
    );

    return results.map(_mapToAlertModel).toList();
  }

  @override
  Future<void> markAsRead(String id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'alerts',
      {'is_read': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final db = await _databaseHelper.database;
    await db.update(
      'alerts',
      {'is_read': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'user_id = ? AND is_read = 0',
      whereArgs: [userId],
    );
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM alerts WHERE user_id = ? AND is_read = 0',
      [userId],
    );

    return (result.first['count'] as int?) ?? 0;
  }

  AlertModel _mapToAlertModel(Map<String, dynamic> map) {
    Map<String, dynamic>? metadata;
    if (map['metadata'] != null) {
      try {
        metadata =
            jsonDecode(map['metadata'] as String) as Map<String, dynamic>;
      } catch (e) {
        metadata = null;
      }
    }

    return AlertModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      type: AlertType.values.firstWhere((e) => e.value == map['type']),
      title: map['title'] as String,
      message: map['message'] as String,
      isRead: (map['is_read'] as int) == 1,
      metadata: metadata,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
