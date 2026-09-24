import 'package:MatchIn/features/auth/data/models/login_model.dart';
abstract class AuthRemoteDataSource {
  Future<void> verifyOtp({required String email, required String otp});

  Future<void> resendOtp({required String email});

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  });

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  Future<LoginModel> login({
    required String email,
    required String password,
  });
}
