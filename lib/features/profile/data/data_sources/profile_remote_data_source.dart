import 'package:MatchIn/features/profile/data/models/candidate_profile_model.dart';
import 'package:MatchIn/features/profile/data/models/candidate_skill_model.dart';
import 'package:MatchIn/features/profile/domain/entities/add_candidate_skill_params.dart';

abstract class ProfileRemoteDataSource {
  Future<CandidateProfileModel> getCandidateProfile();

  Future<List<CandidateSkillModel>> getCandidateSkills();

  Future<CandidateSkillModel> addCandidateSkill(AddCandidateSkillParams params);

  Future<void> removeCandidateSkill(int candidateSkillId);
}
