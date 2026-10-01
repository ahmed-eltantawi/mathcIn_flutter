import 'package:MatchIn/features/auth/domain/entities/user_entity.dart';

/// Domain entity returned by POST /api/auth/login.
/// Contains the JWT tokens and the full authenticated user profile.
class LoginEntity {
  const LoginEntity({
    required this.message,
    required this.accessToken,
    required this.refreshToken,
    this.user,
  });

  final String message;
  final String accessToken;
  final String refreshToken;

  /// The full user profile returned alongside the tokens.
  /// Nullable so that future endpoint changes don't break parsing.
  final UserEntity? user;
}
