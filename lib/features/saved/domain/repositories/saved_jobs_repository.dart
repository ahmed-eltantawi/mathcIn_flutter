import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/saved/domain/entities/paginated_saved_jobs_entity.dart';
import 'package:dartz/dartz.dart';

abstract class SavedJobsRepository {
  Future<Either<Failure, PaginatedSavedJobsEntity>> getSavedJobs({
    int page = 1,
    int perPage = 15,
  });

  Future<Either<Failure, bool>> saveJob({required int jobPostId});

  Future<Either<Failure, bool>> unsaveJob({required int jobPostId});
}
