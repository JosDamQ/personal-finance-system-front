// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_card_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreditCardModel _$CreditCardModelFromJson(Map<String, dynamic> json) =>
    CreditCardModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      bank: json['bank'] as String,
      limitGTQ: (json['limitGTQ'] as num).toDouble(),
      limitUSD: (json['limitUSD'] as num).toDouble(),
      currentBalanceGTQ: (json['currentBalanceGTQ'] as num).toDouble(),
      currentBalanceUSD: (json['currentBalanceUSD'] as num).toDouble(),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      syncStatus: $enumDecodeNullable(_$SyncStatusEnumMap, json['syncStatus']),
      lastSyncAt: json['lastSyncAt'] == null
          ? null
          : DateTime.parse(json['lastSyncAt'] as String),
    );

Map<String, dynamic> _$CreditCardModelToJson(CreditCardModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'bank': instance.bank,
      'limitGTQ': instance.limitGTQ,
      'limitUSD': instance.limitUSD,
      'currentBalanceGTQ': instance.currentBalanceGTQ,
      'currentBalanceUSD': instance.currentBalanceUSD,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'syncStatus': _$SyncStatusEnumMap[instance.syncStatus],
      'lastSyncAt': instance.lastSyncAt?.toIso8601String(),
    };

const _$SyncStatusEnumMap = {
  SyncStatus.synced: 'synced',
  SyncStatus.pending: 'pending',
  SyncStatus.conflict: 'conflict',
  SyncStatus.error: 'error',
};
