import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_file_download_entity.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

class DownloadCvUseCase {
  const DownloadCvUseCase({required this.repository});

  final ProfileRepository repository;

  Future<Either<Failure, CvFileDownloadEntity>> call({int? cvDocumentId}) {
    return repository.downloadCv(cvDocumentId: cvDocumentId);
  }
}
