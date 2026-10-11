import 'package:MatchIn/features/settings/domain/use_cases/get_language_use_case.dart';
import 'package:MatchIn/features/settings/domain/use_cases/get_notification_preference_use_case.dart';
import 'package:MatchIn/features/settings/domain/use_cases/get_theme_mode_use_case.dart';
import 'package:MatchIn/features/settings/domain/use_cases/logout_use_case.dart';
import 'package:MatchIn/features/settings/domain/use_cases/set_language_use_case.dart';
import 'package:MatchIn/features/settings/domain/use_cases/set_notification_preference_use_case.dart';
import 'package:MatchIn/features/settings/domain/use_cases/set_theme_mode_use_case.dart';
import 'package:MatchIn/features/settings/presentation/cubit/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required this.getNotificationPreferenceUseCase,
    required this.setNotificationPreferenceUseCase,
    required this.getLanguageUseCase,
    required this.setLanguageUseCase,
    required this.getThemeModeUseCase,
    required this.setThemeModeUseCase,
    required this.logoutUseCase,
  }) : super(const SettingsState());

  final GetNotificationPreferenceUseCase getNotificationPreferenceUseCase;
  final SetNotificationPreferenceUseCase setNotificationPreferenceUseCase;
  final GetLanguageUseCase getLanguageUseCase;
  final SetLanguageUseCase setLanguageUseCase;
  final GetThemeModeUseCase getThemeModeUseCase;
  final SetThemeModeUseCase setThemeModeUseCase;
  final LogoutUseCase logoutUseCase;

  Future<void> loadSettings() async {
    final notifResult = await getNotificationPreferenceUseCase();
    final langResult = await getLanguageUseCase();
    final themeResult = await getThemeModeUseCase();

    final isNotificationsEnabled = notifResult.fold(
      (_) => state.isNotificationsEnabled,
      (value) => value,
    );

    final languageCode = langResult.fold(
      (_) => state.languageCode,
      (value) => value,
    );

    final themeModeStr = themeResult.fold(
      (_) => 'system',
      (value) => value,
    );

    final themeMode = _parseThemeMode(themeModeStr);

    emit(
      state.copyWith(
        isNotificationsEnabled: isNotificationsEnabled,
        languageCode: languageCode,
        themeMode: themeMode,
        isLoading: false,
      ),
    );
  }

  Future<void> toggleNotifications(bool enabled) async {
    final result = await setNotificationPreferenceUseCase(enabled);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => emit(state.copyWith(isNotificationsEnabled: enabled)),
    );
  }

  Future<void> setLanguage(String languageCode) async {
    final result = await setLanguageUseCase(languageCode);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => emit(state.copyWith(languageCode: languageCode)),
    );
  }

  Future<void> setTheme(ThemeMode mode) async {
    final themeStr = _themeModeToString(mode);
    final result = await setThemeModeUseCase(themeStr);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => emit(state.copyWith(themeMode: mode)),
    );
  }

  Future<void> logout() async {
    emit(state.copyWith(isLoading: true));
    final result = await logoutUseCase();
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          isLoading: false,
          isLoggedOut: true,
        ),
      ),
    );
  }

  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
