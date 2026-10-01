import 'package:MatchIn/features/auth/domain/entities/user_entity.dart';

class AuthEntity {
  const AuthEntity({
    required this.accessToken,
    required this.message,
    required this.refreshToken,
    this.user,
  });

  final String message;
  final String accessToken;
  final String refreshToken;
  final UserEntity? user;
}
