import 'package:MatchIn/features/profile/data/models/candidate_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<CandidateProfileModel> getCandidateProfile();
}
