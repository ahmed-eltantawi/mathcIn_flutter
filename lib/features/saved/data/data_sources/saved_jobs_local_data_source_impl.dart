import 'dart:convert';

import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/features/saved/data/data_sources/saved_jobs_local_data_source.dart';
import 'package:MatchIn/features/saved/data/models/paginated_saved_jobs_model.dart';

class SavedJobsLocalDataSourceImpl implements SavedJobsLocalDataSource {
  const SavedJobsLocalDataSourceImpl({required this.sharedPreferencesHelper});

  final SharedPreferencesHelper sharedPreferencesHelper;

  static const String _savedJobsCachePrefix = 'cached_saved_jobs_';

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
    // Default page 1 key
    const primaryKey = 'page_1_per_page_15';
    final cached = await getCachedSavedJobs(primaryKey);
    if (cached != null) {
      final updatedJobs = cached.jobs.where((j) => j.id != jobPostId).toList();
      final updatedModel = PaginatedSavedJobsModel(
        jobs: updatedJobs,
        currentPage: cached.currentPage,
        lastPage: cached.lastPage,
        total: cached.total > 0 ? cached.total - 1 : 0,
        hasMorePages: cached.hasMorePages,
      );
      await cacheSavedJobs(primaryKey, updatedModel);
    }
  }

  @override
  Future<void> clearCache() async {
    // Best-effort clear of primary page
    await sharedPreferencesHelper.deleteData(
      key: '${_savedJobsCachePrefix}page_1_per_page_15',
    );
  }
}
