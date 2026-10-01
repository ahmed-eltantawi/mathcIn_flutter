import 'dart:convert';
import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/features/jobsAndApplications/data/data_sources/applications_local_data_source.dart';
import 'package:MatchIn/features/jobsAndApplications/data/models/application_model.dart';
import 'package:MatchIn/features/jobsAndApplications/data/models/paginated_applications_model.dart';

class ApplicationsLocalDataSourceImpl implements ApplicationsLocalDataSource {
  const ApplicationsLocalDataSourceImpl({
    required this.sharedPreferencesHelper,
  });

  final SharedPreferencesHelper sharedPreferencesHelper;

  static const String _applicationsCachePrefix = 'cached_applications_';
  static const String _applicationDetailsPrefix = 'cached_application_details_';

  @override
  Future<void> cacheApplications(
    String key,
    PaginatedApplicationsModel applications,
  ) async {
    final jsonString = jsonEncode(applications.toJson());
    await sharedPreferencesHelper.saveData(
      key: '$_applicationsCachePrefix$key',
      value: jsonString,
    );
  }

  @override
  Future<PaginatedApplicationsModel?> getCachedApplications(String key) async {
    final jsonString = sharedPreferencesHelper.getString(
      key: '$_applicationsCachePrefix$key',
    );
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        return PaginatedApplicationsModel.fromJson(jsonMap);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> cacheApplicationDetails(
    String applicationId,
    ApplicationModel application,
  ) async {
    final jsonString = jsonEncode(application.toJson());
    await sharedPreferencesHelper.saveData(
      key: '$_applicationDetailsPrefix$applicationId',
      value: jsonString,
    );
  }

  @override
  Future<ApplicationModel?> getCachedApplicationDetails(
    String applicationId,
  ) async {
    final jsonString = sharedPreferencesHelper.getString(
      key: '$_applicationDetailsPrefix$applicationId',
    );
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        return ApplicationModel.fromJson(jsonMap);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
