import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import '../../core/enums/app_enums.dart';

part 'budget_model.g.dart';

@JsonSerializable()
class BudgetModel extends Equatable {
  final String id;
  final String userId;
  final int month;
  final int year;
  final PaymentFrequency paymentFrequency;
  final double totalIncome;
  final List<BudgetPeriodModel> periods;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SyncStatus? syncStatus;
  final DateTime? lastSyncAt;

  const BudgetModel({
    required this.id,
    required this.userId,
    required this.month,
    required this.year,
    required this.paymentFrequency,
    required this.totalIncome,
    required this.periods,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus,
    this.lastSyncAt,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) => _$BudgetModelFromJson(json);
  Map<String, dynamic> toJson() => _$BudgetModelToJson(this);

  BudgetModel copyWith({
    String? id,
    String? userId,
    int? month,
    int? year,
    PaymentFrequency? paymentFrequency,
    double? totalIncome,
    List<BudgetPeriodModel>? periods,
    DateTime? createdAt,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
    DateTime? lastSyncAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      month: month ?? this.month,
      year: year ?? this.year,
      paymentFrequency: paymentFrequency ?? this.paymentFrequency,
      totalIncome: totalIncome ?? this.totalIncome,
      periods: periods ?? this.periods,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        month,
        year,
        paymentFrequency,
        totalIncome,
        periods,
        createdAt,
        updatedAt,
        syncStatus,
        lastSyncAt,
      ];
}

@JsonSerializable()
class BudgetPeriodModel extends Equatable {
  final String id;
  final String budgetId;
  final int periodNumber;
  final double income;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BudgetPeriodModel({
    required this.id,
    required this.budgetId,
    required this.periodNumber,
    required this.income,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BudgetPeriodModel.fromJson(Map<String, dynamic> json) => _$BudgetPeriodModelFromJson(json);
  Map<String, dynamic> toJson() => _$BudgetPeriodModelToJson(this);

  BudgetPeriodModel copyWith({
    String? id,
    String? budgetId,
    int? periodNumber,
    double? income,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetPeriodModel(
      id: id ?? this.id,
      budgetId: budgetId ?? this.budgetId,
      periodNumber: periodNumber ?? this.periodNumber,
      income: income ?? this.income,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        budgetId,
        periodNumber,
        income,
        createdAt,
        updatedAt,
      ];
}