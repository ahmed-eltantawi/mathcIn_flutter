import 'dart:convert';

import 'package:MatchIn/core/cache/cache_key.dart';
import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:MatchIn/features/profile/data/models/user_profile_model.dart';

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  const ProfileLocalDataSourceImpl(this._sharedPreferencesHelper);

  final SharedPreferencesHelper _sharedPreferencesHelper;

  @override
  Future<void> cacheUserProfile(UserProfileModel profile) async {
    final jsonString = jsonEncode(profile.toJson());
    await _sharedPreferencesHelper.saveData(
      key: CacheKey.userDataKey,
      value: jsonString,
    );
  }

  @override
  Future<UserProfileModel?> getCachedUserProfile() async {
    final jsonString = _sharedPreferencesHelper.getString(
      key: CacheKey.userDataKey,
    );
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserProfileModel.fromJson(jsonMap);
    } catch (_) {
      return null;
    }
  }
}
