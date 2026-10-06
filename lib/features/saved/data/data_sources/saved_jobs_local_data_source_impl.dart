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
}
