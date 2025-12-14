// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BudgetModel _$BudgetModelFromJson(Map<String, dynamic> json) => BudgetModel(
  id: json['id'] as String,
  userId: json['userId'] as String,
  month: (json['month'] as num).toInt(),
  year: (json['year'] as num).toInt(),
  paymentFrequency: $enumDecode(
    _$PaymentFrequencyEnumMap,
    json['paymentFrequency'],
  ),
  totalIncome: (json['totalIncome'] as num).toDouble(),
  periods: (json['periods'] as List<dynamic>)
      .map((e) => BudgetPeriodModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  syncStatus: $enumDecodeNullable(_$SyncStatusEnumMap, json['syncStatus']),
  lastSyncAt: json['lastSyncAt'] == null
      ? null
      : DateTime.parse(json['lastSyncAt'] as String),
);

Map<String, dynamic> _$BudgetModelToJson(BudgetModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'month': instance.month,
      'year': instance.year,
      'paymentFrequency': _$PaymentFrequencyEnumMap[instance.paymentFrequency]!,
      'totalIncome': instance.totalIncome,
      'periods': instance.periods,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'syncStatus': _$SyncStatusEnumMap[instance.syncStatus],
      'lastSyncAt': instance.lastSyncAt?.toIso8601String(),
    };

const _$PaymentFrequencyEnumMap = {
  PaymentFrequency.biweekly: 'biweekly',
  PaymentFrequency.monthly: 'monthly',
};

const _$SyncStatusEnumMap = {
  SyncStatus.synced: 'synced',
  SyncStatus.pending: 'pending',
  SyncStatus.conflict: 'conflict',
  SyncStatus.error: 'error',
};

BudgetPeriodModel _$BudgetPeriodModelFromJson(Map<String, dynamic> json) =>
    BudgetPeriodModel(
      id: json['id'] as String,
      budgetId: json['budgetId'] as String,
      periodNumber: (json['periodNumber'] as num).toInt(),
      income: (json['income'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$BudgetPeriodModelToJson(BudgetPeriodModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'budgetId': instance.budgetId,
      'periodNumber': instance.periodNumber,
      'income': instance.income,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
