// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_queue_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncQueueModel _$SyncQueueModelFromJson(Map<String, dynamic> json) =>
    SyncQueueModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      operation: $enumDecode(_$SyncOperationEnumMap, json['operation']),
      entityType: $enumDecode(_$EntityTypeEnumMap, json['entityType']),
      entityId: json['entityId'] as String,
      data: json['data'] as Map<String, dynamic>,
      retryCount: (json['retryCount'] as num).toInt(),
      maxRetries: (json['maxRetries'] as num).toInt(),
      status: $enumDecode(_$SyncQueueStatusEnumMap, json['status']),
      errorMessage: json['errorMessage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SyncQueueModelToJson(SyncQueueModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'operation': _$SyncOperationEnumMap[instance.operation]!,
      'entityType': _$EntityTypeEnumMap[instance.entityType]!,
      'entityId': instance.entityId,
      'data': instance.data,
      'retryCount': instance.retryCount,
      'maxRetries': instance.maxRetries,
      'status': _$SyncQueueStatusEnumMap[instance.status]!,
      'errorMessage': instance.errorMessage,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$SyncOperationEnumMap = {
  SyncOperation.create: 'create',
  SyncOperation.update: 'update',
  SyncOperation.delete: 'delete',
};

const _$EntityTypeEnumMap = {
  EntityType.budget: 'budget',
  EntityType.expense: 'expense',
  EntityType.creditCard: 'creditCard',
  EntityType.category: 'category',
  EntityType.budgetPeriod: 'budgetPeriod',
};

const _$SyncQueueStatusEnumMap = {
  SyncQueueStatus.pending: 'pending',
  SyncQueueStatus.processing: 'processing',
  SyncQueueStatus.completed: 'completed',
  SyncQueueStatus.failed: 'failed',
};
