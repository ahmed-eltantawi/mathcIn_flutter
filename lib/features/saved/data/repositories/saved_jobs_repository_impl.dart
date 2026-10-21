import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/networking/network_info.dart';
import 'package:MatchIn/features/saved/data/data_sources/saved_jobs_local_data_source.dart';
import 'package:MatchIn/features/saved/data/data_sources/saved_jobs_remote_data_source.dart';
import 'package:MatchIn/features/saved/data/models/paginated_saved_jobs_model.dart';
import 'package:MatchIn/features/saved/data/models/saved_job_response_model.dart';
import 'package:MatchIn/features/saved/data/models/saved_job_sync_op.dart';
import 'package:MatchIn/features/saved/domain/entities/paginated_saved_jobs_entity.dart';
import 'package:MatchIn/features/saved/domain/entities/saved_job_entity.dart';
import 'package:MatchIn/features/saved/domain/entities/saved_jobs_sync_report.dart';
import 'package:MatchIn/features/saved/domain/repositories/saved_jobs_repository.dart';
import 'package:dartz/dartz.dart';

/// Offline-first saved-jobs repository.
///
/// The durable local snapshot is the source of truth for instant UI:
/// mutations persist + enqueue BEFORE any network attempt, so offline
/// taps never lose user intent. Server responses only confirm queued ops
/// and can never resurrect a newer local unsave.
class SavedJobsRepositoryImpl implements SavedJobsRepository {
  const SavedJobsRepositoryImpl({
    required this.remoteDataSource,
    this.localDataSource,
    required this.networkInfo,
  });

  final SavedJobsRemoteDataSource remoteDataSource;
  final SavedJobsLocalDataSource? localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, PaginatedSavedJobsEntity>> getSavedJobs({
    int page = 1,
    int perPage = 15,
  }) async {
    final cacheKey = 'page_${page}_per_page_$perPage';

    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getSavedJobs(
          page: page,
          perPage: perPage,
        );
        final overlaid = await _overlayPending(result, page: page);
        if (localDataSource != null) {
          await localDataSource!.cacheSavedJobs(cacheKey, overlaid);
        }
        return Right(overlaid);
      } on ServerException catch (e) {
        final fallback = await _snapshotFallback(page: page);
        if (fallback != null) return Right(fallback);
        return Left(
          ServerFailure(
            message: e.errorModel.errorMessage,
            fieldErrors: e.errorModel.fieldErrors,
          ),
        );
      } catch (e) {
        final fallback = await _snapshotFallback(page: page);
        if (fallback != null) return Right(fallback);
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      final fallback = await _snapshotFallback(page: page);
      if (fallback != null) return Right(fallback);
      return const Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> saveJob({required int jobPostId}) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.saveJob(jobPostId: jobPostId);
        return Right(result.isSaved);
      } on ServerException catch (e) {
        return Left(
          ServerFailure(
            message: e.errorModel.errorMessage,
            fieldErrors: e.errorModel.fieldErrors,
          ),
        );
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> unsaveJob({required int jobPostId}) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.unsaveJob(jobPostId: jobPostId);
        if (localDataSource != null) {
          await localDataSource!.removeSavedJob(jobPostId);
        }
        return Right(result.isSaved);
      } on ServerException catch (e) {
        return Left(
          ServerFailure(
            message: e.errorModel.errorMessage,
            fieldErrors: e.errorModel.fieldErrors,
          ),
        );
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> setSavedJob(SavedJobEntity job) async {
    final local = localDataSource;
    if (local == null) {
      return saveJob(jobPostId: job.id);
    }
    try {
      // 1. Persist locally first — UI reads this immediately.
      await local.upsertSavedJob(_toModel(job));
      // 2. Queue durably (replaces older intents for the same job).
      await local.enqueueOp(
        SavedJobSyncOp(
          opKey: SavedJobSyncOp.keyFor(job.id),
          type: SavedJobSyncOp.typeSave,
          jobPostId: job.id,
          createdAtMs: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
    // 3. Best-effort immediate sync; failures stay queued for retry.
    await _bestEffortSyncOne(job.id);
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> setUnsavedJob(int jobPostId) async {
    final local = localDataSource;
    if (local == null) {
      return unsaveJob(jobPostId: jobPostId);
    }
    try {
      // 1. Remove locally first — a delayed response can never undo this.
      await local.removeSavedJob(jobPostId);
      // 2. Queue durably (replaces older intents for the same job).
      await local.enqueueOp(
        SavedJobSyncOp(
          opKey: SavedJobSyncOp.keyFor(jobPostId),
          type: SavedJobSyncOp.typeUnsave,
          jobPostId: jobPostId,
          createdAtMs: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
    // 3. Best-effort immediate sync; failures stay queued for retry.
    await _bestEffortSyncOne(jobPostId);
    return const Right(false);
  }

  @override
  Future<List<SavedJobEntity>> getLocalSavedJobs() async {
    final local = localDataSource;
    if (local == null) return const [];
    return local.getLocalSavedJobs();
  }

  @override
  Future<List<SavedJobSyncOp>> getPendingOps() async {
    final local = localDataSource;
    if (local == null) return const [];
    return local.getPendingOps();
  }

  @override
  Future<SavedJobsSyncReport> syncPendingOps() async {
    final local = localDataSource;
    if (local == null) return const SavedJobsSyncReport();
    final ops = await local.getPendingOps();
    if (ops.isEmpty) return const SavedJobsSyncReport();
    if (!await networkInfo.isConnected) {
      return SavedJobsSyncReport(remaining: ops.length);
    }

    var succeeded = 0;
    var failed = 0;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    for (final op in ops) {
      if (!op.isDue(nowMs)) continue;
      if (!await networkInfo.isConnected) break;
      final outcome = await _syncOne(op);
      if (outcome == null) {
        final remaining = await local.getPendingOps();
        return SavedJobsSyncReport(
          succeeded: succeeded,
          failed: failed,
          remaining: remaining.length,
          stoppedForAuth: true,
        );
      }
      if (outcome) {
        succeeded++;
      } else {
        failed++;
      }
    }
    final remaining = await local.getPendingOps();
    return SavedJobsSyncReport(
      succeeded: succeeded,
      failed: failed,
      remaining: remaining.length,
    );
  }

  //! ===== Private helpers =====

  SavedJobResponseModel _toModel(SavedJobEntity job) {
    if (job is SavedJobResponseModel) return job;
    return SavedJobResponseModel(
      id: job.id,
      title: job.title,
      company: job.company,
      companyLogoUrl: job.companyLogoUrl,
      companyEntity: job.companyEntity,
      location: job.location,
      workMode: job.workMode,
      experience: job.experience,
      jobType: job.jobType,
      postedDate: job.postedDate,
      skills: job.skills,
      requiredSkills: job.requiredSkills,
      preferredSkills: job.preferredSkills,
      isExpired: job.isExpired,
      matchPercentage: job.matchPercentage,
      isSaved: true,
    );
  }

  /// Overlays durable pending intentions over a server page so the UI
  /// never shows a stale save state: unsave-pending ids are removed
  /// everywhere; save-pending jobs missing from page 1 are restored from
  /// the local snapshot.
  Future<PaginatedSavedJobsModel> _overlayPending(
    PaginatedSavedJobsModel server, {
    required int page,
  }) async {
    final local = localDataSource;
    if (local == null) return server;
    final ops = await local.getPendingOps();
    if (ops.isEmpty) return server;

    final unsaveIds = ops
        .where((op) => op.type == SavedJobSyncOp.typeUnsave)
        .map((op) => op.jobPostId)
        .toSet();
    final saveIds = ops
        .where((op) => op.type == SavedJobSyncOp.typeSave)
        .map((op) => op.jobPostId)
        .toSet();

    final jobs = server.jobs
        .where((job) => !unsaveIds.contains(job.id))
        .toList();
    var addedSaves = 0;
    if (page == 1 && saveIds.isNotEmpty) {
      final present = jobs.map((job) => job.id).toSet();
      final snapshot = await local.getLocalSavedJobs();
      for (final saved in snapshot) {
        if (saveIds.contains(saved.id) && !present.contains(saved.id)) {
          jobs.insert(0, saved);
          addedSaves++;
        }
      }
    }
    final removedUnsaves = server.jobs.length - jobs.length + addedSaves;
    return PaginatedSavedJobsModel(
      jobs: jobs,
      currentPage: server.currentPage,
      lastPage: server.lastPage,
      total: server.total + addedSaves - removedUnsaves,
      hasMorePages: server.hasMorePages,
    );
  }

  Future<PaginatedSavedJobsModel?> _snapshotFallback({
    required int page,
  }) async {
    final local = localDataSource;
    if (local == null) return null;
    if (page == 1) {
      // The primary snapshot is the durable source of truth: it already
      // contains locally saved jobs and excludes locally unsaved ones.
      final jobs = await local.getLocalSavedJobs();
      if (jobs.isEmpty) return null;
      return PaginatedSavedJobsModel(
        jobs: jobs,
        currentPage: 1,
        lastPage: 1,
        total: jobs.length,
        hasMorePages: false,
      );
    }
    final cached = await local.getCachedSavedJobs('page_${page}_per_page_15');
    if (cached != null && cached.jobs.isNotEmpty) return cached;
    return null;
  }

  /// Attempts to sync a single job's queued op right away. Any failure
  /// (including offline) leaves the op queued with backoff metadata —
  /// callers never treat this as an error.
  Future<void> _bestEffortSyncOne(int jobPostId) async {
    try {
      if (!await networkInfo.isConnected) return;
      final local = localDataSource;
      if (local == null) return;
      final ops = await local.getPendingOps();
      for (final op in ops) {
        if (op.jobPostId != jobPostId || !op.isDue(_nowMs())) continue;
        await _syncOne(op);
      }
    } catch (_) {
      // Best effort only: the durable queue + background sync own retries.
    }
  }

  int _nowMs() => DateTime.now().millisecondsSinceEpoch;

  bool _isAuthError(ServerException e) {
    return e.errorModel.statusCode == 401 || e.errorModel.statusCode == 403;
  }

  bool _isAlreadyApplied(ServerException e, {required bool saving}) {
    final message = e.errorModel.errorMessage.toLowerCase();
    if (message.contains('already') || message.contains('not found')) {
      return true;
    }
    for (final messages in e.errorModel.fieldErrors.values) {
      for (final detail in messages) {
        final normalized = detail.toLowerCase();
        if (normalized.contains('already') ||
            normalized.contains('not found')) {
          return true;
        }
      }
    }
    // 404 on unsave (or save) means the desired end-state already holds.
    if (e.errorModel.statusCode == 404) return true;
    // Duplicate 422 on save means the bookmark already exists server-side.
    if (saving && e.errorModel.statusCode == 422) return true;
    return false;
  }

  /// Returns true on success, false on a (queued) failure, null when the
  /// pass must stop for an expired session.
  Future<bool?> _syncOne(SavedJobSyncOp op) async {
    final local = localDataSource;
    if (local == null) return true;
    final nowMs = _nowMs();
    try {
      if (op.type == SavedJobSyncOp.typeSave) {
        await remoteDataSource.saveJob(jobPostId: op.jobPostId);
        await local.removeOp(op.opKey);
        return true;
      }
      if (op.type == SavedJobSyncOp.typeUnsave) {
        await remoteDataSource.unsaveJob(jobPostId: op.jobPostId);
        await local.removeOp(op.opKey);
        return true;
      }
      // Unknown op type: drop it so one bad entry cannot block the queue.
      await local.removeOp(op.opKey);
      return true;
    } on ServerException catch (e) {
      if (_isAuthError(e)) return null;
      if (_isAlreadyApplied(e, saving: op.type == SavedJobSyncOp.typeSave)) {
        await local.removeOp(op.opKey);
        return true;
      }
      await local.updateOp(op.withAttempt(nowMs));
      return false;
    } catch (_) {
      await local.updateOp(op.withAttempt(nowMs));
      return false;
    }
  }
}
