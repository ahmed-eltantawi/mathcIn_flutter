import 'package:shared_preferences/shared_preferences.dart';

/// [SharedPreferencesHelper] handles **non-sensitive** local storage only.
///
/// Injected with a [SharedPreferences] instance via the constructor so the app
/// uses a single instance (managed by GetIt) instead of calling
/// [SharedPreferences.getInstance()] in multiple places.
class SharedPreferencesHelper {
  SharedPreferencesHelper({required this.preferences});

  final SharedPreferences preferences;

  //! ─── Write ───────────────────────────────────────────────────────────────

  /// this method is used to save data with different types
  Future<bool> saveData({required String key, required dynamic value}) async {
    if (value is String) return preferences.setString(key, value);
    if (value is int) return preferences.setInt(key, value);
    if (value is bool) return preferences.setBool(key, value);
    if (value is double) return preferences.setDouble(key, value);
    if (value is List<String>) return preferences.setStringList(key, value);

    throw UnsupportedError(
      'Type ${value.runtimeType} is not supported by SharedPreferences.',
    );
  }

  Future<bool> updateData({required String key, required dynamic value}) =>
      saveData(key: key, value: value);

  //! ─── Read ────────────────────────────────────────────────────────────────

  dynamic getData({required String key}) => preferences.get(key);

  String? getString({required String key}) => preferences.getString(key);

  int? getInt({required String key}) => preferences.getInt(key);

  bool? getBool({required String key}) => preferences.getBool(key);

  double? getDouble({required String key}) => preferences.getDouble(key);

  List<String>? getStringList({required String key}) =>
      preferences.getStringList(key);

  bool containsKey({required String key}) => preferences.containsKey(key);

  Set<String> getKeys() => preferences.getKeys();

  //! ─── Delete ──────────────────────────────────────────────────────────────

  Future<bool> deleteData({required String key}) => preferences.remove(key);

  Future<bool> clearAllData() => preferences.clear();
}
