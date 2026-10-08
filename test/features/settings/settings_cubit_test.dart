import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/core/services/secure_storage_service.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:MatchIn/features/profile/data/models/candidate_profile_model.dart';
import 'package:MatchIn/features/profile/data/models/user_profile_model.dart';
import 'package:MatchIn/features/settings/data/data_sources/settings_local_data_source_impl.dart';
import 'package:MatchIn/features/settings/data/data_sources/settings_remote_data_source.dart';
import 'package:MatchIn/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:MatchIn/features/settings/domain/repositories/settings_repository.dart';
import 'package:MatchIn/features/settings/domain/use_cases/get_language_use_case.dart';
import 'package:MatchIn/features/settings/domain/use_cases/get_notification_preference_use_case.dart';
import 'package:MatchIn/features/settings/domain/use_cases/get_theme_mode_use_case.dart';
import 'package:MatchIn/features/settings/domain/use_cases/logout_use_case.dart';
import 'package:MatchIn/features/settings/domain/use_cases/set_language_use_case.dart';
import 'package:MatchIn/features/settings/domain/use_cases/set_notification_preference_use_case.dart';
import 'package:MatchIn/features/settings/domain/use_cases/set_theme_mode_use_case.dart';
import 'package:MatchIn/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeProfileLocalDataSource implements ProfileLocalDataSource {
  bool cleared = false;

  @override
  Future<void> cacheCandidateProfile(CandidateProfileModel profile) async {}

  @override
  Future<void> cacheUserProfile(UserProfileModel profile) async {}

  @override
  Future<void> clearCachedCandidateProfile() async {
    cleared = true;
  }

  @override
  Future<CandidateProfileModel?> getCachedCandidateProfile() async => null;

  @override
  Future<UserProfileModel?> getCachedUserProfile() async => null;
}

class _FakeSecureStorageService implements SecureStorageService {
  bool tokensDeleted = false;

  @override
  Future<void> deleteTokens() async {
    tokensDeleted = true;
  }

  @override
  Future<String?> getAccessToken() async => 'dummy_token';

  @override
  Future<String?> getRefreshToken() async => 'dummy_refresh';

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {}
}

class _FakeSettingsRemoteDataSource implements SettingsRemoteDataSource {
  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferencesService sharedPreferencesService;
  late _FakeSecureStorageService fakeSecureStorage;
  late _FakeProfileLocalDataSource fakeProfileDataSource;
  late SettingsRepository repository;
  late SettingsCubit cubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final helper = SharedPreferencesHelper(preferences: prefs);
    sharedPreferencesService = SharedPreferencesService(helper);
    fakeSecureStorage = _FakeSecureStorageService();
    fakeProfileDataSource = _FakeProfileLocalDataSource();

    final localDataSource = SettingsLocalDataSourceImpl(
      sharedPreferencesService: sharedPreferencesService,
      secureStorageService: fakeSecureStorage,
      profileLocalDataSource: fakeProfileDataSource,
    );

    repository = SettingsRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: _FakeSettingsRemoteDataSource(),
    );

    cubit = SettingsCubit(
      getNotificationPreferenceUseCase: GetNotificationPreferenceUseCase(
        repository: repository,
      ),
      setNotificationPreferenceUseCase: SetNotificationPreferenceUseCase(
        repository: repository,
      ),
      getLanguageUseCase: GetLanguageUseCase(repository: repository),
      setLanguageUseCase: SetLanguageUseCase(repository: repository),
      getThemeModeUseCase: GetThemeModeUseCase(repository: repository),
      setThemeModeUseCase: SetThemeModeUseCase(repository: repository),
      logoutUseCase: LogoutUseCase(repository: repository),
    );
  });

  group('SettingsCubit Unit Tests', () {
    test('initial state has default values', () {
      expect(cubit.state.isNotificationsEnabled, isTrue);
      expect(cubit.state.languageCode, equals('en'));
      expect(cubit.state.themeMode, equals(ThemeMode.system));
    });

    test('loadSettings loads preferences from repository', () async {
      await sharedPreferencesService.setNotificationsEnabled(false);
      await sharedPreferencesService.saveLanguageCode('ar');
      await sharedPreferencesService.saveThemeMode('dark');

      await cubit.loadSettings();

      expect(cubit.state.isNotificationsEnabled, isFalse);
      expect(cubit.state.languageCode, equals('ar'));
      expect(cubit.state.themeMode, equals(ThemeMode.dark));
    });

    test('toggleNotifications updates state and persists choice', () async {
      await cubit.toggleNotifications(false);

      expect(cubit.state.isNotificationsEnabled, isFalse);
      expect(sharedPreferencesService.isNotificationsEnabled(), isFalse);

      await cubit.toggleNotifications(true);
      expect(cubit.state.isNotificationsEnabled, isTrue);
      expect(sharedPreferencesService.isNotificationsEnabled(), isTrue);
    });

    test('setLanguage updates state and persists language', () async {
      await cubit.setLanguage('ar');

      expect(cubit.state.languageCode, equals('ar'));
      expect(sharedPreferencesService.getLanguageCode(), equals('ar'));
    });

    test('setTheme updates state and persists theme mode', () async {
      await cubit.setTheme(ThemeMode.light);

      expect(cubit.state.themeMode, equals(ThemeMode.light));
      expect(sharedPreferencesService.getThemeMode(), equals('light'));
    });

    test('logout clears auth data, tokens, profile cache, and updates state', () async {
      await sharedPreferencesService.setLoggedIn(true);

      await cubit.logout();

      expect(cubit.state.isLoggedOut, isTrue);
      expect(sharedPreferencesService.isLoggedIn(), isFalse);
      expect(fakeSecureStorage.tokensDeleted, isTrue);
      expect(fakeProfileDataSource.cleared, isTrue);
    });
  });
}
