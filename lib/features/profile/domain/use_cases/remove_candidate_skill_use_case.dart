import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

class RemoveCandidateSkillUseCase {
  const RemoveCandidateSkillUseCase({required this.repository});

  final ProfileRepository repository;

  Future<Either<Failure, Unit>> call(int candidateSkillId) {
    return repository.removeCandidateSkill(candidateSkillId);
  }
}
