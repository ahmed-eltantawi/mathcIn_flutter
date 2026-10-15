import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteExperienceUseCase {
  const DeleteExperienceUseCase({required this.repository});

  final ProfileRepository repository;

  Future<Either<Failure, Unit>> call(int experienceId) {
    return repository.deleteExperience(experienceId);
  }
}
