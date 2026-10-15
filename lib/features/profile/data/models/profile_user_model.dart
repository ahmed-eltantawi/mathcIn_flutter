import 'package:MatchIn/features/profile/data/models/json_parsing.dart';
import 'package:MatchIn/features/profile/domain/entities/profile_user_entity.dart';

class ProfileUserModel extends ProfileUserEntity {
  const ProfileUserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.isActive,
    super.phone,
    super.avatar,
  });

  factory ProfileUserModel.fromJson(Map<String, dynamic> json) {
    return ProfileUserModel(
      id: JsonParsing.parseId(json['id']) ?? 0,
      name: JsonParsing.parseString(json['name']) ?? '',
      email: JsonParsing.parseString(json['email']) ?? '',
      role: JsonParsing.parseString(json['role']) ?? 'candidate',
      isActive: JsonParsing.parseBoolFlag(json['is_active']) ?? true,
      phone: JsonParsing.parseString(json['phone']),
      avatar: JsonParsing.parseString(json['avatar']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'is_active': isActive,
      'phone': phone,
      'avatar': avatar,
    };
  }
}
