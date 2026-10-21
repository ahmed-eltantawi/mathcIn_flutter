import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_sync_op.dart';
import 'package:MatchIn/features/roadmap/domain/entities/award_xp_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/award_xp_response_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/candidate_xp_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/complete_roadmap_task_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/generate_roadmap_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/paginated_roadmaps_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/refresh_roadmap_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_sync_report.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_task.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_xp_metrics_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmaps_params.dart';
import 'package:dartz/dartz.dart';

abstract class RoadmapRepository {
  Future<Either<Failure, PaginatedRoadmapsEntity>> getRoadmaps({
    RoadmapsParams? params,
  });

  Future<Either<Failure, RoadmapEntity>> getRoadmapDetails(int roadmapId);

  /// Generates a personalized AI roadmap (HTTP 201). Remote-only.
  /// Validation (422) and rate-limit (429) failures surface through
  /// [Failure] with the server message preserved.
  Future<Either<Failure, RoadmapEntity>> generateRoadmap(
    GenerateRoadmapParams params,
  );

  /// Marks a roadmap task completed (HTTP 200). Remote-only.
  /// [CompleteRoadmapTaskParams.taskId] is the backend task id.
  /// Validation (422) and duplicate-completion failures surface through
  /// [Failure] with the server message preserved.
  Future<Either<Failure, RoadmapTask>> completeRoadmapTask(
    CompleteRoadmapTaskParams params,
  );

  /// Refreshes a roadmap with AI (HTTP 200). Remote-only.
  /// [RefreshRoadmapParams.roadmapId] selects the roadmap; the returned
  /// roadmap is authoritative and may carry a different id.
  Future<Either<Failure, RoadmapEntity>> refreshRoadmap(
    RefreshRoadmapParams params,
  );

  /// Durable cache reads for instant first paint (never throws: the
  /// local data source returns null on corrupt payloads).
  Future<List<RoadmapEntity>?> getCachedRoadmaps();

  Future<RoadmapEntity?> getCachedRoadmapDetails(int roadmapId);

  /// Offline-first task completion: online it completes remotely and
  /// persists the authoritative response; offline it applies the change
  /// to the local cache, enqueues a durable sync op, and returns a local
  /// completed projection so the UI updates immediately.
  Future<Either<Failure, RoadmapTask>> completeTaskOfflineFirst({
    required int? roadmapId,
    required CompleteRoadmapTaskParams params,
  });

  /// Applies an optimistic completion to the durable local cache and
  /// returns the local projection, or null when no cached roadmap holds
  /// the task. Callers paint from local truth immediately, then confirm
  /// through [completeTaskOfflineFirst] and roll back via
  /// [revertLocalCompletion] on confirmed failure.
  Future<RoadmapTask?> applyLocalCompletion({
    required int roadmapId,
    required int taskId,
  });

  /// Rolls back an optimistic completion after a confirmed failure.
  /// Never touches tasks that were already completed beforehand.
  Future<void> revertLocalCompletion({
    required int roadmapId,
    required int taskId,
  });

  /// Candidate-wide XP (`GET /roadmaps/xp`): authoritative when online
  /// (cached on success), cached values while offline.
  Future<Either<Failure, CandidateXpEntity>> getCandidateXp({int? roadmapId});

  /// Per-roadmap XP metrics (`GET /roadmaps/{roadmap}/xp`): authoritative
  /// when online (cached on success), cached values while offline.
  Future<Either<Failure, RoadmapXpMetricsEntity>> getRoadmapXp(int roadmapId);

  /// Awards XP through the canonical `PATCH /roadmaps/xp` route.
  /// Online: performs the request and refreshes cached XP data.
  /// Offline: enqueues a durable op keyed by [opKey] and returns
  /// [OfflineFailure] so callers never treat it as confirmed XP.
  Future<Either<Failure, AwardXpResponseEntity>> awardXp(
    AwardXpParams params, {
    required String opKey,
  });

  /// Durable pending-sync queue inspection (ordered oldest-first).
  Future<List<RoadmapSyncOp>> getPendingOps();

  /// Replays due queued ops in order: never marks an op synchronized
  /// before server confirmation, keeps failed ops queued with backoff
  /// metadata, and stops (keeping the remainder queued) on auth expiry.
  Future<RoadmapSyncReport> syncPendingOps();

  /// Per-roadmap treasure reward ledger (durable, survives restarts).
  Future<Set<int>> getCollectedTreasures(int roadmapId);

  Future<void> collectTreasure(int roadmapId, int milestoneIndex);

  /// Milestone indices whose +50 XP award the server already confirmed.
  Future<Set<int>> getSyncedTreasures(int roadmapId);
}
