import 'package:dartz/dartz.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/add_candidate_project_params.dart';
import 'package:MatchIn/features/profile/domain/entities/add_candidate_skill_params.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_profile_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_project_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_skill_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/career_preference_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/save_career_preferences_params.dart';
import 'package:MatchIn/features/profile/domain/entities/skill_search_result_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/update_candidate_project_params.dart';
import 'package:MatchIn/features/profile/domain/entities/user_profile_entity.dart';

abstract class ProfileRepository {
  // Candidate Profile
  Future<Either<Failure, CandidateProfileEntity>> getCandidateProfile();

  Future<Either<Failure, CandidateProfileEntity?>> getCachedCandidateProfile();

  Future<Either<Failure, UserProfileEntity>> getUserProfile();

  // Candidate Skills
  Future<Either<Failure, List<CandidateSkillEntity>>> getCandidateSkills();

  Future<Either<Failure, CandidateSkillEntity>> addCandidateSkill(
    AddCandidateSkillParams params,
  );

  Future<Either<Failure, Unit>> removeCandidateSkill(int candidateSkillId);
  Future<Either<Failure, List<SkillSearchResultEntity>>> searchSkills(
    String query,
  );

  // Candidate Projects
  Future<Either<Failure, List<CandidateProjectEntity>>> getProjects();

  Future<Either<Failure, CandidateProjectEntity>> getProject(int projectId);

  Future<Either<Failure, CandidateProjectEntity>> addCandidateProject(
    AddCandidateProjectParams params,
  );

  Future<Either<Failure, CandidateProjectEntity>> updateCandidateProject(
    UpdateCandidateProjectParams params,
  );

  Future<Either<Failure, Unit>> deleteCandidateProject(int projectId);

  // Career Preferences
  Future<Either<Failure, CareerPreferenceEntity?>> getCareerPreferences();

  Future<Either<Failure, CareerPreferenceEntity>> saveCareerPreferences(
    SaveCareerPreferencesParams params,
  );
}
