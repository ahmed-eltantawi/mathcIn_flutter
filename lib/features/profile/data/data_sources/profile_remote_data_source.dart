import 'package:MatchIn/features/profile/data/models/candidate_profile_model.dart';
import 'package:MatchIn/features/profile/data/models/candidate_project_model.dart';
import 'package:MatchIn/features/profile/data/models/candidate_skill_model.dart';
import 'package:MatchIn/features/profile/data/models/skill_search_result_model.dart';
import 'package:MatchIn/features/profile/domain/entities/add_candidate_project_params.dart';
import 'package:MatchIn/features/profile/domain/entities/add_candidate_skill_params.dart';
import 'package:MatchIn/features/profile/domain/entities/update_candidate_project_params.dart';

abstract class ProfileRemoteDataSource {
  Future<CandidateProfileModel> getCandidateProfile();

  // Candidate Skills
  Future<List<CandidateSkillModel>> getCandidateSkills();

  Future<CandidateSkillModel> addCandidateSkill(AddCandidateSkillParams params);

  Future<void> removeCandidateSkill(int candidateSkillId);
  Future<List<SkillSearchResultModel>> searchSkills(String query);

  // Candidate Projects
  Future<List<CandidateProjectModel>> getProjects();

  Future<CandidateProjectModel> getProject(int projectId);

  Future<CandidateProjectModel> addCandidateProject(
    AddCandidateProjectParams params,
  );

  Future<CandidateProjectModel> updateCandidateProject(
    UpdateCandidateProjectParams params,
  );

  Future<void> deleteCandidateProject(int projectId);
}
