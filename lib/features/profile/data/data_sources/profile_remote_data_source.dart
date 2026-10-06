import 'package:MatchIn/features/profile/data/models/candidate_profile_model.dart';
import 'package:MatchIn/features/profile/data/models/candidate_project_model.dart';
import 'package:MatchIn/features/profile/data/models/candidate_skill_model.dart';
import 'package:MatchIn/features/profile/data/models/career_preference_model.dart';
import 'package:MatchIn/features/profile/data/models/skill_search_result_model.dart';
import 'package:MatchIn/features/profile/data/models/user_profile_model.dart';
import 'package:MatchIn/features/profile/domain/entities/add_candidate_project_params.dart';
import 'package:MatchIn/features/profile/domain/entities/add_candidate_skill_params.dart';
import 'package:MatchIn/features/profile/domain/entities/save_career_preferences_params.dart';
import 'package:MatchIn/features/profile/domain/entities/update_candidate_project_params.dart';

abstract class ProfileRemoteDataSource {
  Future<CandidateProfileModel> getCandidateProfile();

  Future<UserProfileModel> getUserProfile();

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

  // Career Preferences
  Future<CareerPreferenceModel?> getCareerPreferences();

  Future<CareerPreferenceModel> saveCareerPreferences(
    SaveCareerPreferencesParams params,
  );
}
