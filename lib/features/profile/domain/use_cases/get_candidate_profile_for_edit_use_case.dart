import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_profile_entity.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

class GetCandidateProfileForEditUseCase {
  const GetCandidateProfileForEditUseCase(this.repository);

  final ProfileRepository repository;

  Future<Either<Failure, CandidateProfileEntity>> call() {
    return repository.getCandidateProfileForEdit();
  }
}
