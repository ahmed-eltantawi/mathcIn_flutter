
import '../cache/cache_key.dart';
import '../cache/shared_preferences_helper.dart';

class SharedPreferencesService {
  const SharedPreferencesService(this._sharedPreferencesHelper);

  final SharedPreferencesHelper _sharedPreferencesHelper;

  // --- This methods are used to save and get data about login status ---
  Future<void> setLoggedIn(bool value) async {
    await _sharedPreferencesHelper.saveData(
      key: CacheKey.isLoggedIn,
      value: value,
    );
  }

  bool isLoggedIn() {
    return _sharedPreferencesHelper.getData(key: CacheKey.isLoggedIn) ?? false;
  }

  Future<void> clearAuthData() async {
    await _sharedPreferencesHelper.deleteData(key: CacheKey.id);
    await _sharedPreferencesHelper.deleteData(key: CacheKey.userDataKey);
    await _sharedPreferencesHelper.deleteData(key: CacheKey.isLoggedIn);
  }

  // --- This methods are used to save and get data about onboarding status ---
  Future<void> onBoardingViewed() async {
    await _sharedPreferencesHelper.saveData(
      key: CacheKey.onBoardingViewed,
      value: true,
    );
  }

  bool isOnBoardingViewed() {
    return _sharedPreferencesHelper.getData(key: CacheKey.onBoardingViewed) ??
        false;
  }

  // --- FCM token — persisted locally so it can be re-sent after a restart ---
  Future<void> saveFcmToken(String token) async {
    await _sharedPreferencesHelper.saveData(
      key: CacheKey.fcmToken,
      value: token,
    );
  }

  String? getFcmToken() {
    return _sharedPreferencesHelper.getString(key: CacheKey.fcmToken);
  }

  // --- Roadmap collected treasure milestones persistence ---
  Future<void> saveCollectedTreasures(Set<int> milestoneIndices) async {
    final list = milestoneIndices.map((e) => e.toString()).toList();
    await _sharedPreferencesHelper.saveData(
      key: CacheKey.collectedTreasures,
      value: list,
    );
  }

  Set<int> getCollectedTreasures() {
    final list = _sharedPreferencesHelper.getStringList(
      key: CacheKey.collectedTreasures,
    );
    if (list == null) return {};
    return list.map((e) => int.tryParse(e)).whereType<int>().toSet();
  }

  // --- Roadmap completed tasks persistence ---
  Future<void> saveCompletedTasks(Set<String> taskIds) async {
    await _sharedPreferencesHelper.saveData(
      key: CacheKey.completedTaskIds,
      value: taskIds.toList(),
    );
  }

  Set<String> getCompletedTasks() {
    final list = _sharedPreferencesHelper.getStringList(
      key: CacheKey.completedTaskIds,
    );
    if (list == null) return {};
    return list.toSet();
  }
}
