import 'dart:convert';

import 'package:MatchIn/core/cache/cache_key.dart';
import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:MatchIn/features/profile/data/models/candidate_profile_model.dart';
import 'package:MatchIn/features/profile/data/models/cv_local_file_model.dart';
import 'package:MatchIn/features/profile/data/models/cv_pending_upload_model.dart';
import 'package:MatchIn/features/profile/data/models/cv_upload_marker_model.dart';
import 'package:MatchIn/features/profile/data/models/user_profile_model.dart';

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  const ProfileLocalDataSourceImpl({required this.sharedPreferencesHelper});

  final SharedPreferencesHelper sharedPreferencesHelper;

  String _candidateProfileKey() {
    final userId = sharedPreferencesHelper.getData(key: CacheKey.id);
    if (userId != null && userId is int && userId > 0) {
      return '${CacheKey.candidateProfile}_$userId';
    }
    return CacheKey.candidateProfile;
  }

  //! ─── CV offline-first storage ────────────────────────────────────────────

  // --- Every CV record is scoped per user so one account never sees
  // --- another account's pending or cached file. ---
  @override
  String currentUserScopeId() {
    final userId = sharedPreferencesHelper.getData(key: CacheKey.id);
    if (userId == null) return '';
    final text = userId.toString();
    return text.isEmpty ? '' : text;
  }

  String _scopedCvKey(String base) {
    final userId = currentUserScopeId();
    if (userId.isNotEmpty) {
      return '${base}_$userId';
    }
    return base;
  }

  @override
  Future<void> savePendingCvUpload(CvPendingUploadModel pending) async {
    await sharedPreferencesHelper.saveData(
      key: _scopedCvKey(CacheKey.pendingCv),
      value: jsonEncode(pending.toJson()),
    );
  }

  @override
  Future<CvPendingUploadModel?> getPendingCvUpload() async {
    final rawJson = sharedPreferencesHelper.getString(
      key: _scopedCvKey(CacheKey.pendingCv),
    );
    if (rawJson == null || rawJson.isEmpty) return null;
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map<String, dynamic>) return null;
      final pending = CvPendingUploadModel.fromJson(decoded);
      if (pending.bytes.isEmpty) return null;
      return pending;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearPendingCvUpload() async {
    await sharedPreferencesHelper.deleteData(
      key: _scopedCvKey(CacheKey.pendingCv),
    );
  }

  @override
  Future<void> saveUploadedCvMarker(CvUploadMarkerModel marker) async {
    await sharedPreferencesHelper.saveData(
      key: _scopedCvKey(CacheKey.cvUploadMarker),
      value: jsonEncode(marker.toJson()),
    );
  }

  @override
  Future<CvUploadMarkerModel?> getUploadedCvMarker() async {
    final rawJson = sharedPreferencesHelper.getString(
      key: _scopedCvKey(CacheKey.cvUploadMarker),
    );
    if (rawJson == null || rawJson.isEmpty) return null;
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map<String, dynamic>) return null;
      return CvUploadMarkerModel.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearUploadedCvMarker() async {
    await sharedPreferencesHelper.deleteData(
      key: _scopedCvKey(CacheKey.cvUploadMarker),
    );
  }

  @override
  Future<void> saveCachedCvFile(CvLocalFileModel file) async {
    await sharedPreferencesHelper.saveData(
      key: _scopedCvKey(CacheKey.cachedCvFile),
      value: jsonEncode(file.toJson()),
    );
  }

  @override
  Future<CvLocalFileModel?> getCachedCvFile() async {
    final rawJson = sharedPreferencesHelper.getString(
      key: _scopedCvKey(CacheKey.cachedCvFile),
    );
    if (rawJson == null || rawJson.isEmpty) return null;
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map<String, dynamic>) return null;
      final file = CvLocalFileModel.fromJson(decoded);
      if (file.bytes.isEmpty) return null;
      return file;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<CandidateProfileModel?> getCachedCandidateProfile() async {
    String? rawJson = sharedPreferencesHelper.getString(
      key: _candidateProfileKey(),
    );

    // Fallback to legacy default key if user-scoped key is empty
    if (rawJson == null || rawJson.isEmpty) {
      rawJson = sharedPreferencesHelper.getString(
        key: CacheKey.candidateProfile,
      );
    }

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
  Future<void> cacheCandidateProfile(CandidateProfileModel profile) async {
    final rawJson = jsonEncode(profile.toJson());

    await sharedPreferencesHelper.saveData(
      key: _candidateProfileKey(),
      value: rawJson,
    );
    // Also save under general key for backward compatibility
    await sharedPreferencesHelper.saveData(
      key: CacheKey.candidateProfile,
      value: rawJson,
    );
  }

  @override
  Future<void> clearCachedCandidateProfile() async {
    await sharedPreferencesHelper.deleteData(key: _candidateProfileKey());
    await sharedPreferencesHelper.deleteData(key: CacheKey.candidateProfile);
    // --- Remove every per-user CV record (profile copy, pending
    // --- upload, marker, cached file). The id is already wiped at
    // --- logout, so stale suffixed keys are cleared by prefix. ---
    await _clearKeysWithPrefix(CacheKey.candidateProfile);
    await _clearKeysWithPrefix(CacheKey.pendingCv);
    await _clearKeysWithPrefix(CacheKey.cvUploadMarker);
    await _clearKeysWithPrefix(CacheKey.cachedCvFile);
  }

  Future<void> _clearKeysWithPrefix(String prefix) async {
    final keys = sharedPreferencesHelper.getKeys();
    for (final key in keys) {
      if (key == prefix || key.startsWith('${prefix}_')) {
        await sharedPreferencesHelper.deleteData(key: key);
      }
    }
  }

  @override
  Future<void> cacheUserProfile(UserProfileModel profile) async {
    final jsonString = jsonEncode(profile.toJson());
    await sharedPreferencesHelper.saveData(
      key: CacheKey.userDataKey,
      value: jsonString,
    );
  }

  @override
  Future<UserProfileModel?> getCachedUserProfile() async {
    final jsonString = sharedPreferencesHelper.getString(
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

  @override
  Future<String?> getCachedUserName() async {
    // 1. Try candidate profile first
    final candidateProfile = await getCachedCandidateProfile();
    if (candidateProfile != null && candidateProfile.user.name.trim().isNotEmpty) {
      return candidateProfile.user.name.trim();
    }

    // 2. Try user profile
    final userProfile = await getCachedUserProfile();
    if (userProfile != null && userProfile.name.trim().isNotEmpty) {
      return userProfile.name.trim();
    }

    return null;
  }
}
