import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_upload_input.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_upload_receipt.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

class UploadCvUseCase {
  const UploadCvUseCase({required this.repository});

  final ProfileRepository repository;

  Future<Either<Failure, CvUploadReceipt?>> call(
    CvUploadInput input, {
    void Function(int sentBytes, int totalBytes)? onSendProgress,
  }) {
    return repository.uploadCv(input, onSendProgress: onSendProgress);
  }
}
