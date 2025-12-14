import 'dart:convert';
import '../models/user_model.dart';
import 'api_service.dart';

/// API service for user-related operations
class UserApiService {
  static final UserApiService _instance = UserApiService._internal();
  factory UserApiService() => _instance;
  UserApiService._internal();

  final ApiService _apiService = ApiService();

  /// Get current user profile
  Future<UserModel> getCurrentUser() async {
    final response = await _apiService.get('/api/v1/users/profile');
    return _apiService.parseDataResponse(response, UserModel.fromJson);
  }

  /// Update user profile
  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? defaultCurrency,
    String? theme,
  }) async {
    final body = jsonEncode({
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (defaultCurrency != null) 'defaultCurrency': defaultCurrency,
      if (theme != null) 'theme': theme,
    });

    final response = await _apiService.put('/api/v1/users/profile', body: body);
    return _apiService.parseDataResponse(response, UserModel.fromJson);
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final body = jsonEncode({
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });

    await _apiService.put('/api/v1/users/password', body: body);
  }

  /// Update user preferences
  Future<Map<String, dynamic>> updatePreferences({
    String? defaultCurrency,
    String? theme,
    String? language,
    Map<String, dynamic>? notificationSettings,
    Map<String, dynamic>? privacySettings,
  }) async {
    final body = jsonEncode({
      if (defaultCurrency != null) 'defaultCurrency': defaultCurrency,
      if (theme != null) 'theme': theme,
      if (language != null) 'language': language,
      if (notificationSettings != null)
        'notificationSettings': notificationSettings,
      if (privacySettings != null) 'privacySettings': privacySettings,
    });

    final response = await _apiService.put(
      '/api/v1/users/preferences',
      body: body,
    );
    return _apiService.parseResponse(response);
  }

  /// Get user preferences
  Future<Map<String, dynamic>> getPreferences() async {
    final response = await _apiService.get('/api/v1/users/preferences');
    return _apiService.parseResponse(response);
  }

  /// Delete user account
  Future<void> deleteAccount({required String password}) async {
    final body = jsonEncode({'password': password});
    await _apiService.delete('/api/v1/users/account', body: body);
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStats() async {
    final response = await _apiService.get('/api/v1/users/stats');
    return _apiService.parseResponse(response);
  }

  /// Export user data
  Future<Map<String, dynamic>> exportUserData() async {
    final response = await _apiService.get('/api/v1/users/export');
    return _apiService.parseResponse(response);
  }

  /// Update notification preferences
  Future<Map<String, dynamic>> updateNotificationPreferences({
    bool? emailNotifications,
    bool? pushNotifications,
    bool? budgetAlerts,
    bool? creditLimitAlerts,
    bool? paymentReminders,
    bool? monthlySummary,
  }) async {
    final body = jsonEncode({
      if (emailNotifications != null) 'emailNotifications': emailNotifications,
      if (pushNotifications != null) 'pushNotifications': pushNotifications,
      if (budgetAlerts != null) 'budgetAlerts': budgetAlerts,
      if (creditLimitAlerts != null) 'creditLimitAlerts': creditLimitAlerts,
      if (paymentReminders != null) 'paymentReminders': paymentReminders,
      if (monthlySummary != null) 'monthlySummary': monthlySummary,
    });

    final response = await _apiService.put(
      '/api/v1/users/notifications',
      body: body,
    );
    return _apiService.parseResponse(response);
  }

  /// Get notification preferences
  Future<Map<String, dynamic>> getNotificationPreferences() async {
    final response = await _apiService.get('/api/v1/users/notifications');
    return _apiService.parseResponse(response);
  }

  /// Update privacy settings
  Future<Map<String, dynamic>> updatePrivacySettings({
    bool? dataSharing,
    bool? analytics,
    bool? crashReporting,
  }) async {
    final body = jsonEncode({
      if (dataSharing != null) 'dataSharing': dataSharing,
      if (analytics != null) 'analytics': analytics,
      if (crashReporting != null) 'crashReporting': crashReporting,
    });

    final response = await _apiService.put('/api/v1/users/privacy', body: body);
    return _apiService.parseResponse(response);
  }

  /// Get privacy settings
  Future<Map<String, dynamic>> getPrivacySettings() async {
    final response = await _apiService.get('/api/v1/users/privacy');
    return _apiService.parseResponse(response);
  }

  /// Verify email address
  Future<void> verifyEmail(String token) async {
    final body = jsonEncode({'token': token});
    await _apiService.post('/api/v1/users/verify-email', body: body);
  }

  /// Request email verification
  Future<void> requestEmailVerification() async {
    await _apiService.post('/api/v1/users/request-verification');
  }

  /// Update user avatar/profile picture
  Future<UserModel> updateAvatar(String base64Image) async {
    final body = jsonEncode({'avatar': base64Image});
    final response = await _apiService.put('/api/v1/users/avatar', body: body);
    return _apiService.parseDataResponse(response, UserModel.fromJson);
  }

  /// Remove user avatar
  Future<UserModel> removeAvatar() async {
    final response = await _apiService.delete('/api/v1/users/avatar');
    return _apiService.parseDataResponse(response, UserModel.fromJson);
  }

  /// Get user activity log
  Future<List<Map<String, dynamic>>> getActivityLog({
    int? limit,
    DateTime? since,
  }) async {
    final queryParams = <String>[];
    if (limit != null) queryParams.add('limit=$limit');
    if (since != null) queryParams.add('since=${since.toIso8601String()}');

    final queryString = queryParams.isNotEmpty
        ? '?${queryParams.join('&')}'
        : '';
    final response = await _apiService.get(
      '/api/v1/users/activity$queryString',
    );
    final data = _apiService.parseResponse(response);
    return List<Map<String, dynamic>>.from(data['data']);
  }

  /// Get user sessions
  Future<List<Map<String, dynamic>>> getUserSessions() async {
    final response = await _apiService.get('/api/v1/users/sessions');
    final data = _apiService.parseResponse(response);
    return List<Map<String, dynamic>>.from(data['data']);
  }

  /// Revoke user session
  Future<void> revokeSession(String sessionId) async {
    await _apiService.delete('/api/v1/users/sessions/$sessionId');
  }

  /// Revoke all sessions except current
  Future<void> revokeAllOtherSessions() async {
    await _apiService.delete('/api/v1/users/sessions/others');
  }
}
