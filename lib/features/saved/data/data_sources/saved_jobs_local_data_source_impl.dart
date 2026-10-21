import 'dart:convert';

import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/features/saved/data/data_sources/saved_jobs_local_data_source.dart';
import 'package:MatchIn/features/saved/data/models/paginated_saved_jobs_model.dart';
import 'package:MatchIn/features/saved/data/models/saved_job_response_model.dart';
import 'package:MatchIn/features/saved/data/models/saved_job_sync_op.dart';

class SavedJobsLocalDataSourceImpl implements SavedJobsLocalDataSource {
  const SavedJobsLocalDataSourceImpl({required this.sharedPreferencesHelper});

  final SharedPreferencesHelper sharedPreferencesHelper;

  static const String _savedJobsCachePrefix = 'cached_saved_jobs_';

  /// Primary key backing the local source of truth for saved jobs.
  static const String primaryCacheKey = 'page_1_per_page_15';

  static const String _syncQueueKey = 'saved_jobs_sync_queue_v1';

  @override
  Future<void> cacheSavedJobs(
    String key,
    PaginatedSavedJobsModel savedJobs,
  ) async {
    final jsonString = jsonEncode(savedJobs.toJson());
    await sharedPreferencesHelper.saveData(
      key: '$_savedJobsCachePrefix$key',
      value: jsonString,
    );
  }

  @override
  Future<PaginatedSavedJobsModel?> getCachedSavedJobs(String key) async {
    final jsonString = sharedPreferencesHelper.getString(
      key: '$_savedJobsCachePrefix$key',
    );
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        return PaginatedSavedJobsModel.fromJson(jsonMap);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> removeSavedJob(int jobPostId) async {
    final cached = await getCachedSavedJobs(primaryCacheKey);
    if (cached != null) {
      final updatedJobs = cached.jobs.where((j) => j.id != jobPostId).toList();
      final updatedModel = PaginatedSavedJobsModel(
        jobs: updatedJobs,
        currentPage: cached.currentPage,
        lastPage: cached.lastPage,
        total: cached.total > 0 ? cached.total - 1 : 0,
        hasMorePages: cached.hasMorePages,
      );
      await cacheSavedJobs(primaryCacheKey, updatedModel);
    }
  }

  @override
  Future<void> clearCache() async {
    // Best-effort clear of primary page
    await sharedPreferencesHelper.deleteData(
      key: '$_savedJobsCachePrefix$primaryCacheKey',
    );
  }

  @override
  Future<void> upsertSavedJob(SavedJobResponseModel job) async {
    final cached = await getCachedSavedJobs(primaryCacheKey);
    // The snapshot round-trips through JSON, so entries are response
    // models at runtime; non-model entries cannot be re-persisted.
    final jobs =
        cached?.jobs.whereType<SavedJobResponseModel>().toList() ??
        <SavedJobResponseModel>[];
    final index = jobs.indexWhere((j) => j.id == job.id);
    final saved = job.isSaved
        ? job
        : SavedJobResponseModel(
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
    if (index >= 0) {
      jobs[index] = saved;
    } else {
      jobs.insert(0, saved);
    }
    await cacheSavedJobs(
      primaryCacheKey,
      PaginatedSavedJobsModel(
        jobs: jobs,
        currentPage: 1,
        lastPage: 1,
        total: jobs.length,
        hasMorePages: false,
      ),
    );
  }

  @override
  Future<List<SavedJobResponseModel>> getLocalSavedJobs() async {
    final cached = await getCachedSavedJobs(primaryCacheKey);
    return cached?.jobs.whereType<SavedJobResponseModel>().toList() ?? const [];
  }

  @override
  Future<List<SavedJobSyncOp>> getPendingOps() async {
    final raw = sharedPreferencesHelper.getString(key: _syncQueueKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      final ops = <SavedJobSyncOp>[];
      for (final entry in decoded) {
        if (entry is! Map<String, dynamic>) continue;
        final op = SavedJobSyncOp.fromJson(entry);
        if (op.opKey.isEmpty || op.jobPostId <= 0) continue;
        ops.add(op);
      }
      ops.sort((a, b) => a.createdAtMs.compareTo(b.createdAtMs));
      return ops;
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> enqueueOp(SavedJobSyncOp op) async {
    final ops = await getPendingOps();
    final filtered = ops.where((e) => e.opKey != op.opKey).toList();
    filtered.add(op);
    filtered.sort((a, b) => a.createdAtMs.compareTo(b.createdAtMs));
    await _persistOps(filtered);
  }

  @override
  Future<void> removeOp(String opKey) async {
    final ops = await getPendingOps();
    await _persistOps(ops.where((e) => e.opKey != opKey).toList());
  }

  @override
  Future<void> updateOp(SavedJobSyncOp op) async {
    await enqueueOp(op);
  }

  Future<void> _persistOps(List<SavedJobSyncOp> ops) async {
    await sharedPreferencesHelper.saveData(
      key: _syncQueueKey,
      value: jsonEncode(ops.map((o) => o.toJson()).toList()),
    );
  }
}
