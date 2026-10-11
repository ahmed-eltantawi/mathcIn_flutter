import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteCandidateProjectUseCase {
  const DeleteCandidateProjectUseCase({required this.repository});

  final ProfileRepository repository;

  Future<Either<Failure, Unit>> call(int projectId) {
    return repository.deleteCandidateProject(projectId);
  }
}
