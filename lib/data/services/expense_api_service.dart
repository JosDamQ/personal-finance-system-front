import 'dart:convert';
import '../models/expense_model.dart';
import '../../core/enums/app_enums.dart';
import 'api_service.dart';

/// API service for expense-related operations
class ExpenseApiService {
  static final ExpenseApiService _instance = ExpenseApiService._internal();
  factory ExpenseApiService() => _instance;
  ExpenseApiService._internal();

  final ApiService _apiService = ApiService();

  /// Get all expenses with optional filters
  Future<List<ExpenseModel>> getExpenses({
    String? categoryId,
    String? creditCardId,
    String? budgetPeriodId,
    DateTime? startDate,
    DateTime? endDate,
    Currency? currency,
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String>[];

    if (categoryId != null) queryParams.add('categoryId=$categoryId');
    if (creditCardId != null) queryParams.add('creditCardId=$creditCardId');
    if (budgetPeriodId != null)
      queryParams.add('budgetPeriodId=$budgetPeriodId');
    if (startDate != null)
      queryParams.add('startDate=${startDate.toIso8601String()}');
    if (endDate != null)
      queryParams.add('endDate=${endDate.toIso8601String()}');
    if (currency != null)
      queryParams.add('currency=${currency.name.toUpperCase()}');
    if (limit != null) queryParams.add('limit=$limit');
    if (offset != null) queryParams.add('offset=$offset');

    final queryString = queryParams.isNotEmpty
        ? '?${queryParams.join('&')}'
        : '';
    final response = await _apiService.get('/api/v1/expenses$queryString');
    return _apiService.parseListResponse(response, ExpenseModel.fromJson);
  }

  /// Get a specific expense by ID
  Future<ExpenseModel> getExpense(String expenseId) async {
    final response = await _apiService.get('/api/v1/expenses/$expenseId');
    return _apiService.parseDataResponse(response, ExpenseModel.fromJson);
  }

  /// Create a new expense
  Future<ExpenseModel> createExpense({
    required String categoryId,
    String? creditCardId,
    String? budgetPeriodId,
    required double amount,
    required Currency currency,
    required String description,
    DateTime? date,
  }) async {
    final body = jsonEncode({
      'categoryId': categoryId,
      if (creditCardId != null) 'creditCardId': creditCardId,
      if (budgetPeriodId != null) 'budgetPeriodId': budgetPeriodId,
      'amount': amount,
      'currency': currency.name.toUpperCase(),
      'description': description,
      'date': (date ?? DateTime.now()).toIso8601String(),
    });

    final response = await _apiService.post('/api/v1/expenses', body: body);
    return _apiService.parseDataResponse(response, ExpenseModel.fromJson);
  }

  /// Update an existing expense
  Future<ExpenseModel> updateExpense(
    String expenseId, {
    String? categoryId,
    String? creditCardId,
    String? budgetPeriodId,
    double? amount,
    Currency? currency,
    String? description,
    DateTime? date,
  }) async {
    final body = jsonEncode({
      if (categoryId != null) 'categoryId': categoryId,
      if (creditCardId != null) 'creditCardId': creditCardId,
      if (budgetPeriodId != null) 'budgetPeriodId': budgetPeriodId,
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency.name.toUpperCase(),
      if (description != null) 'description': description,
      if (date != null) 'date': date.toIso8601String(),
    });

    final response = await _apiService.put(
      '/api/v1/expenses/$expenseId',
      body: body,
    );
    return _apiService.parseDataResponse(response, ExpenseModel.fromJson);
  }

  /// Delete an expense
  Future<void> deleteExpense(String expenseId) async {
    await _apiService.delete('/api/v1/expenses/$expenseId');
  }

  /// Get expense totals by category for a date range
  Future<Map<String, double>> getExpenseTotalsByCategory({
    DateTime? startDate,
    DateTime? endDate,
    Currency? currency,
  }) async {
    final queryParams = <String>[];
    if (startDate != null)
      queryParams.add('startDate=${startDate.toIso8601String()}');
    if (endDate != null)
      queryParams.add('endDate=${endDate.toIso8601String()}');
    if (currency != null)
      queryParams.add('currency=${currency.name.toUpperCase()}');

    final queryString = queryParams.isNotEmpty
        ? '?${queryParams.join('&')}'
        : '';
    final response = await _apiService.get(
      '/api/v1/expenses/totals/category$queryString',
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

  /// Get expense totals by credit card
  Future<Map<String, double>> getExpenseTotalsByCreditCard({
    DateTime? startDate,
    DateTime? endDate,
    Currency? currency,
  }) async {
    final queryParams = <String>[];
    if (startDate != null)
      queryParams.add('startDate=${startDate.toIso8601String()}');
    if (endDate != null)
      queryParams.add('endDate=${endDate.toIso8601String()}');
    if (currency != null)
      queryParams.add('currency=${currency.name.toUpperCase()}');

    final queryString = queryParams.isNotEmpty
        ? '?${queryParams.join('&')}'
        : '';
    final response = await _apiService.get(
      '/api/v1/expenses/totals/credit-card$queryString',
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

  /// Get expense summary for a period
  Future<Map<String, dynamic>> getExpenseSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String>[];
    if (startDate != null)
      queryParams.add('startDate=${startDate.toIso8601String()}');
    if (endDate != null)
      queryParams.add('endDate=${endDate.toIso8601String()}');

    final queryString = queryParams.isNotEmpty
        ? '?${queryParams.join('&')}'
        : '';
    final response = await _apiService.get(
      '/api/v1/expenses/summary$queryString',
    );
    return _apiService.parseResponse(response);
  }

  /// Bulk create expenses
  Future<List<ExpenseModel>> createBulkExpenses(
    List<Map<String, dynamic>> expenses,
  ) async {
    final body = jsonEncode({'expenses': expenses});
    final response = await _apiService.post(
      '/api/v1/expenses/bulk',
      body: body,
    );
    return _apiService.parseListResponse(response, ExpenseModel.fromJson);
  }

  /// Search expenses by description
  Future<List<ExpenseModel>> searchExpenses({
    required String query,
    int? limit,
    int? offset,
  }) async {
    final queryParams = ['q=$query'];
    if (limit != null) queryParams.add('limit=$limit');
    if (offset != null) queryParams.add('offset=$offset');

    final queryString = '?${queryParams.join('&')}';
    final response = await _apiService.get(
      '/api/v1/expenses/search$queryString',
    );
    return _apiService.parseListResponse(response, ExpenseModel.fromJson);
  }
}
