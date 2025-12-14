import '../../database/database_helper.dart';
import '../../models/user_model.dart';
import '../interfaces/i_user_repository.dart';

class LocalUserRepository implements IUserRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  Future<UserModel> create(UserModel user) async {
    final db = await _databaseHelper.database;

    final userMap = <String, dynamic>{
      'id': user.id,
      'email': user.email,
      'name': user.name,
      'phone': user.phone,
      'oauth_provider': user.oauthProvider,
      'oauth_id': user.oauthId,
      'default_currency': user.defaultCurrency,
      'theme': user.theme,
      'created_at': user.createdAt.toIso8601String(),
      'updated_at': user.updatedAt.toIso8601String(),
    };

    await db.insert('users', userMap);
    return user;
  }

  @override
  Future<UserModel> update(String id, UserModel user) async {
    final db = await _databaseHelper.database;

    final userMap = <String, dynamic>{
      'id': user.id,
      'email': user.email,
      'name': user.name,
      'phone': user.phone,
      'oauth_provider': user.oauthProvider,
      'oauth_id': user.oauthId,
      'default_currency': user.defaultCurrency,
      'theme': user.theme,
      'updated_at': DateTime.now().toIso8601String(),
    };

    await db.update('users', userMap, where: 'id = ?', whereArgs: [id]);

    return user.copyWith(updatedAt: DateTime.now());
  }

  @override
  Future<void> delete(String id) async {
    final db = await _databaseHelper.database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<UserModel?> findById(String id) async {
    final db = await _databaseHelper.database;
    final results = await db.query('users', where: 'id = ?', whereArgs: [id]);

    if (results.isEmpty) return null;
    return _mapToUserModel(results.first);
  }

  @override
  Future<UserModel?> findByEmail(String email) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (results.isEmpty) return null;
    return _mapToUserModel(results.first);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'users',
      limit: 1,
      orderBy: 'updated_at DESC',
    );

    if (results.isEmpty) return null;
    return _mapToUserModel(results.first);
  }

  @override
  Future<void> setCurrentUser(UserModel user) async {
    // Clear existing users and set this as the current user
    final db = await _databaseHelper.database;
    await db.delete('users');
    await create(user);
  }

  @override
  Future<void> clearCurrentUser() async {
    final db = await _databaseHelper.database;
    await db.delete('users');
  }

  UserModel _mapToUserModel(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String?,
      phone: map['phone'] as String?,
      oauthProvider: map['oauth_provider'] as String?,
      oauthId: map['oauth_id'] as String?,
      defaultCurrency: map['default_currency'] as String,
      theme: map['theme'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
