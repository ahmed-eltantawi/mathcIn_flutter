abstract class SettingsLocalDataSource {
  Future<bool> getNotificationPreference();

  Future<void> setNotificationPreference(bool enabled);

  Future<String> getLanguageCode();

  Future<void> setLanguageCode(String languageCode);

  Future<String> getThemeMode();

  Future<void> setThemeMode(String themeMode);

  Future<void> logout();
}
