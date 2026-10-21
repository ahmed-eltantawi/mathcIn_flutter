import 'package:MatchIn/features/saved/data/models/paginated_saved_jobs_model.dart';
import 'package:MatchIn/features/saved/data/models/saved_job_response_model.dart';
import 'package:MatchIn/features/saved/data/models/saved_job_sync_op.dart';

abstract interface class SavedJobsLocalDataSource {
  Future<void> cacheSavedJobs(String key, PaginatedSavedJobsModel savedJobs);

  Future<PaginatedSavedJobsModel?> getCachedSavedJobs(String key);

  Future<void> removeSavedJob(int jobPostId);

  Future<void> clearCache();

  /// Inserts or replaces [job] by stable backend id in the primary local
  /// snapshot (durable, survives restarts). Never creates duplicates.
  Future<void> upsertSavedJob(SavedJobResponseModel job);

  /// Full locally-known saved list (primary snapshot), oldest intent last.
  Future<List<SavedJobResponseModel>> getLocalSavedJobs();

  /// Durable pending-sync queue, oldest first. Latest intent per job wins:
  /// enqueueing replaces any queued op with the same [opKey].
  Future<List<SavedJobSyncOp>> getPendingOps();

  Future<void> enqueueOp(SavedJobSyncOp op);

  Future<void> removeOp(String opKey);

  Future<void> updateOp(SavedJobSyncOp op);
}
