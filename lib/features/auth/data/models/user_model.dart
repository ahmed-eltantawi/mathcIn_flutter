import 'dart:convert';

import 'package:MatchIn/core/networking/api_end_points.dart';
import 'package:MatchIn/features/auth/domain/entities/user_entity.dart';

/// Data model for the `user` object inside the login API response.
/// Adds [fromJson] / [toJson] for network parsing and local caching.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.isActive,
    super.avatar,
    super.phone,
  });

  //! ===== Deserialization =====

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json[ApiKey.id] as num?)?.toInt() ?? 0,
      name: json[ApiKey.name] as String? ?? '',
      email: json[ApiKey.email] as String? ?? '',
      role: json[ApiKey.role] as String? ?? '',
      isActive: json[ApiKey.isActive] as bool? ?? false,
      avatar: json[ApiKey.avatar] as String?,
      phone: json[ApiKey.phone] as String?,
    );
  }

  /// Parses a JSON string stored in SharedPreferences back to [UserModel].
  factory UserModel.fromJsonString(String jsonString) {
    return UserModel.fromJson(
      json.decode(jsonString) as Map<String, dynamic>,
    );
  }

  //! ===== Serialization =====

  Map<String, dynamic> toJson() {
    return {
      ApiKey.id: id,
      ApiKey.name: name,
      ApiKey.email: email,
      ApiKey.role: role,
      ApiKey.isActive: isActive,
      ApiKey.avatar: avatar,
      ApiKey.phone: phone,
    };
  }

  /// Encodes the model to a JSON string for caching in SharedPreferences.
  String toJsonString() => json.encode(toJson());
}
