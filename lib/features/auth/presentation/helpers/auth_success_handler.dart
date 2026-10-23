import 'package:MatchIn/core/networking/api_consumer.dart';
import 'package:MatchIn/core/networking/api_end_points.dart';
import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/core/services/secure_storage_service.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:MatchIn/features/auth/data/models/login_model.dart';
import 'package:MatchIn/features/home/data/data_sources/home_local_data_source.dart';
import 'package:MatchIn/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:MatchIn/features/profile/data/models/user_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  final profileLocal = getIt<ProfileLocalDataSource>();
  // Clear any stale data from previous sessions before writing fresh data
  await profileLocal.clearCachedCandidateProfile();

  // Clear stale cached home dashboard from any previous user session
  final homeLocal = getIt<HomeLocalDataSource>();
  await homeLocal.clearCachedHomeDashboard();

  // --- Prefer name from login response; fall back to GET /auth/me ---
  String resolvedName = '';
  int resolvedId = user?.id ?? 0;
  String resolvedEmail = user?.email ?? '';

  if (user != null) {
    await prefs.saveUserId(user.id);
    final rawName = user.name.trim();
    final isTestName =
        rawName.toLowerCase() == 'test user' ||
        rawName.toLowerCase() == 'test_user';
    if (!isTestName && rawName.isNotEmpty) {
      resolvedName = rawName;
    }
  }

  // If login response did not include a valid name, call auth/me for it
  if (resolvedName.isEmpty) {
    try {
      final api = getIt<ApiConsumer>();
      final meResponse = await api.get(EndPoint.currentUser);
      if (meResponse is Map<String, dynamic>) {
        final meProfile = UserProfileModel.fromJson(meResponse);
        final meName = meProfile.name.trim();
        final isTestName =
            meName.toLowerCase() == 'test user' ||
            meName.toLowerCase() == 'test_user';
        if (!isTestName && meName.isNotEmpty) {
          resolvedName = meName;
        }
        if (resolvedId == 0) resolvedId = meProfile.id;
        if (resolvedEmail.isEmpty) resolvedEmail = meProfile.email;
      }
    } catch (_) {
      // Ignore — Home screen will fetch on load
    }
  }

  if (resolvedEmail.isNotEmpty) {
    await prefs.saveUserEmail(resolvedEmail);
  }

  // Persist resolved profile
  await profileLocal.cacheUserProfile(
    UserProfileModel(
      id: resolvedId,
      name: resolvedName,
      email: resolvedEmail,
      jobTitle: '',
      location: '',
    ),
  );

  if (resolvedName.isNotEmpty) {
    await homeLocal.cacheHomeDashboard(
      HomeDashboardEntity(
        userName: resolvedName,
        matchesCount: 0,
      ),
    );
  }
  // If resolvedName is still empty the Home cubit will fetch from remote on load

  if (context.mounted) {
    context.go(AppRoutes.kHomeView);
  }
}
