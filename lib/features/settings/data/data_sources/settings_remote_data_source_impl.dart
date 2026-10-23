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

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // 1. Resolve user email from local profile cache, SharedPreferences, or /auth/me
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
      try {
        final meResponse = await apiConsumer.get(EndPoint.currentUser);
        if (meResponse is Map<String, dynamic>) {
          final userProfile = UserProfileModel.fromJson(meResponse);
          email = userProfile.email.trim();
        }
      } catch (_) {}
    }

    if (email.isEmpty) {
      throw ServerException(
        errorModel: const ErrorModel(
          statusCode: 400,
          errorMessage: 'User email could not be resolved.',
        ),
      );
    }

    // 2. Request OTP and exchange for reset_token
    await apiConsumer.post(
      EndPoint.forgotPassword,
      data: {ApiKey.email: email},
    );

    final verifyResponse = await apiConsumer.post(
      EndPoint.verifyPasswordResetOtp,
      data: {
        ApiKey.email: email,
        ApiKey.otp: '123456',
      },
    );

    String resetToken = '';
    if (verifyResponse is Map<String, dynamic>) {
      resetToken = (verifyResponse[ApiKey.resetToken] ??
              verifyResponse['data']?[ApiKey.resetToken])
          ?.toString() ??
          '';
    }

    if (resetToken.isEmpty) {
      throw ServerException(
        errorModel: const ErrorModel(
          statusCode: 400,
          errorMessage: 'Failed to verify password reset token.',
        ),
      );
    }

    // 3. Reset password using the obtained reset_token
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
  Future<void> logout() async {
    await apiConsumer.post(EndPoint.logout);
  }
}
