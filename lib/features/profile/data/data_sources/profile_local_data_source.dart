import 'package:MatchIn/features/profile/data/models/candidate_profile_model.dart';
import 'package:MatchIn/features/profile/data/models/user_profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<CandidateProfileModel?> getCachedCandidateProfile();

  Future<void> cacheCandidateProfile(CandidateProfileModel profile);

  Future<void> clearCachedCandidateProfile();

  Future<void> cacheUserProfile(UserProfileModel profile);

  Future<UserProfileModel?> getCachedUserProfile();
}
