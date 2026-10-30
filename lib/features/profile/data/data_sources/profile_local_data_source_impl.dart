import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:MatchIn/core/cache/cache_key.dart';
import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:MatchIn/features/profile/data/models/candidate_profile_model.dart';
import 'package:MatchIn/features/profile/data/models/cv_local_file_model.dart';
import 'package:MatchIn/features/profile/data/models/cv_pending_upload_model.dart';
import 'package:MatchIn/features/profile/data/models/cv_upload_marker_model.dart';
import 'package:MatchIn/features/profile/data/models/user_profile_model.dart';
import 'package:path_provider/path_provider.dart';

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

  Future<File> _cvFile(String kind) async {
    final directory = await getApplicationSupportDirectory();
    final safeUserId = currentUserScopeId().replaceAll(
      RegExp(r'[^A-Za-z0-9_-]'),
      '_',
    );
    return File('${directory.path}${Platform.pathSeparator}profile_cv_${kind}_$safeUserId.bin');
  }

  @override
  Future<void> savePendingCvUpload(CvPendingUploadModel pending) async {
    await (await _cvFile('pending')).writeAsBytes(pending.bytes, flush: true);
    await sharedPreferencesHelper.saveData(
      key: _scopedCvKey(CacheKey.pendingCv),
      value: jsonEncode({
        'fileName': pending.fileName,
        'extension': pending.extension,
        'sizeBytes': pending.sizeBytes,
        'userId': pending.userId,
        'savedAt': pending.savedAt,
      }),
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
      final legacy = CvPendingUploadModel.fromJson(decoded);
      final bytes = legacy.bytes.isNotEmpty
          ? legacy.bytes
          : await _readCvBytes('pending');
      if (bytes.isEmpty) return null;
      if (legacy.bytes.isNotEmpty) {
        await (await _cvFile('pending')).writeAsBytes(bytes, flush: true);
        await sharedPreferencesHelper.saveData(
          key: _scopedCvKey(CacheKey.pendingCv),
          value: jsonEncode({
            'fileName': legacy.fileName,
            'extension': legacy.extension,
            'sizeBytes': legacy.sizeBytes,
            'userId': legacy.userId,
            'savedAt': legacy.savedAt,
          }),
        );
      }
      return CvPendingUploadModel(
        fileName: legacy.fileName,
        extension: legacy.extension,
        sizeBytes: legacy.sizeBytes,
        bytes: bytes,
        userId: legacy.userId,
        savedAt: legacy.savedAt,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearPendingCvUpload() async {
    await _deleteCvFile('pending');
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
    await (await _cvFile('cached')).writeAsBytes(file.bytes, flush: true);
    await sharedPreferencesHelper.saveData(
      key: _scopedCvKey(CacheKey.cachedCvFile),
      value: jsonEncode({
        'fileName': file.fileName,
        'userId': file.userId,
        'savedAt': file.savedAt,
      }),
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
      final legacy = CvLocalFileModel.fromJson(decoded);
      final bytes = legacy.bytes.isNotEmpty
          ? legacy.bytes
          : await _readCvBytes('cached');
      if (bytes.isEmpty) return null;
      if (legacy.bytes.isNotEmpty) {
        await (await _cvFile('cached')).writeAsBytes(bytes, flush: true);
        await sharedPreferencesHelper.saveData(
          key: _scopedCvKey(CacheKey.cachedCvFile),
          value: jsonEncode({
            'fileName': legacy.fileName,
            'userId': legacy.userId,
            'savedAt': legacy.savedAt,
          }),
        );
      }
      return CvLocalFileModel(
        fileName: legacy.fileName,
        bytes: bytes,
        userId: legacy.userId,
        savedAt: legacy.savedAt,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<CandidateProfileModel?> getCachedCandidateProfile() async {
    final userId = sharedPreferencesHelper.getData(key: CacheKey.id);
    final rawJson = sharedPreferencesHelper.getString(
      key: _candidateProfileKey(),
    );

    // Fallback to legacy default key ONLY if it matches the current user
    if (rawJson == null || rawJson.isEmpty) {
      final legacyJson = sharedPreferencesHelper.getString(
        key: CacheKey.candidateProfile,
      );
      if (legacyJson != null && legacyJson.isNotEmpty) {
        try {
          final decoded = jsonDecode(legacyJson);
          if (decoded is Map<String, dynamic>) {
            final model = CandidateProfileModel.fromJson(decoded);
            if (userId == null || model.user.id == 0 || model.user.id == userId) {
              return model;
            }
          }
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    try {
      final decodedJson = jsonDecode(rawJson);

      if (decodedJson is! Map<String, dynamic>) {
        return null;
      }

      final profile = CandidateProfileModel.fromJson(decodedJson);
      if (userId != null && profile.user.id != 0 && profile.user.id != userId) {
        return null;
      }
      return profile;
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
    await _deleteAllCvFiles();
    await sharedPreferencesHelper.deleteData(key: _candidateProfileKey());
    await sharedPreferencesHelper.deleteData(key: CacheKey.candidateProfile);
    await sharedPreferencesHelper.deleteData(key: CacheKey.userDataKey);
    // --- Remove every per-user CV record (profile copy, pending
    // --- upload, marker, cached file). The id is already wiped at
    // --- logout, so stale suffixed keys are cleared by prefix. ---
    await _clearKeysWithPrefix(CacheKey.candidateProfile);
    await _clearKeysWithPrefix(CacheKey.pendingCv);
    await _clearKeysWithPrefix(CacheKey.cvUploadMarker);
    await _clearKeysWithPrefix(CacheKey.cachedCvFile);
  }

  Future<Uint8List> _readCvBytes(String kind) async {
    try {
      final file = await _cvFile(kind);
      if (!await file.exists()) return Uint8List(0);
      return await file.readAsBytes();
    } catch (_) {
      return Uint8List(0);
    }
  }

  Future<void> _deleteCvFile(String kind) async {
    try {
      final file = await _cvFile(kind);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  Future<void> _deleteAllCvFiles() async {
    try {
      final directory = await getApplicationSupportDirectory();
      await for (final entry in directory.list()) {
        if (entry is File &&
            entry.uri.pathSegments.last.startsWith('profile_cv_')) {
          await entry.delete();
        }
      }
    } catch (_) {}
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
    // Names that are known stale / placeholder — never surface them
    const staleNames = {'test user', 'test_user', 'user', 'test'};

    // 1. Try user profile first (directly persisted upon login with active user data)
    final userProfile = await getCachedUserProfile();
    if (userProfile != null && userProfile.name.trim().isNotEmpty) {
      final name = userProfile.name.trim();
      if (!staleNames.contains(name.toLowerCase())) {
        return name;
      }
    }

    // 2. Try candidate profile
    final candidateProfile = await getCachedCandidateProfile();
    if (candidateProfile != null &&
        candidateProfile.user.name.trim().isNotEmpty) {
      final name = candidateProfile.user.name.trim();
      if (!staleNames.contains(name.toLowerCase())) {
        return name;
      }
    }

    return null;
  }
}
