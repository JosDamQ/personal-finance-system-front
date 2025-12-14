// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String?,
  phone: json['phone'] as String?,
  oauthProvider: json['oauthProvider'] as String?,
  oauthId: json['oauthId'] as String?,
  defaultCurrency: json['defaultCurrency'] as String,
  theme: json['theme'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'phone': instance.phone,
  'oauthProvider': instance.oauthProvider,
  'oauthId': instance.oauthId,
  'defaultCurrency': instance.defaultCurrency,
  'theme': instance.theme,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
