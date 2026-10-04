import 'dart:convert';

import 'package:MatchIn/core/cache/cache_key.dart';
import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:MatchIn/features/profile/data/models/candidate_profile_model.dart';

class ProfileLocalDataSourceImpl
    implements ProfileLocalDataSource {
  const ProfileLocalDataSourceImpl({
    required this.sharedPreferencesHelper,
  });

  final SharedPreferencesHelper sharedPreferencesHelper;

  @override
  Future<CandidateProfileModel?>
  getCachedCandidateProfile() async {
    final rawJson = sharedPreferencesHelper.getString(
      key: CacheKey.candidateProfile,
    );

    if (rawJson == null || rawJson.isEmpty) {
      return null;
    }

    try {
      final decodedJson = jsonDecode(rawJson);

      if (decodedJson is! Map<String, dynamic>) {
        return null;
      }

      return CandidateProfileModel.fromJson(decodedJson);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheCandidateProfile(
    CandidateProfileModel profile,
  ) async {
    final rawJson = jsonEncode(profile.toJson());

    await sharedPreferencesHelper.saveData(
      key: CacheKey.candidateProfile,
      value: rawJson,
    );
  }

  @override
  Future<void> clearCachedCandidateProfile() async {
    await sharedPreferencesHelper.deleteData(
      key: CacheKey.candidateProfile,
    );
  }
}
