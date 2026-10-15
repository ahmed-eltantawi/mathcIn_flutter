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
    int? cvDocumentId,
    String? coverLetter,
    String? notes,
  });

  Future<ApplicationModel> updateApplicationStatus({
    required String applicationId,
    required String status,
    String? notes,
  });

  Future<ApplicationModel> withdrawApplication(String applicationId);

  /// Candidate updates personal notes on their own application.
  /// Request/response shapes are unverified against live (write op).
  Future<ApplicationModel> updateApplicationNotes({
    required String applicationId,
    required String notes,
  });
}
