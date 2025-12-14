import 'dart:convert';
import '../models/budget_model.dart';
import 'api_service.dart';

/// API service for budget-related operations
class BudgetApiService {
  static final BudgetApiService _instance = BudgetApiService._internal();
  factory BudgetApiService() => _instance;
  BudgetApiService._internal();

  final ApiService _apiService = ApiService();

  /// Get all budgets for the current user
  Future<List<BudgetModel>> getBudgets() async {
    final response = await _apiService.get('/api/v1/budgets');
    return _apiService.parseListResponse(response, BudgetModel.fromJson);
  }

  /// Get a specific budget by ID
  Future<BudgetModel> getBudget(String budgetId) async {
    final response = await _apiService.get('/api/v1/budgets/$budgetId');
    return _apiService.parseDataResponse(response, BudgetModel.fromJson);
  }

  /// Create a new budget
  Future<BudgetModel> createBudget({
    required int month,
    required int year,
    required String paymentFrequency,
    required double totalIncome,
    required List<Map<String, dynamic>> periods,
  }) async {
    final body = jsonEncode({
      'month': month,
      'year': year,
      'paymentFrequency': paymentFrequency,
      'totalIncome': totalIncome,
      'periods': periods,
    });

    final response = await _apiService.post('/api/v1/budgets', body: body);
    return _apiService.parseDataResponse(response, BudgetModel.fromJson);
  }

  /// Update an existing budget
  Future<BudgetModel> updateBudget(
    String budgetId, {
    int? month,
    int? year,
    String? paymentFrequency,
    double? totalIncome,
    List<Map<String, dynamic>>? periods,
  }) async {
    final body = jsonEncode({
      if (month != null) 'month': month,
      if (year != null) 'year': year,
      if (paymentFrequency != null) 'paymentFrequency': paymentFrequency,
      if (totalIncome != null) 'totalIncome': totalIncome,
      if (periods != null) 'periods': periods,
    });

    final response = await _apiService.put(
      '/api/v1/budgets/$budgetId',
      body: body,
    );
    return _apiService.parseDataResponse(response, BudgetModel.fromJson);
  }

  /// Delete a budget
  Future<void> deleteBudget(String budgetId) async {
    await _apiService.delete('/api/v1/budgets/$budgetId');
  }

  /// Export budget as image
  Future<Map<String, dynamic>> exportBudgetAsImage(String budgetId) async {
    final response = await _apiService.post('/api/v1/budgets/$budgetId/export');
    return _apiService.parseResponse(response);
  }

  /// Get budgets for a specific date range
  Future<List<BudgetModel>> getBudgetsByDateRange({
    required int startYear,
    required int startMonth,
    required int endYear,
    required int endMonth,
  }) async {
    final response = await _apiService.get(
      '/api/v1/budgets?startYear=$startYear&startMonth=$startMonth&endYear=$endYear&endMonth=$endMonth',
    );
    return _apiService.parseListResponse(response, BudgetModel.fromJson);
  }

  /// Copy budget from previous month
  Future<BudgetModel> copyFromPreviousMonth({
    required int targetMonth,
    required int targetYear,
    required String sourceBudgetId,
  }) async {
    final body = jsonEncode({
      'targetMonth': targetMonth,
      'targetYear': targetYear,
      'sourceBudgetId': sourceBudgetId,
    });

    final response = await _apiService.post('/api/v1/budgets/copy', body: body);
    return _apiService.parseDataResponse(response, BudgetModel.fromJson);
  }
}
