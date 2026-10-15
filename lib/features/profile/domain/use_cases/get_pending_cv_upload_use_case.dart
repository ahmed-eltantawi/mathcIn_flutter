import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_pending_upload.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

class GetPendingCvUploadUseCase {
  const GetPendingCvUploadUseCase({required this.repository});

  final ProfileRepository repository;

  Future<Either<Failure, CvPendingUpload?>> call() {
    return repository.getPendingCvUpload();
  }
}
