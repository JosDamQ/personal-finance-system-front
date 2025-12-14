import '../../core/enums/app_enums.dart';
import 'api_service.dart';

/// API service for dashboard-related operations
class DashboardApiService {
  static final DashboardApiService _instance = DashboardApiService._internal();
  factory DashboardApiService() => _instance;
  DashboardApiService._internal();

  final ApiService _apiService = ApiService();

  /// Get general dashboard summary
  Future<Map<String, dynamic>> getSummary({
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
      '/api/v1/dashboard/summary$queryString',
    );
    return _apiService.parseResponse(response);
  }

  /// Get metrics for a specific period
  Future<Map<String, dynamic>> getMetrics(String period) async {
    final response = await _apiService.get('/api/v1/dashboard/metrics/$period');
    return _apiService.parseResponse(response);
  }

  /// Get chart data by type
  Future<Map<String, dynamic>> getChartData(
    String chartType, {
    DateTime? startDate,
    DateTime? endDate,
    String? groupBy,
  }) async {
    final queryParams = <String>[];
    if (startDate != null)
      queryParams.add('startDate=${startDate.toIso8601String()}');
    if (endDate != null)
      queryParams.add('endDate=${endDate.toIso8601String()}');
    if (groupBy != null) queryParams.add('groupBy=$groupBy');

    final queryString = queryParams.isNotEmpty
        ? '?${queryParams.join('&')}'
        : '';
    final response = await _apiService.get(
      '/api/v1/dashboard/charts/$chartType$queryString',
    );
    return _apiService.parseResponse(response);
  }

  /// Get monthly overview
  Future<Map<String, dynamic>> getMonthlyOverview({
    int? month,
    int? year,
  }) async {
    final now = DateTime.now();
    final targetMonth = month ?? now.month;
    final targetYear = year ?? now.year;

    final response = await _apiService.get(
      '/api/v1/dashboard/monthly?month=$targetMonth&year=$targetYear',
    );
    return _apiService.parseResponse(response);
  }

  /// Get spending trends
  Future<Map<String, dynamic>> getSpendingTrends({
    int? months = 6,
    Currency? currency,
  }) async {
    final queryParams = <String>[];
    if (months != null) queryParams.add('months=$months');
    if (currency != null)
      queryParams.add('currency=${currency.name.toUpperCase()}');

    final queryString = queryParams.isNotEmpty
        ? '?${queryParams.join('&')}'
        : '';
    final response = await _apiService.get(
      '/api/v1/dashboard/trends$queryString',
    );
    return _apiService.parseResponse(response);
  }

  /// Get budget vs actual comparison
  Future<Map<String, dynamic>> getBudgetComparison({
    int? month,
    int? year,
  }) async {
    final now = DateTime.now();
    final targetMonth = month ?? now.month;
    final targetYear = year ?? now.year;

    final response = await _apiService.get(
      '/api/v1/dashboard/budget-comparison?month=$targetMonth&year=$targetYear',
    );
    return _apiService.parseResponse(response);
  }

  /// Get credit card utilization overview
  Future<Map<String, dynamic>> getCreditCardUtilization() async {
    final response = await _apiService.get(
      '/api/v1/dashboard/credit-utilization',
    );
    return _apiService.parseResponse(response);
  }

  /// Get top spending categories
  Future<Map<String, dynamic>> getTopCategories({
    DateTime? startDate,
    DateTime? endDate,
    int? limit = 5,
  }) async {
    final queryParams = <String>[];
    if (startDate != null)
      queryParams.add('startDate=${startDate.toIso8601String()}');
    if (endDate != null)
      queryParams.add('endDate=${endDate.toIso8601String()}');
    if (limit != null) queryParams.add('limit=$limit');

    final queryString = queryParams.isNotEmpty
        ? '?${queryParams.join('&')}'
        : '';
    final response = await _apiService.get(
      '/api/v1/dashboard/top-categories$queryString',
    );
    return _apiService.parseResponse(response);
  }

  /// Get recent transactions
  Future<Map<String, dynamic>> getRecentTransactions({int? limit = 10}) async {
    final queryParams = <String>[];
    if (limit != null) queryParams.add('limit=$limit');

    final queryString = queryParams.isNotEmpty
        ? '?${queryParams.join('&')}'
        : '';
    final response = await _apiService.get(
      '/api/v1/dashboard/recent-transactions$queryString',
    );
    return _apiService.parseResponse(response);
  }

  /// Get financial health score
  Future<Map<String, dynamic>> getFinancialHealthScore() async {
    final response = await _apiService.get('/api/v1/dashboard/health-score');
    return _apiService.parseResponse(response);
  }

  /// Get expense breakdown by category
  Future<Map<String, dynamic>> getExpenseBreakdown({
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
      '/api/v1/dashboard/expense-breakdown$queryString',
    );
    return _apiService.parseResponse(response);
  }

  /// Get savings analysis
  Future<Map<String, dynamic>> getSavingsAnalysis({int? months = 12}) async {
    final queryParams = <String>[];
    if (months != null) queryParams.add('months=$months');

    final queryString = queryParams.isNotEmpty
        ? '?${queryParams.join('&')}'
        : '';
    final response = await _apiService.get(
      '/api/v1/dashboard/savings$queryString',
    );
    return _apiService.parseResponse(response);
  }

  /// Get alerts summary for dashboard
  Future<Map<String, dynamic>> getAlertsSummary() async {
    final response = await _apiService.get('/api/v1/dashboard/alerts');
    return _apiService.parseResponse(response);
  }

  /// Get quick stats (for widgets)
  Future<Map<String, dynamic>> getQuickStats() async {
    final response = await _apiService.get('/api/v1/dashboard/quick-stats');
    return _apiService.parseResponse(response);
  }
}
