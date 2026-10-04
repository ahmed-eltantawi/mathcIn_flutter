import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_profile_entity.dart';
import 'package:dartz/dartz.dart';

abstract class ProfileRepository {
  Future<Either<Failure, CandidateProfileEntity>> getCandidateProfile();

  Future<Either<Failure, CandidateProfileEntity?>> getCachedCandidateProfile();
}
