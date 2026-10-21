import 'dart:convert';

import 'package:MatchIn/core/cache/cache_key.dart';
import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/features/roadmap/data/data_sources/roadmap_local_data_source.dart';
import 'package:MatchIn/features/roadmap/data/models/candidate_xp_model.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_milestone_model.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_model.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_sync_op.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_task_model.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_xp_metrics_model.dart';

class RoadmapLocalDataSourceImpl implements RoadmapLocalDataSource {
  const RoadmapLocalDataSourceImpl({required this.sharedPreferencesHelper});

  final SharedPreferencesHelper sharedPreferencesHelper;

  String _detailsKey(int roadmapId) =>
      '${CacheKey.cachedRoadmapDetailsPrefix}$roadmapId';

  String _treasureKey(int roadmapId) => 'treasure_ledger_$roadmapId';

  String _syncedTreasureKey(int roadmapId) => 'treasure_synced_$roadmapId';

  String _roadmapXpKey(int roadmapId) =>
      '${CacheKey.roadmapXpPrefix}$roadmapId';

  String _queueKey() => '${CacheKey.roadmapSyncQueuePrefix}v1';

  @override
  Future<List<RoadmapModel>?> getCachedRoadmaps() async {
    final raw = sharedPreferencesHelper.getString(key: CacheKey.cachedRoadmaps);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      final roadmaps = <RoadmapModel>[];
      for (final entry in decoded) {
        if (entry is! Map<String, dynamic>) continue;
        try {
          roadmaps.add(RoadmapModel.fromJson(entry));
        } catch (_) {
          continue;
        }
      }
      return roadmaps;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheRoadmaps(List<RoadmapModel> roadmaps) async {
    final raw = jsonEncode(roadmaps.map((r) => r.toJson()).toList());
    await sharedPreferencesHelper.saveData(
      key: CacheKey.cachedRoadmaps,
      value: raw,
    );
  }

  @override
  Future<RoadmapModel?> getCachedRoadmapDetails(int roadmapId) async {
    final raw = sharedPreferencesHelper.getString(key: _detailsKey(roadmapId));
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return RoadmapModel.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheRoadmapDetails(RoadmapModel roadmap) async {
    final raw = jsonEncode(roadmap.toJson());
    await sharedPreferencesHelper.saveData(
      key: _detailsKey(roadmap.id),
      value: raw,
    );
  }

  @override
  Future<RoadmapModel?> markTaskCompletedLocally({
    required int roadmapId,
    required int taskId,
  }) async {
    return _setTaskCompletionLocally(
      roadmapId: roadmapId,
      taskId: taskId,
      isCompleted: true,
      completedAt: DateTime.now().toUtc().toIso8601String(),
    );
  }

  @override
  Future<RoadmapModel?> revertTaskCompletionLocally({
    required int roadmapId,
    required int taskId,
  }) async {
    // Rolls back an optimistic completion after a confirmed failure.
    // Only touches tasks this flow marked: already-completed tasks keep
    // their authoritative state.
    return _setTaskCompletionLocally(
      roadmapId: roadmapId,
      taskId: taskId,
      isCompleted: false,
      completedAt: null,
      onlyWhen: (task) => task.isCompleted,
    );
  }

  /// Shared local completion writer. When [onlyWhen] is provided, tasks
  /// not matching it are left untouched (rollback safety).
  Future<RoadmapModel?> _setTaskCompletionLocally({
    required int roadmapId,
    required int taskId,
    required bool isCompleted,
    String? completedAt,
    bool Function(RoadmapTaskModel task)? onlyWhen,
  }) async {
    final cached = await getCachedRoadmapDetails(roadmapId);
    if (cached == null) return null;
    var changed = false;
    final milestones = cached.milestones.map((milestone) {
      final tasks = milestone.tasks.map((task) {
        final model = task is RoadmapTaskModel
            ? task
            : RoadmapTaskModel(
                id: task.id,
                title: task.title,
                description: task.description,
                estimatedHours: task.estimatedHours,
                isCompleted: task.isCompleted,
                completedAt: task.completedAt,
              );
        if (model.id == taskId &&
            model.isCompleted != isCompleted &&
            (onlyWhen == null || onlyWhen(model))) {
          changed = true;
          return RoadmapTaskModel(
            id: model.id,
            title: model.title,
            description: model.description,
            estimatedHours: model.estimatedHours,
            isCompleted: isCompleted,
            completedAt: isCompleted
                ? (completedAt ?? model.completedAt)
                : null,
          );
        }
        return model;
      }).toList();
      return RoadmapMilestoneModel(
        id: milestone.id,
        roadmapId: milestone.roadmapId,
        title: milestone.title,
        order: milestone.order,
        tasks: tasks,
      );
    }).toList();
    if (!changed) return cached;
    final updated = RoadmapModel(
      id: cached.id,
      candidateId: cached.candidateId,
      targetRole: cached.targetRole,
      title: cached.title,
      description: cached.description,
      status: cached.status,
      completionPercentage: cached.completionPercentage,
      milestones: milestones,
      createdAt: cached.createdAt,
    );
    await cacheRoadmapDetails(updated);
    return updated;
  }

  @override
  Future<RoadmapModel?> applyServerTask({
    required int roadmapId,
    required int taskId,
    required bool isCompleted,
    String? completedAt,
  }) async {
    final cached = await getCachedRoadmapDetails(roadmapId);
    if (cached == null) return null;
    var changed = false;
    final milestones = cached.milestones.map((milestone) {
      final tasks = milestone.tasks.map((task) {
        if (task.id == taskId) {
          // Never overwrite a newer local completion with an older
          // incomplete server echo: local completed wins until the
          // queued op is confirmed.
          if (task.isCompleted && !isCompleted) return task;
          if (task.isCompleted == isCompleted &&
              task.completedAt == completedAt) {
            return task;
          }
          changed = true;
          return RoadmapTaskModel(
            id: task.id,
            title: task.title,
            description: task.description,
            estimatedHours: task.estimatedHours,
            isCompleted: isCompleted,
            completedAt: completedAt ?? task.completedAt,
          );
        }
        return task;
      }).toList();
      return RoadmapMilestoneModel(
        id: milestone.id,
        roadmapId: milestone.roadmapId,
        title: milestone.title,
        order: milestone.order,
        tasks: tasks,
      );
    }).toList();
    if (!changed) return cached;
    final updated = RoadmapModel(
      id: cached.id,
      candidateId: cached.candidateId,
      targetRole: cached.targetRole,
      title: cached.title,
      description: cached.description,
      status: cached.status,
      completionPercentage: cached.completionPercentage,
      milestones: milestones,
      createdAt: cached.createdAt,
    );
    await cacheRoadmapDetails(updated);
    return updated;
  }

  @override
  Future<List<RoadmapSyncOp>> getPendingOps() async {
    final raw = sharedPreferencesHelper.getString(key: _queueKey());
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      final ops = <RoadmapSyncOp>[];
      for (final entry in decoded) {
        if (entry is! Map<String, dynamic>) continue;
        final op = RoadmapSyncOp.fromJson(entry);
        if (op.opKey.isEmpty || op.type.isEmpty) continue;
        ops.add(op);
      }
      ops.sort((a, b) => a.createdAtMs.compareTo(b.createdAtMs));
      return ops;
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> enqueueOp(RoadmapSyncOp op) async {
    final ops = await getPendingOps();
    final filtered = ops.where((e) => e.opKey != op.opKey).toList();
    filtered.add(op);
    filtered.sort((a, b) => a.createdAtMs.compareTo(b.createdAtMs));
    await _persistOps(filtered);
  }

  @override
  Future<void> removeOp(String opKey) async {
    final ops = await getPendingOps();
    final filtered = ops.where((e) => e.opKey != opKey).toList();
    await _persistOps(filtered);
  }

  @override
  Future<void> updateOp(RoadmapSyncOp op) async {
    await enqueueOp(op);
  }

  @override
  Future<void> clearOps() async {
    await sharedPreferencesHelper.deleteData(key: _queueKey());
  }

  Future<void> _persistOps(List<RoadmapSyncOp> ops) async {
    final raw = jsonEncode(ops.map((o) => o.toJson()).toList());
    await sharedPreferencesHelper.saveData(key: _queueKey(), value: raw);
  }

  @override
  Future<Set<int>> getCollectedTreasures(int roadmapId) async {
    final list = sharedPreferencesHelper.getStringList(
      key: _treasureKey(roadmapId),
    );
    if (list == null) return {};
    return list.map(int.tryParse).whereType<int>().toSet();
  }

  @override
  Future<void> saveCollectedTreasures(int roadmapId, Set<int> collected) async {
    await sharedPreferencesHelper.saveData(
      key: _treasureKey(roadmapId),
      value: collected.map((e) => e.toString()).toList(),
    );
  }

  @override
  Future<Set<int>> getSyncedTreasures(int roadmapId) async {
    final list = sharedPreferencesHelper.getStringList(
      key: _syncedTreasureKey(roadmapId),
    );
    if (list == null) return {};
    return list.map(int.tryParse).whereType<int>().toSet();
  }

  @override
  Future<void> saveSyncedTreasures(int roadmapId, Set<int> synced) async {
    await sharedPreferencesHelper.saveData(
      key: _syncedTreasureKey(roadmapId),
      value: synced.map((e) => e.toString()).toList(),
    );
  }

  @override
  Future<CandidateXpModel?> getCachedCandidateXp() async {
    final raw = sharedPreferencesHelper.getString(key: CacheKey.candidateXp);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return CandidateXpModel.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheCandidateXp(CandidateXpModel xp) async {
    await sharedPreferencesHelper.saveData(
      key: CacheKey.candidateXp,
      value: jsonEncode(xp.toJson()),
    );
  }

  @override
  Future<RoadmapXpMetricsModel?> getCachedRoadmapXp(int roadmapId) async {
    final raw = sharedPreferencesHelper.getString(
      key: _roadmapXpKey(roadmapId),
    );
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return RoadmapXpMetricsModel.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheRoadmapXp(RoadmapXpMetricsModel xp) async {
    await sharedPreferencesHelper.saveData(
      key: _roadmapXpKey(xp.roadmapId),
      value: jsonEncode(xp.toJson()),
    );
  }
}
