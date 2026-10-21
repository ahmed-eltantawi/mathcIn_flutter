import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_verify_params.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

class VerifyExtractionUseCase {
  const VerifyExtractionUseCase({required this.repository});

  final ProfileRepository repository;

  Future<Either<Failure, Unit>> call(CvVerifyParams params) {
    return repository.verifyExtraction(params);
  }
}
