import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/add_candidate_skill_params.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_profile_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_skill_entity.dart';
import 'package:dartz/dartz.dart';

abstract class ProfileRepository {
  // Candidate Profile
  Future<Either<Failure, CandidateProfileEntity>>
  getCandidateProfile();

  Future<Either<Failure, CandidateProfileEntity?>>
  getCachedCandidateProfile();

  // Candidate Skills
  Future<Either<Failure, List<CandidateSkillEntity>>>
  getCandidateSkills();

  Future<Either<Failure, CandidateSkillEntity>>
  addCandidateSkill(AddCandidateSkillParams params);

  Future<Either<Failure, Unit>> removeCandidateSkill(
    int candidateSkillId,
  );
}
