import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/networking/network_info.dart';
import 'package:MatchIn/features/roadmap/data/data_sources/roadmap_local_data_source.dart';
import 'package:MatchIn/features/roadmap/data/data_sources/roadmap_remote_data_source.dart';
import 'package:MatchIn/features/roadmap/data/models/candidate_xp_model.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_model.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_sync_op.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_task_model.dart';
import 'package:MatchIn/features/roadmap/domain/entities/award_xp_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/award_xp_response_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/candidate_xp_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/complete_roadmap_task_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/generate_roadmap_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/paginated_roadmaps_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_pagination_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/refresh_roadmap_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_sync_report.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_task.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_xp_metrics_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmaps_params.dart';
import 'package:MatchIn/features/roadmap/domain/repositories/roadmap_repository.dart';
import 'package:dartz/dartz.dart';

/// Offline-first repository: reads prefer cache with network refresh,
/// mutations apply locally + enqueue durable ops when offline and sync
/// when connectivity returns. Failed ops stay queued with backoff
/// metadata and are never silently discarded.
class RoadmapRepositoryImpl implements RoadmapRepository {
  const RoadmapRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  final RoadmapRemoteDataSource remoteDataSource;
  final RoadmapLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<List<RoadmapEntity>?> getCachedRoadmaps() async {
    return localDataSource.getCachedRoadmaps();
  }

  @override
  Future<RoadmapEntity?> getCachedRoadmapDetails(int roadmapId) async {
    return localDataSource.getCachedRoadmapDetails(roadmapId);
  }

  @override
  Future<Either<Failure, PaginatedRoadmapsEntity>> getRoadmaps({
    RoadmapsParams? params,
  }) async {
    if (!await networkInfo.isConnected) {
      final cached = await localDataSource.getCachedRoadmaps();
      if (cached != null && cached.isNotEmpty) {
        return Right(_pageFromCache(cached));
      }
      return const Left(OfflineFailure());
    }

    try {
      final result = await remoteDataSource.getRoadmaps(params: params);
      await localDataSource.cacheRoadmaps(result.roadmaps);

      return Right(
        PaginatedRoadmapsEntity(
          roadmaps: result.roadmaps,
          pagination: result.pagination.toEntity(),
        ),
      );
    } on ServerException catch (e) {
      final cached = await localDataSource.getCachedRoadmaps();
      if (cached != null && cached.isNotEmpty) {
        return Right(_pageFromCache(cached));
      }
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      final cached = await localDataSource.getCachedRoadmaps();
      if (cached != null && cached.isNotEmpty) {
        return Right(_pageFromCache(cached));
      }
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RoadmapEntity>> getRoadmapDetails(
    int roadmapId,
  ) async {
    if (!await networkInfo.isConnected) {
      final cached = await localDataSource.getCachedRoadmapDetails(roadmapId);
      if (cached != null) return Right(cached);
      return const Left(OfflineFailure());
    }

    try {
      final roadmap = await remoteDataSource.getRoadmapDetails(roadmapId);
      await localDataSource.cacheRoadmapDetails(roadmap);

      return Right(roadmap);
    } on ServerException catch (e) {
      final cached = await localDataSource.getCachedRoadmapDetails(roadmapId);
      if (cached != null) return Right(cached);
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      final cached = await localDataSource.getCachedRoadmapDetails(roadmapId);
      if (cached != null) return Right(cached);
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RoadmapEntity>> generateRoadmap(
    GenerateRoadmapParams params,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }

    try {
      final roadmap = await remoteDataSource.generateRoadmap(params);
      await _persistGeneratedRoadmap(roadmap);

      return Right(roadmap);
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
  }

  @override
  Future<Either<Failure, RoadmapTask>> completeRoadmapTask(
    CompleteRoadmapTaskParams params,
  ) async {
    return completeTaskOfflineFirst(roadmapId: null, params: params);
  }

  @override
  Future<Either<Failure, RoadmapTask>> completeTaskOfflineFirst({
    required int? roadmapId,
    required CompleteRoadmapTaskParams params,
  }) async {
    final targetRoadmapId = roadmapId ?? params.roadmapId;
    if (!await networkInfo.isConnected) {
      return _completeOffline(roadmapId: targetRoadmapId, params: params);
    }

    try {
      final task = await remoteDataSource.completeRoadmapTask(params);
      await localDataSource.removeOp(
        RoadmapSyncOp.completeTaskKey(params.taskId),
      );
      if (targetRoadmapId != null) {
        await localDataSource.applyServerTask(
          roadmapId: targetRoadmapId,
          taskId: task.id,
          isCompleted: task.isCompleted,
          completedAt: task.completedAt,
        );
      }

      return Right(task);
    } on ServerException catch (e) {
      if (_isAlreadyApplied(e)) {
        // Idempotent retry: the server already holds this completion.
        await localDataSource.removeOp(
          RoadmapSyncOp.completeTaskKey(params.taskId),
        );
        if (targetRoadmapId != null) {
          await _reconcileDetails(targetRoadmapId);
          final cached = await localDataSource.getCachedRoadmapDetails(
            targetRoadmapId,
          );
          final confirmed = _findTask(cached, params.taskId);
          if (confirmed != null) return Right(confirmed);
        }
        return Right(
          RoadmapTaskModel(id: params.taskId, title: '', isCompleted: true),
        );
      }
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<RoadmapTask?> applyLocalCompletion({
    required int roadmapId,
    required int taskId,
  }) async {
    try {
      final updated = await localDataSource.markTaskCompletedLocally(
        roadmapId: roadmapId,
        taskId: taskId,
      );
      return _findTask(updated, taskId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> revertLocalCompletion({
    required int roadmapId,
    required int taskId,
  }) async {
    try {
      await localDataSource.revertTaskCompletionLocally(
        roadmapId: roadmapId,
        taskId: taskId,
      );
    } catch (_) {
      // Best effort: the next authoritative fetch self-heals the cache.
    }
  }

  @override
  Future<Either<Failure, RoadmapEntity>> refreshRoadmap(
    RefreshRoadmapParams params,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(OfflineFailure());
    }

    try {
      final roadmap = await remoteDataSource.refreshRoadmap(params);
      await _persistGeneratedRoadmap(roadmap);

      return Right(roadmap);
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
  }

  @override
  Future<Either<Failure, CandidateXpEntity>> getCandidateXp({
    int? roadmapId,
  }) async {
    if (!await networkInfo.isConnected) {
      final cached = await localDataSource.getCachedCandidateXp();
      if (cached != null) return Right(cached);
      return const Left(OfflineFailure());
    }

    try {
      final xp = await remoteDataSource.getCandidateXp(roadmapId: roadmapId);
      await localDataSource.cacheCandidateXp(xp);
      return Right(xp);
    } on ServerException catch (e) {
      final cached = await localDataSource.getCachedCandidateXp();
      if (cached != null) return Right(cached);
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      final cached = await localDataSource.getCachedCandidateXp();
      if (cached != null) return Right(cached);
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RoadmapXpMetricsEntity>> getRoadmapXp(
    int roadmapId,
  ) async {
    if (!await networkInfo.isConnected) {
      final cached = await localDataSource.getCachedRoadmapXp(roadmapId);
      if (cached != null) return Right(cached);
      return const Left(OfflineFailure());
    }

    try {
      final xp = await remoteDataSource.getRoadmapXp(roadmapId);
      await localDataSource.cacheRoadmapXp(xp);
      return Right(xp);
    } on ServerException catch (e) {
      final cached = await localDataSource.getCachedRoadmapXp(roadmapId);
      if (cached != null) return Right(cached);
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      final cached = await localDataSource.getCachedRoadmapXp(roadmapId);
      if (cached != null) return Right(cached);
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AwardXpResponseEntity>> awardXp(
    AwardXpParams params, {
    required String opKey,
  }) async {
    if (!await networkInfo.isConnected) {
      await _enqueueAwardOp(params, opKey);
      return const Left(OfflineFailure());
    }

    try {
      final response = await remoteDataSource.awardXp(params);
      await _applyAwardSuccess(params, opKey, response.earnedXp);
      return Right(response);
    } on ServerException catch (e) {
      if (_isAlreadyApplied(e)) {
        await _applyAwardSuccess(params, opKey, null);
        return Right(_alreadyAwardedProjection(params));
      }
      return Left(
        ServerFailure(
          message: e.errorModel.errorMessage,
          fieldErrors: e.errorModel.fieldErrors,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<List<RoadmapSyncOp>> getPendingOps() {
    return localDataSource.getPendingOps();
  }

  @override
  Future<RoadmapSyncReport> syncPendingOps() async {
    final ops = await localDataSource.getPendingOps();
    if (ops.isEmpty) return const RoadmapSyncReport();
    if (!await networkInfo.isConnected) {
      return RoadmapSyncReport(remaining: ops.length);
    }

    var succeeded = 0;
    var failed = 0;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    for (final op in ops) {
      if (!op.isDue(nowMs)) continue;
      if (!await networkInfo.isConnected) break;
      final ok = await _syncOne(op);
      if (ok == null) {
        // Auth expiry: stop the pass, keep the remainder queued.
        final remaining = await localDataSource.getPendingOps();
        return RoadmapSyncReport(
          succeeded: succeeded,
          failed: failed,
          remaining: remaining.length,
          stoppedForAuth: true,
        );
      }
      if (ok) {
        succeeded++;
      } else {
        failed++;
      }
    }
    final remaining = await localDataSource.getPendingOps();
    return RoadmapSyncReport(
      succeeded: succeeded,
      failed: failed,
      remaining: remaining.length,
    );
  }

  @override
  Future<Set<int>> getCollectedTreasures(int roadmapId) {
    return localDataSource.getCollectedTreasures(roadmapId);
  }

  @override
  Future<void> collectTreasure(int roadmapId, int milestoneIndex) async {
    final collected = await localDataSource.getCollectedTreasures(roadmapId);
    final updated = Set<int>.of(collected)..add(milestoneIndex);
    await localDataSource.saveCollectedTreasures(roadmapId, updated);
  }

  @override
  Future<Set<int>> getSyncedTreasures(int roadmapId) {
    return localDataSource.getSyncedTreasures(roadmapId);
  }

  //! ===== Private helpers =====

  PaginatedRoadmapsEntity _pageFromCache(List<RoadmapModel> cached) {
    return PaginatedRoadmapsEntity(
      roadmaps: cached,
      pagination: _cachedPagination(total: cached.length),
    );
  }

  Future<void> _persistGeneratedRoadmap(RoadmapModel roadmap) async {
    await localDataSource.cacheRoadmapDetails(roadmap);
    final cached = await localDataSource.getCachedRoadmaps();
    final list = List<RoadmapModel>.of(cached ?? const []);
    final index = list.indexWhere((e) => e.id == roadmap.id);
    if (index >= 0) {
      list[index] = roadmap;
    } else {
      list.insert(0, roadmap);
    }
    await localDataSource.cacheRoadmaps(list);
  }

  Future<Either<Failure, RoadmapTask>> _completeOffline({
    required int? roadmapId,
    required CompleteRoadmapTaskParams params,
  }) async {
    final payload = <String, dynamic>{'taskId': params.taskId};
    final targetRoadmapId = roadmapId;
    if (targetRoadmapId != null) payload['roadmapId'] = targetRoadmapId;
    final note = params.completionNote;
    if (note != null) payload['completionNote'] = note;
    await localDataSource.enqueueOp(
      RoadmapSyncOp(
        opKey: RoadmapSyncOp.completeTaskKey(params.taskId),
        type: RoadmapSyncOp.typeCompleteTask,
        payload: payload,
        createdAtMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    if (roadmapId != null) {
      final updated = await localDataSource.markTaskCompletedLocally(
        roadmapId: roadmapId,
        taskId: params.taskId,
      );
      final task = _findTask(updated, params.taskId);
      if (task != null) return Right(task);
    }
    return const Left(OfflineFailure());
  }

  Future<void> _reconcileDetails(int roadmapId) async {
    try {
      final fresh = await remoteDataSource.getRoadmapDetails(roadmapId);
      await localDataSource.cacheRoadmapDetails(fresh);
    } catch (_) {
      // Best effort: sync already holds the authoritative task state.
    }
  }

  RoadmapTask? _findTask(RoadmapEntity? roadmap, int taskId) {
    if (roadmap == null) return null;
    for (final milestone in roadmap.milestones) {
      for (final task in milestone.tasks) {
        if (task.id == taskId) return task;
      }
    }
    return null;
  }

  bool _isAlreadyApplied(ServerException e) {
    final message = e.errorModel.errorMessage.toLowerCase();
    if (e.errorModel.statusCode == 422 && message.contains('already')) {
      return true;
    }
    for (final messages in e.errorModel.fieldErrors.values) {
      for (final detail in messages) {
        if (detail.toLowerCase().contains('already')) return true;
      }
    }
    return false;
  }

  bool _isAuthError(ServerException e) {
    return e.errorModel.statusCode == 401 || e.errorModel.statusCode == 403;
  }

  Future<void> _enqueueAwardOp(AwardXpParams params, String opKey) async {
    await localDataSource.enqueueOp(
      RoadmapSyncOp(
        opKey: opKey,
        type: RoadmapSyncOp.typeAwardXp,
        payload: params.toJson(),
        createdAtMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Future<void> _applyAwardSuccess(
    AwardXpParams params,
    String opKey,
    int? earnedXp,
  ) async {
    await localDataSource.removeOp(opKey);
    final treasure = _treasureFromOpKey(opKey);
    if (treasure != null) {
      final synced = await localDataSource.getSyncedTreasures(
        treasure.roadmapId,
      );
      await localDataSource.saveSyncedTreasures(
        treasure.roadmapId,
        Set<int>.of(synced)..add(treasure.milestoneIndex),
      );
    }
    if (earnedXp != null) {
      final cached = await localDataSource.getCachedCandidateXp();
      final updated = CandidateXpModel(
        userId: cached?.userId,
        totalXp: earnedXp,
        level: cached?.level ?? 1,
        levelTitle: cached?.levelTitle ?? '',
        currentLevelXp: cached?.currentLevelXp ?? 0,
        nextLevelXp: cached?.nextLevelXp ?? 100,
        xpToNextLevel: cached?.xpToNextLevel ?? 100,
        progressPercentage: cached?.progressPercentage ?? 0.0,
      );
      await localDataSource.cacheCandidateXp(updated);
    }
    try {
      final fresh = await remoteDataSource.getCandidateXp();
      await localDataSource.cacheCandidateXp(fresh);
    } catch (_) {
      // Best effort: authoritative totals arrive on the next XP fetch.
    }
  }

  AwardXpResponseEntity _alreadyAwardedProjection(AwardXpParams params) {
    return AwardXpResponseEntity(
      xpAdded: 0,
      earnedXp: 0,
      roadmapId: params.roadmapId,
      reason: params.reason,
    );
  }

  ({int roadmapId, int milestoneIndex})? _treasureFromOpKey(String opKey) {
    // Stable key format: treasure_<roadmapId>_<milestoneIndex>.
    final parts = opKey.split('_');
    if (parts.length != 3 || parts.first != 'treasure') return null;
    final roadmapId = int.tryParse(parts[1]);
    final milestoneIndex = int.tryParse(parts[2]);
    if (roadmapId == null || milestoneIndex == null) return null;
    return (roadmapId: roadmapId, milestoneIndex: milestoneIndex);
  }

  /// Returns true on success, false on a (queued) failure, null when the
  /// pass must stop for an expired session.
  Future<bool?> _syncOne(RoadmapSyncOp op) async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    try {
      if (op.type == RoadmapSyncOp.typeCompleteTask) {
        final taskId = (op.payload['taskId'] as num?)?.toInt();
        if (taskId == null) {
          await localDataSource.removeOp(op.opKey);
          return true;
        }
        final note = op.payload['completionNote']?.toString();
        await remoteDataSource.completeRoadmapTask(
          CompleteRoadmapTaskParams(taskId: taskId, completionNote: note),
        );
        final roadmapId = (op.payload['roadmapId'] as num?)?.toInt();
        if (roadmapId != null) await _reconcileDetails(roadmapId);
        await localDataSource.removeOp(op.opKey);
        return true;
      }
      if (op.type == RoadmapSyncOp.typeAwardXp) {
        final xp = (op.payload['xp'] as num?)?.toInt();
        final reason = op.payload['reason']?.toString();
        if (xp == null || reason == null) {
          await localDataSource.removeOp(op.opKey);
          return true;
        }
        final response = await remoteDataSource.awardXp(
          AwardXpParams(
            xp: xp,
            reason: reason,
            roadmapId: (op.payload['roadmap_id'] as num?)?.toInt(),
            taskId: (op.payload['task_id'] as num?)?.toInt(),
            milestoneId: (op.payload['milestone_id'] as num?)?.toInt(),
          ),
        );
        await _applyAwardSuccess(
          AwardXpParams(xp: xp, reason: reason),
          op.opKey,
          response.earnedXp,
        );
        return true;
      }
      // Unknown op type: drop it so one bad entry cannot block the queue.
      await localDataSource.removeOp(op.opKey);
      return true;
    } on ServerException catch (e) {
      if (_isAuthError(e)) return null;
      if (_isAlreadyApplied(e)) {
        // Idempotent duplicate: verify server state, then clear.
        if (op.type == RoadmapSyncOp.typeCompleteTask) {
          final roadmapId = (op.payload['roadmapId'] as num?)?.toInt();
          if (roadmapId != null) await _reconcileDetails(roadmapId);
        } else {
          await _applyAwardSuccess(
            const AwardXpParams(xp: 0, reason: 'duplicate'),
            op.opKey,
            null,
          );
        }
        await localDataSource.removeOp(op.opKey);
        return true;
      }
      await localDataSource.updateOp(op.withAttempt(nowMs));
      return false;
    } catch (_) {
      await localDataSource.updateOp(op.withAttempt(nowMs));
      return false;
    }
  }
  //! ===== Cache pagination =====

  // --- Cached list snapshots have no server pagination metadata, so a
  // --- single-page envelope is synthesized (never invents page counts). ---
  RoadmapPaginationEntity _cachedPagination({required int total}) {
    return RoadmapPaginationEntity(
      currentPage: 1,
      lastPage: 1,
      perPage: total == 0 ? 15 : total,
      total: total,
    );
  }
}
