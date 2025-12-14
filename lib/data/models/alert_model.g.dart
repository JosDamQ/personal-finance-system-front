// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlertModel _$AlertModelFromJson(Map<String, dynamic> json) => AlertModel(
  id: json['id'] as String,
  userId: json['userId'] as String,
  type: $enumDecode(_$AlertTypeEnumMap, json['type']),
  title: json['title'] as String,
  message: json['message'] as String,
  isRead: json['isRead'] as bool,
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$AlertModelToJson(AlertModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': _$AlertTypeEnumMap[instance.type]!,
      'title': instance.title,
      'message': instance.message,
      'isRead': instance.isRead,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$AlertTypeEnumMap = {
  AlertType.creditLimitWarning: 'creditLimitWarning',
  AlertType.budgetExceeded: 'budgetExceeded',
  AlertType.paymentReminder: 'paymentReminder',
  AlertType.monthlySummary: 'monthlySummary',
};
