// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpenseModel _$ExpenseModelFromJson(Map<String, dynamic> json) => ExpenseModel(
  id: json['id'] as String,
  userId: json['userId'] as String,
  categoryId: json['categoryId'] as String,
  creditCardId: json['creditCardId'] as String?,
  budgetPeriodId: json['budgetPeriodId'] as String?,
  amount: (json['amount'] as num).toDouble(),
  currency: $enumDecode(_$CurrencyEnumMap, json['currency']),
  description: json['description'] as String,
  date: DateTime.parse(json['date'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  syncStatus: $enumDecodeNullable(_$SyncStatusEnumMap, json['syncStatus']),
  lastSyncAt: json['lastSyncAt'] == null
      ? null
      : DateTime.parse(json['lastSyncAt'] as String),
);

Map<String, dynamic> _$ExpenseModelToJson(ExpenseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'categoryId': instance.categoryId,
      'creditCardId': instance.creditCardId,
      'budgetPeriodId': instance.budgetPeriodId,
      'amount': instance.amount,
      'currency': _$CurrencyEnumMap[instance.currency]!,
      'description': instance.description,
      'date': instance.date.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'syncStatus': _$SyncStatusEnumMap[instance.syncStatus],
      'lastSyncAt': instance.lastSyncAt?.toIso8601String(),
    };

const _$CurrencyEnumMap = {Currency.gtq: 'gtq', Currency.usd: 'usd'};

const _$SyncStatusEnumMap = {
  SyncStatus.synced: 'synced',
  SyncStatus.pending: 'pending',
  SyncStatus.conflict: 'conflict',
  SyncStatus.error: 'error',
};
