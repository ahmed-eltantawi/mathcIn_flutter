import 'package:MatchIn/features/profile/data/models/candidate_profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<CandidateProfileModel?>
  getCachedCandidateProfile();

  Future<void> cacheCandidateProfile(
    CandidateProfileModel profile,
  );

  Future<void> clearCachedCandidateProfile();
}
