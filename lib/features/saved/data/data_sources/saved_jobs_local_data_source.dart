import 'package:MatchIn/features/saved/data/models/paginated_saved_jobs_model.dart';

abstract class SavedJobsLocalDataSource {
  Future<void> cacheSavedJobs(
    String key,
    PaginatedSavedJobsModel savedJobs,
  );

  Future<PaginatedSavedJobsModel?> getCachedSavedJobs(String key);
}
