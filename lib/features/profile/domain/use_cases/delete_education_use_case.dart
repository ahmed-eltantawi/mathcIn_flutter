import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteEducationUseCase {
  const DeleteEducationUseCase({required this.repository});

  final ProfileRepository repository;

  Future<Either<Failure, Unit>> call(int educationId) {
    return repository.deleteEducation(educationId);
  }
}
