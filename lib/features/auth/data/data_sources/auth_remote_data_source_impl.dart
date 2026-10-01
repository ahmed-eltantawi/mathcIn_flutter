import 'package:MatchIn/core/networking/api_consumer.dart';
import 'package:MatchIn/core/networking/api_end_points.dart';
import 'package:MatchIn/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:MatchIn/features/auth/data/models/login_model.dart';
import 'package:MatchIn/features/auth/domain/entities/login_entity.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  @override
  Future<LoginEntity> login({
    required String email,
    required String password,
  }) async {
    final response = await apiConsumer.post(
      EndPoint.login,
      data: {ApiKey.email: email, ApiKey.password: password},
    );
    return LoginModel.fromJson(response);
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
  Future<void> verifyOtp({required String email, required String otp}) async {
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
  Future<void> forgotPassword({required String email}) async {
    await apiConsumer.post(
      EndPoint.forgotPassword,
      data: {ApiKey.email: email},
    );
  }

  @override
  Future<String> verifyPasswordResetOtp({
    required String email,
    required String otp,
  }) async {
    final response = await apiConsumer.post(
      EndPoint.verifyPasswordResetOtp,
      data: {ApiKey.email: email, ApiKey.otp: otp},
    );
    // السواجر بيقول انه هيرجع reset_token فناخده ونرجعه
    return response[ApiKey.resetToken] as String;
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String password,
    required String passwordConfirmation,
  }) async {
    await apiConsumer.post(
      EndPoint.resetPassword,
      data: {
        ApiKey.email: email,
        ApiKey.resetToken: resetToken,
        ApiKey.password: password,
        ApiKey.passwordConfirmation: passwordConfirmation,
      },
    );
  }
}
