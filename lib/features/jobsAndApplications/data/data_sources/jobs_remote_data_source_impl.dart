import 'package:MatchIn/core/networking/api_consumer.dart';
import 'package:MatchIn/core/networking/api_end_points.dart';
import 'package:MatchIn/features/jobsAndApplications/data/data_sources/jobs_remote_data_source.dart';
import 'package:MatchIn/features/jobsAndApplications/data/models/job_model.dart';
import 'package:MatchIn/features/jobsAndApplications/data/models/paginated_jobs_model.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_filter_params.dart';

class JobsRemoteDataSourceImpl implements JobsRemoteDataSource {
  const JobsRemoteDataSourceImpl({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  @override
  Future<PaginatedJobsModel> getJobs({JobFilterParams? params}) async {
    final response = await apiConsumer.get(
      EndPoint.jobs,
      queryParameters: params?.toJson(),
    );

    if (response is Map<String, dynamic>) {
      return PaginatedJobsModel.fromJson(response);
    }
    throw const FormatException('Invalid response format for jobs feed');
  }

  @override
  Future<JobModel> getJobDetails(String jobId) async {
    final response = await apiConsumer.get(EndPoint.jobDetails(jobId));

    // Live shape: {'data': {job...}}.
    if (response is Map<String, dynamic>) {
      final data = response[ApiKey.data];
      if (data is Map<String, dynamic>) {
        return JobModel.fromJson(data);
      }
      return JobModel.fromJson(response);
    }
    throw const FormatException('Invalid response format for job details');
  }

  @override
  Future<JobEntity> toggleSaveJob(String jobId, {bool? currentIsSaved}) async {
    final response = currentIsSaved == true
        ? await apiConsumer.delete(EndPoint.saveJob(jobId))
        : await apiConsumer.post(EndPoint.saveJob(jobId));

    bool isSaved = currentIsSaved != true;
    if (response is Map<String, dynamic>) {
      if (response['data'] is Map<String, dynamic>) {
        isSaved = (response['data']['is_saved'] as bool?) ?? isSaved;
      } else if (response[ApiKey.isSaved] is bool) {
        isSaved = response[ApiKey.isSaved] as bool;
      }
    }

    return JobEntity(
      id: jobId,
      title: '',
      companyName: '',
      location: '',
      workMode: '',
      employmentType: '',
      experienceLevel: '',
      postedDate: DateTime.now(),
      skills: const [],
      matchedSkills: const [],
      missingSkills: const [],
      isSaved: isSaved,
    );
  }

  @override
  Future<JobEntity> applyForJob(String jobId) async {
    final response = await apiConsumer.post(
      EndPoint.applications,
      data: {ApiKey.jobPostId: int.tryParse(jobId) ?? jobId},
    );

    // Only report success when the backend confirms with a parseable body.
    // Anything else must surface as a failure, never a fake pending state.
    if (response is! Map<String, dynamic>) {
      throw const FormatException('Invalid response format for apply to job');
    }

    return JobEntity(
      id: jobId,
      title: '',
      companyName: '',
      location: '',
      workMode: '',
      employmentType: '',
      experienceLevel: '',
      postedDate: DateTime.now(),
      skills: const [],
      matchedSkills: const [],
      missingSkills: const [],
      applicationStatus: JobApplicationStatus.pending,
    );
  }
}
