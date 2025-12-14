enum PaymentFrequency {
  biweekly('BIWEEKLY'),
  monthly('MONTHLY');

  const PaymentFrequency(this.value);
  final String value;
}

enum Currency {
  gtq('GTQ'),
  usd('USD');

  const Currency(this.value);
  final String value;
}

enum AlertType {
  creditLimitWarning('CREDIT_LIMIT_WARNING'),
  budgetExceeded('BUDGET_EXCEEDED'),
  paymentReminder('PAYMENT_REMINDER'),
  monthlySummary('MONTHLY_SUMMARY');

  const AlertType(this.value);
  final String value;
}

enum SyncStatus {
  synced('SYNCED'),
  pending('PENDING'),
  conflict('CONFLICT'),
  error('ERROR');

  const SyncStatus(this.value);
  final String value;
}

enum SyncOperation {
  create('CREATE'),
  update('UPDATE'),
  delete('DELETE');

  const SyncOperation(this.value);
  final String value;
}

enum EntityType {
  budget('BUDGET'),
  expense('EXPENSE'),
  creditCard('CREDIT_CARD'),
  category('CATEGORY'),
  budgetPeriod('BUDGET_PERIOD');

  const EntityType(this.value);
  final String value;
}

enum AppTheme {
  light('light'),
  dark('dark'),
  system('system');

  const AppTheme(this.value);
  final String value;
}

enum LoadingState {
  initial,
  loading,
  loaded,
  error;
}