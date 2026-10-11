import 'package:MatchIn/features/jobsAndApplications/data/models/application_model.dart';
import 'package:MatchIn/features/jobsAndApplications/data/models/paginated_applications_model.dart';

abstract class ApplicationsRemoteDataSource {
  Future<PaginatedApplicationsModel> getApplications({
    String? status,
    String? search,
    int page = 1,
  });

  Future<ApplicationModel> getApplicationDetails(String applicationId);

  Future<ApplicationModel> applyToJob({
    required int jobId,
    String? coverLetter,
  });

  Future<ApplicationModel> updateApplicationStatus({
    required String applicationId,
    required String status,
    String? notes,
  });

  Future<ApplicationModel> withdrawApplication(String applicationId);
}
