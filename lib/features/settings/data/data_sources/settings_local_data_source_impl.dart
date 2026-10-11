import 'package:MatchIn/core/networking/api_interceptor.dart';
import 'package:MatchIn/core/services/secure_storage_service.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:MatchIn/features/settings/data/data_sources/settings_local_data_source.dart';

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  const SettingsLocalDataSourceImpl({
    required this.sharedPreferencesService,
    required this.secureStorageService,
    required this.profileLocalDataSource,
  });

  final SharedPreferencesService sharedPreferencesService;
  final SecureStorageService secureStorageService;
  final ProfileLocalDataSource profileLocalDataSource;

  @override
  Future<bool> getNotificationPreference() async {
    return sharedPreferencesService.isNotificationsEnabled();
  }

  @override
  Future<void> setNotificationPreference(bool enabled) async {
    await sharedPreferencesService.setNotificationsEnabled(enabled);
  }

  @override
  Future<String> getLanguageCode() async {
    return sharedPreferencesService.getLanguageCode();
  }

  @override
  Future<void> setLanguageCode(String languageCode) async {
    await sharedPreferencesService.saveLanguageCode(languageCode);
  }

  @override
  Future<String> getThemeMode() async {
    return sharedPreferencesService.getThemeMode();
  }

  @override
  Future<void> setThemeMode(String themeMode) async {
    await sharedPreferencesService.saveThemeMode(themeMode);
  }

  @override
  Future<void> logout() async {
    // 1. Clear session keys from SharedPreferences (isLoggedIn, id, userDataKey)
    await sharedPreferencesService.clearAuthData();
    // 1b. Explicit logout also exits guest mode so auth shows again.
    await sharedPreferencesService.setGuest(false);

    // 2. Clear JWT tokens from FlutterSecureStorage
    await secureStorageService.deleteTokens();

    // 3. Clear cached profile data
    await profileLocalDataSource.clearCachedCandidateProfile();

    // 4. Dispatch logout event across the app
    AuthEventBus.instance.addEvent(AuthEvent.logout);
  }
}
