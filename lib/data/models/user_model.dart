import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String? oauthProvider;
  final String? oauthId;
  final String defaultCurrency;
  final String theme;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.oauthProvider,
    this.oauthId,
    required this.defaultCurrency,
    required this.theme,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle backend auth response format (minimal user data)
    if (json.containsKey('id') &&
        json.containsKey('email') &&
        !json.containsKey('defaultCurrency')) {
      return UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String?,
        phone: null,
        oauthProvider: null,
        oauthId: null,
        defaultCurrency: 'GTQ', // Default value
        theme: 'light', // Default value
        createdAt: DateTime.now(), // Default value
        updatedAt: DateTime.now(), // Default value
      );
    }
    // Handle full user data format
    return _$UserModelFromJson(json);
  }
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? oauthProvider,
    String? oauthId,
    String? defaultCurrency,
    String? theme,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      oauthProvider: oauthProvider ?? this.oauthProvider,
      oauthId: oauthId ?? this.oauthId,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      theme: theme ?? this.theme,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    phone,
    oauthProvider,
    oauthId,
    defaultCurrency,
    theme,
    createdAt,
    updatedAt,
  ];
}
