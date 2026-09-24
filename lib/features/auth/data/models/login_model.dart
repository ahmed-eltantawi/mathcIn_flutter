class LoginModel {
  LoginModel({required this.accessToken, required this.tokenType});

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
    );
  }

  final String accessToken;
  final String tokenType;
}