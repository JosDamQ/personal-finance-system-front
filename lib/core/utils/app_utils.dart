import 'package:intl/intl.dart';
import '../enums/app_enums.dart';

class AppUtils {
  // Date formatting
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
  
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }
  
  static String formatMonth(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }
  
  // Currency formatting
  static String formatCurrency(double amount, Currency currency) {
    final formatter = NumberFormat.currency(
      symbol: currency == Currency.gtq ? 'Q' : '\$',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
  
  // Validation helpers
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  static bool isValidAmount(String amount) {
    final parsed = double.tryParse(amount);
    return parsed != null && parsed > 0;
  }
  
  static bool isValidPhoneNumber(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)]{8,15}$').hasMatch(phone);
  }
  
  // String helpers
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
  
  // Color helpers
  static String colorToHex(int color) {
    return '#${color.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
  
  static int hexToColor(String hex) {
    return int.parse(hex.replaceFirst('#', ''), radix: 16) + 0xFF000000;
  }
  
  // Calculation helpers
  static double calculatePercentage(double value, double total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }
  
  static double roundToTwoDecimals(double value) {
    return double.parse(value.toStringAsFixed(2));
  }
}