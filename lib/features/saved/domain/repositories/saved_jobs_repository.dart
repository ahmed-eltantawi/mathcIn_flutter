import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/saved/data/models/saved_job_sync_op.dart';
import 'package:MatchIn/features/saved/domain/entities/paginated_saved_jobs_entity.dart';
import 'package:MatchIn/features/saved/domain/entities/saved_job_entity.dart';
import 'package:MatchIn/features/saved/domain/entities/saved_jobs_sync_report.dart';
import 'package:dartz/dartz.dart';

abstract class SavedJobsRepository {
  Future<Either<Failure, PaginatedSavedJobsEntity>> getSavedJobs({
    int page = 1,
    int perPage = 15,
  });

  Future<Either<Failure, bool>> saveJob({required int jobPostId});

  Future<Either<Failure, bool>> unsaveJob({required int jobPostId});

  /// Local-first save: persists [job] in the durable local snapshot and
  /// enqueues a sync op BEFORE any network attempt, then best-effort syncs
  /// in the background. Offline the job stays saved locally with the op
  /// pending. Never fails merely because the network is unavailable.
  Future<Either<Failure, bool>> setSavedJob(SavedJobEntity job);

  /// Local-first unsave: removes [jobPostId] from the durable local
  /// snapshot and enqueues a sync op BEFORE any network attempt. A delayed
  /// API response can never resurrect the removed job.
  Future<Either<Failure, bool>> setUnsavedJob(int jobPostId);

  /// Durable locally-known saved list (source of truth for instant UI).
  Future<List<SavedJobEntity>> getLocalSavedJobs();

  /// Durably queued save/unsave operations, oldest first.
  Future<List<SavedJobSyncOp>> getPendingOps();

  /// Replays due queued ops in order with bounded exponential backoff.
  /// Never marks an op synchronized before server confirmation; failed
  /// ops stay queued; stops (keeping the remainder) on auth expiry.
  Future<SavedJobsSyncReport> syncPendingOps();
}
