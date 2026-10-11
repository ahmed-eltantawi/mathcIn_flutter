import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_project_entity.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

class GetProjectUseCase {
  const GetProjectUseCase({required this.repository});

  final ProfileRepository repository;

  Future<Either<Failure, CandidateProjectEntity>> call(int projectId) {
    return repository.getProject(projectId);
  }
}
