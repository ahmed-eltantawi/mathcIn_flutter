import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/saved/domain/repositories/saved_jobs_repository.dart';
import 'package:dartz/dartz.dart';

/// Local-first unsave: removes + queues before any network attempt.
class SetUnsavedJobUseCase {
  const SetUnsavedJobUseCase({required this.repository});

  final SavedJobsRepository repository;

  Future<Either<Failure, bool>> call(int jobPostId) {
    return repository.setUnsavedJob(jobPostId);
  }
}
