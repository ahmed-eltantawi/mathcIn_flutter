import 'dart:convert';
import 'package:MatchIn/core/cache/cache_key.dart';
import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/features/jobsAndApplications/data/data_sources/jobs_local_data_source.dart';
import 'package:MatchIn/features/jobsAndApplications/data/models/paginated_jobs_model.dart';

class JobsLocalDataSourceImpl implements JobsLocalDataSource {
  const JobsLocalDataSourceImpl({required this.sharedPreferencesHelper});

  final SharedPreferencesHelper sharedPreferencesHelper;

  String _fullKey(String cacheKey) => '${CacheKey.jobsFeedPrefix}$cacheKey';

  @override
  Future<PaginatedJobsModel?> getCachedJobs(String cacheKey) async {
    final rawJson = sharedPreferencesHelper.getString(key: _fullKey(cacheKey));
    if (rawJson == null || rawJson.isEmpty) {
      return null;
    }

    try {
      final map = jsonDecode(rawJson) as Map<String, dynamic>;
      return PaginatedJobsModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheJobs(
    String cacheKey,
    PaginatedJobsModel paginatedJobs,
  ) async {
    final rawJson = jsonEncode(paginatedJobs.toJson());
    await sharedPreferencesHelper.saveData(
      key: _fullKey(cacheKey),
      value: rawJson,
    );
  }

  @override
  Future<void> clearCachedJobs(String cacheKey) async {
    await sharedPreferencesHelper.deleteData(key: _fullKey(cacheKey));
  }
}
