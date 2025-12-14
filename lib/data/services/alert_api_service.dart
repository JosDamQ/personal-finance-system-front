import 'dart:convert';
import '../models/alert_model.dart';
import '../../core/enums/app_enums.dart';
import 'api_service.dart';

/// API service for alert-related operations
class AlertApiService {
  static final AlertApiService _instance = AlertApiService._internal();
  factory AlertApiService() => _instance;
  AlertApiService._internal();

  final ApiService _apiService = ApiService();

  /// Get all alerts for the current user
  Future<List<AlertModel>> getAlerts({
    bool? isRead,
    AlertType? type,
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String>[];

    if (isRead != null) queryParams.add('isRead=$isRead');
    if (type != null) queryParams.add('type=${type.name.toUpperCase()}');
    if (limit != null) queryParams.add('limit=$limit');
    if (offset != null) queryParams.add('offset=$offset');

    final queryString = queryParams.isNotEmpty
        ? '?${queryParams.join('&')}'
        : '';
    final response = await _apiService.get('/api/v1/alerts$queryString');
    return _apiService.parseListResponse(response, AlertModel.fromJson);
  }

  /// Get a specific alert by ID
  Future<AlertModel> getAlert(String alertId) async {
    final response = await _apiService.get('/api/v1/alerts/$alertId');
    return _apiService.parseDataResponse(response, AlertModel.fromJson);
  }

  /// Mark an alert as read
  Future<AlertModel> markAsRead(String alertId) async {
    final response = await _apiService.put('/api/v1/alerts/$alertId/read');
    return _apiService.parseDataResponse(response, AlertModel.fromJson);
  }

  /// Mark multiple alerts as read
  Future<List<AlertModel>> markMultipleAsRead(List<String> alertIds) async {
    final body = jsonEncode({'alertIds': alertIds});
    final response = await _apiService.put(
      '/api/v1/alerts/bulk-read',
      body: body,
    );
    return _apiService.parseListResponse(response, AlertModel.fromJson);
  }

  /// Delete an alert
  Future<void> deleteAlert(String alertId) async {
    await _apiService.delete('/api/v1/alerts/$alertId');
  }

  /// Delete multiple alerts
  Future<void> deleteMultipleAlerts(List<String> alertIds) async {
    final body = jsonEncode({'alertIds': alertIds});
    await _apiService.delete('/api/v1/alerts/bulk', body: body);
  }

  /// Get unread alert count
  Future<int> getUnreadCount() async {
    final response = await _apiService.get('/api/v1/alerts/unread-count');
    final data = _apiService.parseResponse(response);
    return data['data']['count'] as int;
  }

  /// Get alerts by type
  Future<List<AlertModel>> getAlertsByType(AlertType type) async {
    final response = await _apiService.get(
      '/api/v1/alerts?type=${type.name.toUpperCase()}',
    );
    return _apiService.parseListResponse(response, AlertModel.fromJson);
  }

  /// Create a manual alert (for testing or admin purposes)
  Future<AlertModel> createAlert({
    required AlertType type,
    required String title,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    final body = jsonEncode({
      'type': type.name.toUpperCase(),
      'title': title,
      'message': message,
      if (metadata != null) 'metadata': metadata,
    });

    final response = await _apiService.post('/api/v1/alerts', body: body);
    return _apiService.parseDataResponse(response, AlertModel.fromJson);
  }

  /// Get alert statistics
  Future<Map<String, dynamic>> getAlertStats() async {
    final response = await _apiService.get('/api/v1/alerts/stats');
    return _apiService.parseResponse(response);
  }

  /// Clear all read alerts
  Future<void> clearReadAlerts() async {
    await _apiService.delete('/api/v1/alerts/read');
  }

  /// Get recent alerts (last 7 days)
  Future<List<AlertModel>> getRecentAlerts({int? limit}) async {
    final queryParams = <String>[];
    if (limit != null) queryParams.add('limit=$limit');

    final queryString = queryParams.isNotEmpty
        ? '?${queryParams.join('&')}'
        : '';
    final response = await _apiService.get('/api/v1/alerts/recent$queryString');
    return _apiService.parseListResponse(response, AlertModel.fromJson);
  }

  /// Update alert preferences
  Future<Map<String, dynamic>> updateAlertPreferences({
    bool? creditLimitWarnings,
    bool? budgetExceededAlerts,
    bool? paymentReminders,
    bool? monthlySummary,
  }) async {
    final body = jsonEncode({
      if (creditLimitWarnings != null)
        'creditLimitWarnings': creditLimitWarnings,
      if (budgetExceededAlerts != null)
        'budgetExceededAlerts': budgetExceededAlerts,
      if (paymentReminders != null) 'paymentReminders': paymentReminders,
      if (monthlySummary != null) 'monthlySummary': monthlySummary,
    });

    final response = await _apiService.put(
      '/api/v1/alerts/preferences',
      body: body,
    );
    return _apiService.parseResponse(response);
  }

  /// Get alert preferences
  Future<Map<String, dynamic>> getAlertPreferences() async {
    final response = await _apiService.get('/api/v1/alerts/preferences');
    return _apiService.parseResponse(response);
  }
}
