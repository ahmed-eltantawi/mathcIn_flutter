import 'package:MatchIn/core/networking/api_consumer.dart';
import 'package:MatchIn/core/networking/api_end_points.dart';
import 'package:MatchIn/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:MatchIn/features/auth/data/models/login_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  @override
  Future<void> verifyOtp({required String email, required String otp}) async {
    await apiConsumer.post(
      EndPoint.verifyEmailOtp,
      data: {ApiKey.email: email, ApiKey.otp: otp},
    );
  }

  @override
  Future<void> resendOtp({required String email}) async {
    await apiConsumer.post(EndPoint.resendEmailOtp, data: {ApiKey.email: email});
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    await apiConsumer.post(
      EndPoint.resetPassword,
      data: {ApiKey.email: email, ApiKey.newPassword: newPassword},
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
}
