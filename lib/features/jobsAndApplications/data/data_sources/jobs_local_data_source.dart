import 'package:MatchIn/features/jobsAndApplications/data/models/paginated_jobs_model.dart';

abstract class JobsLocalDataSource {
  Future<PaginatedJobsModel?> getCachedJobs(String cacheKey);

  Future<void> cacheJobs(String cacheKey, PaginatedJobsModel paginatedJobs);

  Future<void> clearCachedJobs(String cacheKey);
}
