import 'package:MatchIn/features/auth/domain/entities/login_entity.dart';

abstract interface class AuthRemoteDataSource {
  Future<LoginEntity> login({required String email, required String password});

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  Future<void> verifyOtp({required String email, required String otp});

  Future<void> resendOtp({required String email});

  // فلو تغيير الباسورد الجديد
  Future<void> forgotPassword({required String email});

  Future<String> verifyPasswordResetOtp({
    required String email,
    required String otp,
  });

  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String password,
    required String passwordConfirmation,
  });
}
