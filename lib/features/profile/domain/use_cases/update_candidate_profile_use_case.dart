import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_profile_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/update_candidate_profile_params.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateCandidateProfileUseCase {
  const UpdateCandidateProfileUseCase(this.repository);

  final ProfileRepository repository;

  Future<Either<Failure, CandidateProfileEntity>> call(
    UpdateCandidateProfileParams params,
  ) {
    return repository.updateCandidateProfile(params);
  }
}
