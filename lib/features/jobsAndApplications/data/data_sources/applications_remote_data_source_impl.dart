import 'package:MatchIn/core/networking/api_consumer.dart';
import 'package:MatchIn/core/networking/api_end_points.dart';
import 'package:MatchIn/features/jobsAndApplications/data/data_sources/applications_remote_data_source.dart';
import 'package:MatchIn/features/jobsAndApplications/data/models/application_model.dart';
import 'package:MatchIn/features/jobsAndApplications/data/models/paginated_applications_model.dart';

class ApplicationsRemoteDataSourceImpl implements ApplicationsRemoteDataSource {
  const ApplicationsRemoteDataSourceImpl({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  @override
  Future<PaginatedApplicationsModel> getApplications({
    String? status,
    String? search,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{
      if (status != null && status.isNotEmpty) ApiKey.status: status,
      if (search != null && search.isNotEmpty) ApiKey.search: search,
      ApiKey.page: page,
    };

    final response = await apiConsumer.get(
      EndPoint.applications,
      queryParameters: queryParams,
    );

    if (response is Map<String, dynamic>) {
      return PaginatedApplicationsModel.fromJson(response);
    }
    throw const FormatException('Invalid response format for applications');
  }

  @override
  Future<ApplicationModel> getApplicationDetails(String applicationId) async {
    final response = await apiConsumer.get(
      EndPoint.applicationDetails(applicationId),
    );

    if (response is Map<String, dynamic>) {
      return ApplicationModel.fromJson(response);
    }
    throw const FormatException('Invalid response format for application details');
  }

  @override
  Future<ApplicationModel> applyToJob({
    required int jobId,
    int? cvDocumentId,
    String? coverLetter,
    String? notes,
  }) async {
    // Live contract: POST /applications with job_post_id (required) plus
    // the documented optional fields. No invented fields are sent.
    final body = <String, dynamic>{ApiKey.jobPostId: jobId};
    if (cvDocumentId != null) {
      body[ApiKey.cvDocumentId] = cvDocumentId;
    }
    if (coverLetter != null && coverLetter.isNotEmpty) {
      body[ApiKey.coverLetter] = coverLetter;
    }
    if (notes != null && notes.isNotEmpty) {
      body[ApiKey.notes] = notes;
    }

    final response = await apiConsumer.post(
      EndPoint.applications,
      data: body,
    );

    if (response is Map<String, dynamic>) {
      return ApplicationModel.fromJson(response);
    }
    throw const FormatException('Invalid response format for apply to job');
  }

  @override
  Future<ApplicationModel> updateApplicationStatus({
    required String applicationId,
    required String status,
    String? notes,
  }) async {
    final body = <String, dynamic>{
      ApiKey.status: status,
      if (notes != null && notes.isNotEmpty) ApiKey.notes: notes,
    };

    final response = await apiConsumer.patch(
      EndPoint.updateApplicationStatus(applicationId),
      data: body,
    );

    if (response is Map<String, dynamic>) {
      return ApplicationModel.fromJson(response);
    }
    throw const FormatException(
      'Invalid response format for update application status',
    );
  }

  @override
  Future<ApplicationModel> withdrawApplication(String applicationId) async {
    final response = await apiConsumer.post(
      EndPoint.withdrawApplication(applicationId),
    );

    if (response is Map<String, dynamic>) {
      return ApplicationModel.fromJson(response);
    }
    throw const FormatException('Invalid response format for withdraw application');
  }

  @override
  Future<ApplicationModel> updateApplicationNotes({
    required String applicationId,
    required String notes,
  }) async {
    final response = await apiConsumer.patch(
      EndPoint.applicationNotes(applicationId),
      data: {ApiKey.notes: notes},
    );

    if (response is Map<String, dynamic>) {
      return ApplicationModel.fromJson(response);
    }
    throw const FormatException(
      'Invalid response format for update application notes',
    );
  }
}
