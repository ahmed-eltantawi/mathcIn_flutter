import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_local_file.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

class GetLocalCvFileUseCase {
  const GetLocalCvFileUseCase({required this.repository});

  final ProfileRepository repository;

  Future<Either<Failure, CvLocalFile?>> call() {
    return repository.getLocalCvFile();
  }
}
