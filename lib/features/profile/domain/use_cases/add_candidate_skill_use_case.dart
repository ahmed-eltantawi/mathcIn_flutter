import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/add_candidate_skill_params.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_skill_entity.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

class AddCandidateSkillUseCase {
  const AddCandidateSkillUseCase({required this.repository});

  final ProfileRepository repository;

  Future<Either<Failure, CandidateSkillEntity>> call(
    AddCandidateSkillParams params,
  ) {
    return repository.addCandidateSkill(params);
  }
}
