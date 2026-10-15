import 'package:MatchIn/features/profile/data/models/candidate_profile_model.dart';
import 'package:MatchIn/features/profile/data/models/cv_local_file_model.dart';
import 'package:MatchIn/features/profile/data/models/cv_pending_upload_model.dart';
import 'package:MatchIn/features/profile/data/models/cv_upload_marker_model.dart';
import 'package:MatchIn/features/profile/data/models/user_profile_model.dart';

abstract interface class ProfileLocalDataSource {
  Future<CandidateProfileModel?> getCachedCandidateProfile();

  Future<void> cacheCandidateProfile(CandidateProfileModel profile);

  Future<void> clearCachedCandidateProfile();

  Future<void> cacheUserProfile(UserProfileModel profile);

  Future<UserProfileModel?> getCachedUserProfile();

  Future<String?> getCachedUserName();

  /// Stringified [CacheKey.id] used to scope CV records per user.
  /// Empty when no user id is available.
  String currentUserScopeId();

  //! ===== CV offline-first storage (per authenticated user) =====

  Future<void> savePendingCvUpload(CvPendingUploadModel pending);

  Future<CvPendingUploadModel?> getPendingCvUpload();

  Future<void> clearPendingCvUpload();

  Future<void> saveUploadedCvMarker(CvUploadMarkerModel marker);

  Future<CvUploadMarkerModel?> getUploadedCvMarker();

  Future<void> clearUploadedCvMarker();

  Future<void> saveCachedCvFile(CvLocalFileModel file);

  Future<CvLocalFileModel?> getCachedCvFile();
}
