class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'candidate',
    );
  }

  final int id;
  final String name;
  final String email;
  final String role;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}

class LoginModel {
  const LoginModel({
    required this.accessToken,
    required this.tokenType,
    this.refreshToken,
    this.expiresIn,
    this.user,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    // If wrapped in 'data'
    final data = json.containsKey('data') && json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return LoginModel(
      accessToken: data['access_token'] as String? ?? '',
      tokenType: data['token_type'] as String? ?? 'bearer',
      refreshToken: data['refresh_token'] as String?,
      expiresIn: (data['expires_in'] as num?)?.toInt(),
      user: data['user'] is Map<String, dynamic>
          ? UserModel.fromJson(data['user'] as Map<String, dynamic>)
          : null,
    );
  }

  final String accessToken;
  final String tokenType;
  final String? refreshToken;
  final int? expiresIn;
  final UserModel? user;
}