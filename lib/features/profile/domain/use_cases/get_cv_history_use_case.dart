import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_document_entity.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

class GetCvHistoryUseCase {
  const GetCvHistoryUseCase({required this.repository});

  final ProfileRepository repository;

  Future<Either<Failure, List<CvDocumentEntity>>> call() {
    return repository.getCvHistory();
  }
}
