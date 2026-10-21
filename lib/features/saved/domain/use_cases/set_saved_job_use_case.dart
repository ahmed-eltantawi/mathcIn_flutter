import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/saved/domain/entities/saved_job_entity.dart';
import 'package:MatchIn/features/saved/domain/repositories/saved_jobs_repository.dart';
import 'package:dartz/dartz.dart';

/// Local-first save: persists + queues before any network attempt.
class SetSavedJobUseCase {
  const SetSavedJobUseCase({required this.repository});

  final SavedJobsRepository repository;

  Future<Either<Failure, bool>> call(SavedJobEntity job) {
    return repository.setSavedJob(job);
  }
}
