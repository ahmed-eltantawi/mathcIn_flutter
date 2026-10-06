class LoginModel {
  LoginModel({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      expiresIn: json['expires_in'],
    );
  }

  final String accessToken;
  final String tokenType;
  final int? expiresIn;
}
