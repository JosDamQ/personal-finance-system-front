import '../../../core/enums/app_enums.dart';
import '../../database/database_helper.dart';
import '../../models/category_model.dart';
import '../interfaces/i_category_repository.dart';

class LocalCategoryRepository implements ICategoryRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  Future<CategoryModel> create(CategoryModel category) async {
    final db = await _databaseHelper.database;

    final categoryMap = <String, dynamic>{
      'id': category.id,
      'user_id': category.userId,
      'name': category.name,
      'color': category.color,
      'icon': category.icon,
      'is_default': category.isDefault ? 1 : 0,
      'sync_status': category.syncStatus?.value ?? SyncStatus.pending.value,
      'last_sync_at': category.lastSyncAt?.toIso8601String(),
      'created_at': category.createdAt.toIso8601String(),
      'updated_at': category.updatedAt.toIso8601String(),
    };

    await db.insert('categories', categoryMap);
    return category;
  }

  @override
  Future<CategoryModel> update(String id, CategoryModel category) async {
    final db = await _databaseHelper.database;

    final categoryMap = <String, dynamic>{
      'id': category.id,
      'user_id': category.userId,
      'name': category.name,
      'color': category.color,
      'icon': category.icon,
      'is_default': category.isDefault ? 1 : 0,
      'sync_status': category.syncStatus?.value ?? SyncStatus.pending.value,
      'last_sync_at': category.lastSyncAt?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    await db.update(
      'categories',
      categoryMap,
      where: 'id = ?',
      whereArgs: [id],
    );

    return category.copyWith(updatedAt: DateTime.now());
  }

  @override
  Future<void> delete(String id) async {
    final db = await _databaseHelper.database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<CategoryModel?> findById(String id) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;
    return _mapToCategoryModel(results.first);
  }

  @override
  Future<List<CategoryModel>> findByUser(String userId) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'categories',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'is_default DESC, name ASC',
    );

    return results.map(_mapToCategoryModel).toList();
  }

  @override
  Future<CategoryModel?> findDefaultCategory(String userId) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'categories',
      where: 'user_id = ? AND is_default = 1',
      whereArgs: [userId],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return _mapToCategoryModel(results.first);
  }

  @override
  Future<List<CategoryModel>> findNonDefaultByUser(String userId) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'categories',
      where: 'user_id = ? AND is_default = 0',
      whereArgs: [userId],
      orderBy: 'name ASC',
    );

    return results.map(_mapToCategoryModel).toList();
  }

  @override
  Future<CategoryModel?> findByName(String userId, String name) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'categories',
      where: 'user_id = ? AND name = ?',
      whereArgs: [userId, name],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return _mapToCategoryModel(results.first);
  }

  @override
  Future<List<CategoryModel>> findPendingSync() async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'categories',
      where: 'sync_status = ?',
      whereArgs: [SyncStatus.pending.value],
      orderBy: 'created_at ASC',
    );

    return results.map(_mapToCategoryModel).toList();
  }

  @override
  Future<void> markAsSynced(String id) async {
    await updateSyncStatus(id, SyncStatus.synced);
  }

  @override
  Future<void> markAsConflict(String id) async {
    await updateSyncStatus(id, SyncStatus.conflict);
  }

  @override
  Future<void> updateSyncStatus(String id, SyncStatus status) async {
    final db = await _databaseHelper.database;
    await db.update(
      'categories',
      {
        'sync_status': status.value,
        'last_sync_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  CategoryModel _mapToCategoryModel(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      color: map['color'] as String,
      icon: map['icon'] as String,
      isDefault: (map['is_default'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      syncStatus: map['sync_status'] != null
          ? SyncStatus.values.firstWhere((e) => e.value == map['sync_status'])
          : null,
      lastSyncAt: map['last_sync_at'] != null
          ? DateTime.parse(map['last_sync_at'] as String)
          : null,
    );
  }
}
