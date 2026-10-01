import 'package:MatchIn/core/networking/api_end_points.dart';
import 'package:MatchIn/features/auth/data/models/user_model.dart';
import 'package:MatchIn/features/auth/domain/entities/login_entity.dart';

/// Data model for POST /api/auth/login response.
/// Parses tokens AND the nested user object from the API payload.
class LoginModel extends LoginEntity {
  const LoginModel({
    required super.message,
    required super.accessToken,
    required super.refreshToken,
    super.user,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    // --- Parse the nested user object from the response body ---
    final userData = json[ApiKey.user];
    final userModel =
        userData is Map<String, dynamic> ? UserModel.fromJson(userData) : null;

    return LoginModel(
      message: json[ApiKey.errorMessage] as String? ?? '',
      accessToken: json[ApiKey.accessToken] as String? ?? '',
      refreshToken: json[ApiKey.refreshToken] as String? ?? '',
      user: userModel,
    );
  }
}
