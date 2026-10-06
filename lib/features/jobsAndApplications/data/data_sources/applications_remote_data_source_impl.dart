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
    String? coverLetter,
  }) async {
    final body = <String, dynamic>{
      ApiKey.jobId: jobId,
      if (coverLetter != null && coverLetter.isNotEmpty)
        ApiKey.coverLetter: coverLetter,
    };

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
}
