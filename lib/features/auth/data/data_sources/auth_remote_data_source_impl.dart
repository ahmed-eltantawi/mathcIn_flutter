import 'package:MatchIn/core/errors/error_model.dart';
import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/networking/api_consumer.dart';
import 'package:MatchIn/core/networking/api_end_points.dart';
import 'package:MatchIn/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:MatchIn/features/auth/data/models/login_model.dart';

class AuthRemoteDataSourceImpl
    implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({
    required this.apiConsumer,
  });

  final ApiConsumer apiConsumer;

  @override
  Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    await apiConsumer.post(
      EndPoint.verifyEmailOtp,
      data: {ApiKey.email: email, ApiKey.otp: otp},
    );
  }

  @override
  Future<void> resendOtp({required String email}) async {
    await apiConsumer.post(
      EndPoint.resendEmailOtp,
      data: {ApiKey.email: email},
    );
  }

  @override
  Future<void> forgotPassword({
    required String email,
  }) async {
    await apiConsumer.post(
      EndPoint.forgotPassword,
      data: {ApiKey.email: email},
    );
  }

  @override
  Future<void> verifyPasswordResetOtp({
    required String email,
    required String otp,
  }) async {
    await apiConsumer.post(
      EndPoint.verifyPasswordResetOtp,
      data: {ApiKey.email: email, ApiKey.otp: otp},
    );
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    await apiConsumer.post(
      EndPoint.resetPassword,
      data: {
        ApiKey.email: email,
        ApiKey.newPassword: newPassword,
      },
    );
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    await apiConsumer.post(
      EndPoint.register,
      data: {
        ApiKey.name: name,
        ApiKey.email: email,
        ApiKey.password: password,
        ApiKey.passwordConfirmation: passwordConfirmation,
      },
    );
  }

  @override
  Future<LoginModel> login({
    required String email,
    required String password,
  }) async {
    final response = await apiConsumer.post(
      EndPoint.login,
      data: {
        ApiKey.email: email,
        ApiKey.password: password,
      },
    );
    // هنا السيرفر رد علينا، فبناخد الرد (response) وندخله جوه المودل عشان يتحول لمتغيرات نقدر نستخدمها
    return LoginModel.fromJson(response);
  }

  @override
  Future<LoginModel> loginWithGoogle({
    required String idToken,
  }) async {
    // --- No invented endpoint: the backend exposes no Google/social login
    // --- route (see EndPoint + docs/API_DOCUMENTATION.md), so there is
    // --- nothing truthful to call. Fail explicitly instead of faking auth.
    throw ServerException(
      errorModel: const ErrorModel(
        statusCode: 501,
        errorMessage: 'Google sign-in is not supported by the backend yet. Missing endpoint: a server route exchanging the Google ID token for app tokens.',
      ),
    );
  }
}
