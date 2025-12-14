import 'dart:convert';
import 'dart:typed_data';
import '../../core/enums/app_enums.dart';
import 'api_service.dart';

/// API service for report and export-related operations
class ReportApiService {
  static final ReportApiService _instance = ReportApiService._internal();
  factory ReportApiService() => _instance;
  ReportApiService._internal();

  final ApiService _apiService = ApiService();

  /// Export budget as PDF
  Future<Uint8List> exportBudgetToPdf(
    String budgetId, {
    bool? includeCharts,
    String? format,
  }) async {
    final body = jsonEncode({
      if (includeCharts != null) 'includeCharts': includeCharts,
      if (format != null) 'format': format,
    });

    final response = await _apiService.post(
      '/api/v1/reports/budget/$budgetId/pdf',
      body: body,
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to export budget PDF',
        details: {'budgetId': budgetId},
      );
    }
  }

  /// Export expenses to Excel
  Future<Uint8List> exportExpensesToExcel({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? creditCardId,
    Currency? currency,
    List<String>? columns,
  }) async {
    final body = jsonEncode({
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
      if (categoryId != null) 'categoryId': categoryId,
      if (creditCardId != null) 'creditCardId': creditCardId,
      if (currency != null) 'currency': currency.name.toUpperCase(),
      if (columns != null) 'columns': columns,
    });

    final response = await _apiService.post(
      '/api/v1/reports/expenses/excel',
      body: body,
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to export expenses Excel',
        details: {'filters': body},
      );
    }
  }

  /// Create complete data backup
  Future<Uint8List> createBackup({
    bool? includeDeleted,
    String? format = 'json',
  }) async {
    final body = jsonEncode({
      if (includeDeleted != null) 'includeDeleted': includeDeleted,
      'format': format,
    });

    final response = await _apiService.post(
      '/api/v1/reports/backup',
      body: body,
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to create backup',
        details: {'format': format},
      );
    }
  }

  /// Generate monthly report
  Future<Map<String, dynamic>> generateMonthlyReport({
    required int month,
    required int year,
    String? format = 'summary',
  }) async {
    final body = jsonEncode({'month': month, 'year': year, 'format': format});

    final response = await _apiService.post(
      '/api/v1/reports/monthly',
      body: body,
    );
    return _apiService.parseResponse(response);
  }

  /// Generate annual report
  Future<Map<String, dynamic>> generateAnnualReport({
    required int year,
    String? format = 'summary',
  }) async {
    final body = jsonEncode({'year': year, 'format': format});

    final response = await _apiService.post(
      '/api/v1/reports/annual',
      body: body,
    );
    return _apiService.parseResponse(response);
  }

  /// Export credit card statement
  Future<Uint8List> exportCreditCardStatement(
    String creditCardId, {
    DateTime? startDate,
    DateTime? endDate,
    String? format = 'pdf',
  }) async {
    final body = jsonEncode({
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
      'format': format,
    });

    final response = await _apiService.post(
      '/api/v1/reports/credit-card/$creditCardId/statement',
      body: body,
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to export credit card statement',
        details: {'creditCardId': creditCardId},
      );
    }
  }

  /// Generate category analysis report
  Future<Map<String, dynamic>> generateCategoryAnalysis({
    DateTime? startDate,
    DateTime? endDate,
    List<String>? categoryIds,
  }) async {
    final body = jsonEncode({
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
      if (categoryIds != null) 'categoryIds': categoryIds,
    });

    final response = await _apiService.post(
      '/api/v1/reports/category-analysis',
      body: body,
    );
    return _apiService.parseResponse(response);
  }

  /// Generate spending trends report
  Future<Map<String, dynamic>> generateSpendingTrends({
    int? months = 12,
    Currency? currency,
    String? groupBy = 'month',
  }) async {
    final body = jsonEncode({
      'months': months,
      if (currency != null) 'currency': currency.name.toUpperCase(),
      'groupBy': groupBy,
    });

    final response = await _apiService.post(
      '/api/v1/reports/spending-trends',
      body: body,
    );
    return _apiService.parseResponse(response);
  }

  /// Export budget comparison report
  Future<Uint8List> exportBudgetComparison({
    required List<String> budgetIds,
    String? format = 'pdf',
  }) async {
    final body = jsonEncode({'budgetIds': budgetIds, 'format': format});

    final response = await _apiService.post(
      '/api/v1/reports/budget-comparison',
      body: body,
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to export budget comparison',
        details: {'budgetIds': budgetIds},
      );
    }
  }

  /// Get available report templates
  Future<List<Map<String, dynamic>>> getReportTemplates() async {
    final response = await _apiService.get('/api/v1/reports/templates');
    final data = _apiService.parseResponse(response);
    return List<Map<String, dynamic>>.from(data['data']);
  }

  /// Generate custom report from template
  Future<Map<String, dynamic>> generateCustomReport({
    required String templateId,
    required Map<String, dynamic> parameters,
  }) async {
    final body = jsonEncode({
      'templateId': templateId,
      'parameters': parameters,
    });

    final response = await _apiService.post(
      '/api/v1/reports/custom',
      body: body,
    );
    return _apiService.parseResponse(response);
  }

  /// Get report generation status
  Future<Map<String, dynamic>> getReportStatus(String reportId) async {
    final response = await _apiService.get('/api/v1/reports/status/$reportId');
    return _apiService.parseResponse(response);
  }

  /// Download generated report
  Future<Uint8List> downloadReport(String reportId) async {
    final response = await _apiService.get(
      '/api/v1/reports/download/$reportId',
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to download report',
        details: {'reportId': reportId},
      );
    }
  }
}
