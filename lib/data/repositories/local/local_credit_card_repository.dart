import '../../../core/enums/app_enums.dart';
import '../../database/database_helper.dart';
import '../../models/credit_card_model.dart';
import '../interfaces/i_credit_card_repository.dart';

class LocalCreditCardRepository implements ICreditCardRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  Future<CreditCardModel> create(CreditCardModel creditCard) async {
    final db = await _databaseHelper.database;

    final cardMap = <String, dynamic>{
      'id': creditCard.id,
      'user_id': creditCard.userId,
      'name': creditCard.name,
      'bank': creditCard.bank,
      'limit_gtq': creditCard.limitGTQ,
      'limit_usd': creditCard.limitUSD,
      'current_balance_gtq': creditCard.currentBalanceGTQ,
      'current_balance_usd': creditCard.currentBalanceUSD,
      'is_active': creditCard.isActive ? 1 : 0,
      'sync_status': creditCard.syncStatus?.value ?? SyncStatus.pending.value,
      'last_sync_at': creditCard.lastSyncAt?.toIso8601String(),
      'created_at': creditCard.createdAt.toIso8601String(),
      'updated_at': creditCard.updatedAt.toIso8601String(),
    };

    await db.insert('credit_cards', cardMap);
    return creditCard;
  }

  @override
  Future<CreditCardModel> update(String id, CreditCardModel creditCard) async {
    final db = await _databaseHelper.database;

    final cardMap = <String, dynamic>{
      'id': creditCard.id,
      'user_id': creditCard.userId,
      'name': creditCard.name,
      'bank': creditCard.bank,
      'limit_gtq': creditCard.limitGTQ,
      'limit_usd': creditCard.limitUSD,
      'current_balance_gtq': creditCard.currentBalanceGTQ,
      'current_balance_usd': creditCard.currentBalanceUSD,
      'is_active': creditCard.isActive ? 1 : 0,
      'sync_status': creditCard.syncStatus?.value ?? SyncStatus.pending.value,
      'last_sync_at': creditCard.lastSyncAt?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    await db.update('credit_cards', cardMap, where: 'id = ?', whereArgs: [id]);

    return creditCard.copyWith(updatedAt: DateTime.now());
  }

  @override
  Future<void> delete(String id) async {
    final db = await _databaseHelper.database;
    await db.delete('credit_cards', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<CreditCardModel?> findById(String id) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'credit_cards',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;
    return _mapToCreditCardModel(results.first);
  }

  @override
  Future<List<CreditCardModel>> findByUser(String userId) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'credit_cards',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return results.map(_mapToCreditCardModel).toList();
  }

  @override
  Future<List<CreditCardModel>> findActiveByUser(String userId) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'credit_cards',
      where: 'user_id = ? AND is_active = 1',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return results.map(_mapToCreditCardModel).toList();
  }

  @override
  Future<void> updateBalance(
    String id,
    double balanceGTQ,
    double balanceUSD,
  ) async {
    final db = await _databaseHelper.database;
    await db.update(
      'credit_cards',
      {
        'current_balance_gtq': balanceGTQ,
        'current_balance_usd': balanceUSD,
        'updated_at': DateTime.now().toIso8601String(),
        'sync_status': SyncStatus.pending.value,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<CreditCardModel>> findPendingSync() async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'credit_cards',
      where: 'sync_status = ?',
      whereArgs: [SyncStatus.pending.value],
      orderBy: 'created_at ASC',
    );

    return results.map(_mapToCreditCardModel).toList();
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
      'credit_cards',
      {
        'sync_status': status.value,
        'last_sync_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  CreditCardModel _mapToCreditCardModel(Map<String, dynamic> map) {
    return CreditCardModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      bank: map['bank'] as String,
      limitGTQ: map['limit_gtq'] as double,
      limitUSD: map['limit_usd'] as double,
      currentBalanceGTQ: map['current_balance_gtq'] as double,
      currentBalanceUSD: map['current_balance_usd'] as double,
      isActive: (map['is_active'] as int) == 1,
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
