import '../../models/user_model.dart';

abstract class IUserRepository {
  // Basic CRUD operations
  Future<UserModel> create(UserModel user);
  Future<UserModel> update(String id, UserModel user);
  Future<void> delete(String id);
  Future<UserModel?> findById(String id);
  Future<UserModel?> findByEmail(String email);

  // Local operations
  Future<UserModel?> getCurrentUser();
  Future<void> setCurrentUser(UserModel user);
  Future<void> clearCurrentUser();
}
