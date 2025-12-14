import 'dart:convert';
import '../models/category_model.dart';
import 'api_service.dart';

/// API service for category-related operations
class CategoryApiService {
  static final CategoryApiService _instance = CategoryApiService._internal();
  factory CategoryApiService() => _instance;
  CategoryApiService._internal();

  final ApiService _apiService = ApiService();

  /// Get all categories for the current user
  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiService.get('/api/v1/categories');
    return _apiService.parseListResponse(response, CategoryModel.fromJson);
  }

  /// Get a specific category by ID
  Future<CategoryModel> getCategory(String categoryId) async {
    final response = await _apiService.get('/api/v1/categories/$categoryId');
    return _apiService.parseDataResponse(response, CategoryModel.fromJson);
  }

  /// Create a new category
  Future<CategoryModel> createCategory({
    required String name,
    required String color,
    required String icon,
    bool? isDefault,
  }) async {
    final body = jsonEncode({
      'name': name,
      'color': color,
      'icon': icon,
      if (isDefault != null) 'isDefault': isDefault,
    });

    final response = await _apiService.post('/api/v1/categories', body: body);
    return _apiService.parseDataResponse(response, CategoryModel.fromJson);
  }

  /// Update an existing category
  Future<CategoryModel> updateCategory(
    String categoryId, {
    String? name,
    String? color,
    String? icon,
    bool? isDefault,
  }) async {
    final body = jsonEncode({
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (isDefault != null) 'isDefault': isDefault,
    });

    final response = await _apiService.put(
      '/api/v1/categories/$categoryId',
      body: body,
    );
    return _apiService.parseDataResponse(response, CategoryModel.fromJson);
  }

  /// Delete a category
  Future<void> deleteCategory(String categoryId) async {
    final response = await _apiService.delete('/api/v1/categories/$categoryId');
    _apiService.parseResponse(
      response,
    ); // This will throw ApiException if status is not 2xx
  }

  /// Get default categories for new users
  Future<List<CategoryModel>> getDefaultCategories() async {
    final response = await _apiService.get('/api/v1/categories/defaults');
    return _apiService.parseListResponse(response, CategoryModel.fromJson);
  }

  /// Get category usage statistics
  Future<Map<String, dynamic>> getCategoryStats(
    String categoryId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String>[];
    if (startDate != null) {
      queryParams.add('startDate=${startDate.toIso8601String()}');
    }
    if (endDate != null) {
      queryParams.add('endDate=${endDate.toIso8601String()}');
    }

    final queryString = queryParams.isNotEmpty
        ? '?${queryParams.join('&')}'
        : '';
    final response = await _apiService.get(
      '/api/v1/categories/$categoryId/stats$queryString',
    );
    return _apiService.parseResponse(response);
  }

  /// Get expense totals grouped by category
  Future<Map<String, double>> getCategoryTotals({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String>[];
    if (startDate != null) {
      queryParams.add('startDate=${startDate.toIso8601String()}');
    }
    if (endDate != null) {
      queryParams.add('endDate=${endDate.toIso8601String()}');
    }

    final queryString = queryParams.isNotEmpty
        ? '?${queryParams.join('&')}'
        : '';
    final response = await _apiService.get(
      '/api/v1/categories/totals$queryString',
    );
    final data = _apiService.parseResponse(response);

    // Convert to Map<String, double>
    final Map<String, double> totals = {};
    if (data['data'] is Map) {
      final Map<String, dynamic> rawTotals = data['data'];
      rawTotals.forEach((key, value) {
        totals[key] = (value as num).toDouble();
      });
    }

    return totals;
  }

  /// Bulk create default categories for a new user
  Future<List<CategoryModel>> createDefaultCategories() async {
    final response = await _apiService.post('/api/v1/categories/initialize');
    return _apiService.parseListResponse(response, CategoryModel.fromJson);
  }
}
