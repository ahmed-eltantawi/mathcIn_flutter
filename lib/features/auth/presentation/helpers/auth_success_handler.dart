import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/core/services/secure_storage_service.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:MatchIn/features/auth/data/models/login_model.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:MatchIn/features/profile/data/models/user_profile_model.dart';

///* Persists backend tokens + session flags after any successful login
/// (email/password or Google) and navigates to Home.
/// Single source of truth so login and Google buttons cannot diverge.
Future<void> handleLoginSuccess(
  BuildContext context,
  LoginModel loginModel,
) async {
  final prefs = getIt<SharedPreferencesService>();
  final secureStorage = getIt<SecureStorageService>();
  // Save tokens to secure storage so the interceptor can attach them
  final token = loginModel.accessToken;
  final refreshToken = loginModel.refreshToken ?? '';
  await secureStorage.saveTokens(
    accessToken: token,
    refreshToken: refreshToken,
  );
  await prefs.setLoggedIn(true);
  await prefs.setGuest(false);
  final user = loginModel.user;
  if (user != null) {
    await prefs.saveUserId(user.id);
    final profileLocal = getIt<ProfileLocalDataSource>();
    await profileLocal.cacheUserProfile(
      UserProfileModel(
        id: user.id,
        name: user.name,
        email: user.email,
        jobTitle: '',
        location: '',
      ),
    );
  }
  if (context.mounted) {
    context.go(AppRoutes.kHomeView);
  }
}
