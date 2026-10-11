import 'package:MatchIn/features/jobsAndApplications/data/models/application_model.dart';
import 'package:MatchIn/features/jobsAndApplications/data/models/paginated_applications_model.dart';

abstract class ApplicationsLocalDataSource {
  Future<void> cacheApplications(
    String key,
    PaginatedApplicationsModel applications,
  );

  Future<PaginatedApplicationsModel?> getCachedApplications(String key);

  Future<void> cacheApplicationDetails(
    String applicationId,
    ApplicationModel application,
  );

  Future<ApplicationModel?> getCachedApplicationDetails(String applicationId);
}
