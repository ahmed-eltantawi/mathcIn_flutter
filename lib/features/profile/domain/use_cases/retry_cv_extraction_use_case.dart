import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_extraction_status_entity.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

class RetryCvExtractionUseCase {
  const RetryCvExtractionUseCase({required this.repository});

  final ProfileRepository repository;

  Future<Either<Failure, CvExtractionStatusEntity>> call(int cvDocumentId) {
    return repository.retryCvExtraction(cvDocumentId);
  }
}
