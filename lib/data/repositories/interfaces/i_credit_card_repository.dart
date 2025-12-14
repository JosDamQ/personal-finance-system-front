import '../../../core/enums/app_enums.dart';
import '../../models/credit_card_model.dart';

abstract class ICreditCardRepository {
  // Basic CRUD operations
  Future<CreditCardModel> create(CreditCardModel creditCard);
  Future<CreditCardModel> update(String id, CreditCardModel creditCard);
  Future<void> delete(String id);
  Future<CreditCardModel?> findById(String id);
  Future<List<CreditCardModel>> findByUser(String userId);

  // Specific queries
  Future<List<CreditCardModel>> findActiveByUser(String userId);
  Future<void> updateBalance(String id, double balanceGTQ, double balanceUSD);

  // Sync operations
  Future<List<CreditCardModel>> findPendingSync();
  Future<void> markAsSynced(String id);
  Future<void> markAsConflict(String id);
  Future<void> updateSyncStatus(String id, SyncStatus status);
}
