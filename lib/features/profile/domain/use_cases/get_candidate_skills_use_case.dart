import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_skill_entity.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

class GetCandidateSkillsUseCase {
  const GetCandidateSkillsUseCase({required this.repository});

  final ProfileRepository repository;

  Future<Either<Failure, List<CandidateSkillEntity>>> call() {
    return repository.getCandidateSkills();
  }
}
