import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_profile_entity.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

class GetCachedCandidateProfileUseCase {
  const GetCachedCandidateProfileUseCase({required this.repository});

  final ProfileRepository repository;

  Future<Either<Failure, CandidateProfileEntity?>> call() {
    return repository.getCachedCandidateProfile();
  }
}
