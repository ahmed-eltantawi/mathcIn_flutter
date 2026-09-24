import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/saved/domain/entities/paginated_saved_jobs_entity.dart';
import 'package:MatchIn/features/saved/domain/repositories/saved_jobs_repository.dart';
import 'package:dartz/dartz.dart';

class GetSavedJobsUseCase {
  const GetSavedJobsUseCase({required this.repository});

  final SavedJobsRepository repository;

  Future<Either<Failure, PaginatedSavedJobsEntity>> call({
    int page = 1,
    int perPage = 15,
  }) {
    return repository.getSavedJobs(page: page, perPage: perPage);
  }
}
