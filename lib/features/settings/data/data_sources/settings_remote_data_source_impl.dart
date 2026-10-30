import 'package:MatchIn/core/errors/error_model.dart';
import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/networking/api_consumer.dart';
import 'package:MatchIn/core/networking/api_end_points.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:MatchIn/features/profile/data/models/user_profile_model.dart';
import 'package:MatchIn/features/settings/data/data_sources/settings_remote_data_source.dart';

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  const SettingsRemoteDataSourceImpl({
    required this.apiConsumer,
    this.profileLocalDataSource,
    this.sharedPreferencesService,
  });

  final ApiConsumer apiConsumer;
  final ProfileLocalDataSource? profileLocalDataSource;
  final SharedPreferencesService? sharedPreferencesService;

  Future<String> _resolveEmail() async {
    String email = '';
    try {
      final cached = await profileLocalDataSource?.getCachedUserProfile();
      if (cached != null && cached.email.isNotEmpty) {
        email = cached.email.trim();
      }
    } catch (_) {}

    if (email.isEmpty) {
      final savedEmail = sharedPreferencesService?.getUserEmail();
      if (savedEmail != null && savedEmail.trim().isNotEmpty) {
        email = savedEmail.trim();
      }
    }
    if (email.isEmpty) {
      final meResponse = await apiConsumer.get(EndPoint.currentUser);
      if (meResponse is Map<String, dynamic>) {
        email = UserProfileModel.fromJson(meResponse).email.trim();
      }
    }
    if (email.isEmpty) {
      throw ServerException(
        errorModel: const ErrorModel(
          statusCode: 400,
          errorMessage: 'User email could not be resolved.',
        ),
      );
    }
    return email;
  }

  @override
  Future<void> requestPasswordChangeOtp() async {
    final email = await _resolveEmail();
    await apiConsumer.post(
      EndPoint.forgotPassword,
      data: {ApiKey.email: email},
    );
  }

  @override
  Future<void> confirmPasswordChange({
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final email = await _resolveEmail();
    final verifyResponse = await apiConsumer.post(
      EndPoint.verifyPasswordResetOtp,
      data: {ApiKey.email: email, ApiKey.otp: otp.trim()},
    );
    final responseData = verifyResponse is Map<String, dynamic>
        ? verifyResponse['data']
        : null;
    final resetToken = verifyResponse is Map<String, dynamic>
        ? (verifyResponse[ApiKey.resetToken] ??
                  (responseData is Map<String, dynamic>
                      ? responseData[ApiKey.resetToken]
                      : null))
              ?.toString()
        : null;
    if (resetToken == null || resetToken.isEmpty) {
      throw ServerException(
        errorModel: const ErrorModel(
          statusCode: 502,
          errorMessage: 'The server did not return a password reset token.',
        ),
      );
    }
    await apiConsumer.post(
      EndPoint.resetPassword,
      data: {
        ApiKey.email: email,
        ApiKey.resetToken: resetToken,
        ApiKey.password: newPassword,
        ApiKey.passwordConfirmation: confirmPassword,
      },
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await requestPasswordChangeOtp();
    throw ServerException(
      errorModel: const ErrorModel(
        statusCode: 409,
        errorMessage: 'A verification code was sent. Enter the email code to complete password change.',
      ),
    );
  }

  @override
  Future<void> logout() async {
    await apiConsumer.post(EndPoint.logout);
  }
}
