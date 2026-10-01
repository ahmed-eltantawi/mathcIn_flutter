import 'package:MatchIn/core/errors/error_model.dart';
import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:MatchIn/features/auth/domain/entities/login_entity.dart';
import 'package:MatchIn/features/auth/domain/entities/user_entity.dart';

///* AuthMockRemoteDataSourceImpl: simulates API responses locally for UI development.
///* Mirrors the full AuthRemoteDataSource contract without making real network calls.
class AuthMockRemoteDataSourceImpl implements AuthRemoteDataSource {
  //! ===== Auth =====

  @override
  Future<LoginEntity> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Simulate a bad-credential error for a test account
    if (password == 'wrong') {
      throw ServerException(
        errorModel: ErrorModel(
          statusCode: 401,
          errorMessage: 'Invalid email or password',
        ),
      );
    }
    return const LoginEntity(
      message: 'Authenticated successfully',
      accessToken: 'mock_access_token_abc123',
      refreshToken: 'mock_refresh_token_xyz789',
      user: UserEntity(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        role: 'user',
        isActive: true,
        avatar: null,
        phone: null,
      ),
    );
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Simulate conflict if email already exists
    if (email == 'taken@example.com') {
      throw ServerException(
        errorModel: ErrorModel(
          statusCode: 422,
          errorMessage: 'The email has already been taken',
        ),
      );
    }
  }

  //! ===== Email OTP =====

  @override
  Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (otp == '000000') {
      throw ServerException(
        errorModel: ErrorModel(
          statusCode: 400,
          errorMessage: 'Invalid or expired verification code',
        ),
      );
    }
  }

  @override
  Future<void> resendOtp({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  //! ===== Password Recovery =====

  @override
  Future<void> forgotPassword({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<String> verifyPasswordResetOtp({
    required String email,
    required String otp,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (otp == '000000') {
      throw ServerException(
        errorModel: ErrorModel(
          statusCode: 400,
          errorMessage: 'Invalid verification code',
        ),
      );
    }
    // Returns the 64-char reset_token as specified by the API contract
    return 'mock_reset_token_${email.hashCode.toRadixString(16).padLeft(16, '0')}';
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String password,
    required String passwordConfirmation,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (password.length < 8) {
      throw ServerException(
        errorModel: ErrorModel(
          statusCode: 400,
          errorMessage: 'Password must be at least 8 characters',
        ),
      );
    }
  }
}
