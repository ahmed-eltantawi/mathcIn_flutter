import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_upload_receipt.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

class RetryPendingCvUploadUseCase {
  const RetryPendingCvUploadUseCase({required this.repository});

  final ProfileRepository repository;

  Future<Either<Failure, CvUploadReceipt?>> call() {
    return repository.retryPendingCvUpload();
  }
}
