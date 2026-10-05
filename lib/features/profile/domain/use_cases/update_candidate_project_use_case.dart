import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_project_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/update_candidate_project_params.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateCandidateProjectUseCase {
  const UpdateCandidateProjectUseCase({required this.repository});

  final ProfileRepository repository;

  Future<Either<Failure, CandidateProjectEntity>> call(
    UpdateCandidateProjectParams params,
  ) {
    return repository.updateCandidateProject(params);
  }
}
