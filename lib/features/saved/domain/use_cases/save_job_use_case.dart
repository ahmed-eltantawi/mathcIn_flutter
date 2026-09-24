import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/saved/domain/repositories/saved_jobs_repository.dart';
import 'package:dartz/dartz.dart';

class SaveJobUseCase {
  const SaveJobUseCase({required this.repository});

  final SavedJobsRepository repository;

  Future<Either<Failure, bool>> call({required int jobPostId}) {
    return repository.saveJob(jobPostId: jobPostId);
  }
}
