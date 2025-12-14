import 'dart:convert';
import '../models/credit_card_model.dart';
import '../models/expense_model.dart';
import 'api_service.dart';

/// API service for credit card-related operations
class CreditCardApiService {
  static final CreditCardApiService _instance =
      CreditCardApiService._internal();
  factory CreditCardApiService() => _instance;
  CreditCardApiService._internal();

  final ApiService _apiService = ApiService();

  /// Get all credit cards for the current user
  Future<List<CreditCardModel>> getCreditCards() async {
    final response = await _apiService.get('/api/v1/credit-cards');
    return _apiService.parseListResponse(response, CreditCardModel.fromJson);
  }

  /// Get a specific credit card by ID
  Future<CreditCardModel> getCreditCard(String creditCardId) async {
    final response = await _apiService.get(
      '/api/v1/credit-cards/$creditCardId',
    );
    return _apiService.parseDataResponse(response, CreditCardModel.fromJson);
  }

  /// Create a new credit card
  Future<CreditCardModel> createCreditCard({
    required String name,
    required String bank,
    required double limitGTQ,
    required double limitUSD,
    double? currentBalanceGTQ,
    double? currentBalanceUSD,
    bool? isActive,
  }) async {
    final body = jsonEncode({
      'name': name,
      'bank': bank,
      'limitGTQ': limitGTQ,
      'limitUSD': limitUSD,
      'currentBalanceGTQ': currentBalanceGTQ ?? 0.0,
      'currentBalanceUSD': currentBalanceUSD ?? 0.0,
      'isActive': isActive ?? true,
    });

    final response = await _apiService.post('/api/v1/credit-cards', body: body);
    return _apiService.parseDataResponse(response, CreditCardModel.fromJson);
  }

  /// Update an existing credit card
  Future<CreditCardModel> updateCreditCard(
    String creditCardId, {
    String? name,
    String? bank,
    double? limitGTQ,
    double? limitUSD,
    double? currentBalanceGTQ,
    double? currentBalanceUSD,
    bool? isActive,
  }) async {
    final body = jsonEncode({
      if (name != null) 'name': name,
      if (bank != null) 'bank': bank,
      if (limitGTQ != null) 'limitGTQ': limitGTQ,
      if (limitUSD != null) 'limitUSD': limitUSD,
      if (currentBalanceGTQ != null) 'currentBalanceGTQ': currentBalanceGTQ,
      if (currentBalanceUSD != null) 'currentBalanceUSD': currentBalanceUSD,
      if (isActive != null) 'isActive': isActive,
    });

    final response = await _apiService.put(
      '/api/v1/credit-cards/$creditCardId',
      body: body,
    );
    return _apiService.parseDataResponse(response, CreditCardModel.fromJson);
  }

  /// Delete a credit card
  Future<void> deleteCreditCard(String creditCardId) async {
    await _apiService.delete('/api/v1/credit-cards/$creditCardId');
  }

  /// Get transaction history for a credit card
  Future<List<ExpenseModel>> getCreditCardTransactions(
    String creditCardId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String>[];
    if (startDate != null) {
      queryParams.add('startDate=${startDate.toIso8601String()}');
    }
    if (endDate != null) {
      queryParams.add('endDate=${endDate.toIso8601String()}');
    }
    if (limit != null) {
      queryParams.add('limit=$limit');
    }
    if (offset != null) {
      queryParams.add('offset=$offset');
    }

    final queryString = queryParams.isNotEmpty
        ? '?${queryParams.join('&')}'
        : '';
    final response = await _apiService.get(
      '/api/v1/credit-cards/$creditCardId/transactions$queryString',
    );
    return _apiService.parseListResponse(response, ExpenseModel.fromJson);
  }

  /// Get credit card usage summary
  Future<Map<String, dynamic>> getCreditCardSummary(String creditCardId) async {
    final response = await _apiService.get(
      '/api/v1/credit-cards/$creditCardId/summary',
    );
    return _apiService.parseResponse(response);
  }

  /// Update credit card balance manually
  Future<CreditCardModel> updateBalance(
    String creditCardId, {
    required double balanceGTQ,
    required double balanceUSD,
  }) async {
    final body = jsonEncode({
      'currentBalanceGTQ': balanceGTQ,
      'currentBalanceUSD': balanceUSD,
    });

    final response = await _apiService.put(
      '/api/v1/credit-cards/$creditCardId/balance',
      body: body,
    );
    return _apiService.parseDataResponse(response, CreditCardModel.fromJson);
  }

  /// Get credit cards with usage alerts (80% limit reached)
  Future<List<CreditCardModel>> getCreditCardsWithAlerts() async {
    final response = await _apiService.get('/api/v1/credit-cards?alerts=true');
    return _apiService.parseListResponse(response, CreditCardModel.fromJson);
  }
}
