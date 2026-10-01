import 'package:MatchIn/core/cache/cache_key.dart';
import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/features/auth/data/models/user_model.dart';
import 'package:MatchIn/features/auth/domain/entities/user_entity.dart';

class SharedPreferencesService {
  const SharedPreferencesService(this._sharedPreferencesHelper);

  final SharedPreferencesHelper _sharedPreferencesHelper;

  //! ===== Auth =====

  Future<void> setLoggedIn() async {
    await _sharedPreferencesHelper.saveData(
      key: CacheKey.isLoggedIn,
      value: true,
    );
  }

  bool isLoggedIn() {
    return _sharedPreferencesHelper.getData(key: CacheKey.isLoggedIn) ?? false;
  }

  /// Serialises the full user object to a JSON string and persists it.
  /// A single cache entry replaces all scattered primitive keys.
  Future<void> saveUserData(UserEntity user) async {
    final model = UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      isActive: user.isActive,
      avatar: user.avatar,
      phone: user.phone,
    );
    await _sharedPreferencesHelper.saveData(
      key: CacheKey.userDataKey,
      value: model.toJsonString(),
    );
  }

  /// Retrieves and deserialises the cached user object, or returns null.
  UserEntity? getUserData() {
    final raw = _sharedPreferencesHelper.getString(key: CacheKey.userDataKey);
    if (raw == null || raw.isEmpty) return null;
    return UserModel.fromJsonString(raw);
  }

  Future<void> clearAuthData() async {
    await _sharedPreferencesHelper.deleteData(key: CacheKey.id);
    await _sharedPreferencesHelper.deleteData(key: CacheKey.userDataKey);
    await _sharedPreferencesHelper.deleteData(key: CacheKey.isLoggedIn);
  }

  //! ===== Onboarding =====

  Future<void> onBoardingViewed() async {
    await _sharedPreferencesHelper.saveData(
      key: CacheKey.onBoardingViewed,
      value: true,
    );
  }

  bool isOnBoardingViewed() {
    return _sharedPreferencesHelper.getData(
          key: CacheKey.onBoardingViewed,
        ) ??
        false;
  }

  //! ===== FCM =====

  Future<void> saveFcmToken(String token) async {
    await _sharedPreferencesHelper.saveData(
      key: CacheKey.fcmToken,
      value: token,
    );
  }

  String? getFcmToken() {
    return _sharedPreferencesHelper.getString(key: CacheKey.fcmToken);
  }

  //! ===== Roadmap — Treasures & Tasks =====

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

  // --- Roadmap rewarded ad XP persistence ---
  Future<void> saveRewardedAdXp(int xp) async {
    await _sharedPreferencesHelper.saveData(
      key: CacheKey.rewardedAdXp,
      value: xp,
    );
  }

  int getRewardedAdXp() {
    return _sharedPreferencesHelper.getData(key: CacheKey.rewardedAdXp) ?? 0;
  }
}
