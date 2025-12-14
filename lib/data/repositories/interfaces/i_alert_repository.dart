import '../../../core/enums/app_enums.dart';
import '../../models/alert_model.dart';

abstract class IAlertRepository {
  // Basic CRUD operations
  Future<AlertModel> create(AlertModel alert);
  Future<AlertModel> update(String id, AlertModel alert);
  Future<void> delete(String id);
  Future<AlertModel?> findById(String id);
  Future<List<AlertModel>> findByUser(String userId);

  // Specific queries
  Future<List<AlertModel>> findUnreadByUser(String userId);
  Future<List<AlertModel>> findByType(String userId, AlertType type);
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead(String userId);
  Future<int> getUnreadCount(String userId);
}
