import 'package:MatchIn/core/networking/api_end_points.dart';

class LoginModel {
  LoginModel({
    required this.accessToken,
    required this.tokenType,
    this.refreshToken,
    this.expiresIn,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      accessToken: json[ApiKey.accessToken] as String,
      tokenType: json[ApiKey.tokenType] as String? ?? 'Bearer',
      refreshToken: json[ApiKey.refreshToken] as String?,
      expiresIn: json['expires_in'] as int?,
    );
  }

  final String accessToken;
  final String tokenType;
  final String? refreshToken;
  final int? expiresIn;
}
