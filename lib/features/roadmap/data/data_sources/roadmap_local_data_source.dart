import 'package:MatchIn/features/roadmap/data/models/candidate_xp_model.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_model.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_sync_op.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_xp_metrics_model.dart';

/// Durable local persistence for the offline-first roadmap feature.
///
/// Backed by [SharedPreferencesHelper] JSON blobs (same approach as the
/// jobs/profile local data sources): data survives restarts, process
/// death, and reboots. All reads tolerate corrupt payloads by returning
/// null/empty instead of throwing.
abstract class RoadmapLocalDataSource {
  Future<List<RoadmapModel>?> getCachedRoadmaps();

  Future<void> cacheRoadmaps(List<RoadmapModel> roadmaps);

  Future<RoadmapModel?> getCachedRoadmapDetails(int roadmapId);

  Future<void> cacheRoadmapDetails(RoadmapModel roadmap);

  /// Marks [taskId] completed inside the cached details of [roadmapId].
  /// Returns the updated roadmap, or null when nothing was cached.
  Future<RoadmapModel?> markTaskCompletedLocally({
    required int roadmapId,
    required int taskId,
  });

  /// Rolls back an optimistic local completion after a confirmed
  /// request failure. Never touches tasks that were already completed
  /// before the optimistic mark.
  Future<RoadmapModel?> revertTaskCompletionLocally({
    required int roadmapId,
    required int taskId,
  });

  /// Applies the authoritative server task state to the cached details
  /// of [roadmapId] without touching newer local pending changes for
  /// other tasks. Returns the updated roadmap, or null when the task or
  /// cached roadmap is unknown.
  Future<RoadmapModel?> applyServerTask({
    required int roadmapId,
    required int taskId,
    required bool isCompleted,
    String? completedAt,
  });

  Future<List<RoadmapSyncOp>> getPendingOps();

  /// Inserts [op], replacing any queued op with the same [opKey]
  /// (stable deduplication key) to avoid duplicate mutations.
  Future<void> enqueueOp(RoadmapSyncOp op);

  Future<void> removeOp(String opKey);

  Future<void> updateOp(RoadmapSyncOp op);

  Future<void> clearOps();

  Future<Set<int>> getCollectedTreasures(int roadmapId);

  Future<void> saveCollectedTreasures(int roadmapId, Set<int> collected);

  /// Milestone indices whose +50 XP award was confirmed by the server.
  Future<Set<int>> getSyncedTreasures(int roadmapId);

  Future<void> saveSyncedTreasures(int roadmapId, Set<int> synced);

  Future<CandidateXpModel?> getCachedCandidateXp();

  Future<void> cacheCandidateXp(CandidateXpModel xp);

  Future<RoadmapXpMetricsModel?> getCachedRoadmapXp(int roadmapId);

  Future<void> cacheRoadmapXp(RoadmapXpMetricsModel xp);
}
