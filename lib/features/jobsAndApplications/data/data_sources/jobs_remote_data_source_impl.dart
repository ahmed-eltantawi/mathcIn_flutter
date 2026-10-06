import 'package:MatchIn/core/networking/api_consumer.dart';
import 'package:MatchIn/core/networking/api_end_points.dart';
import 'package:MatchIn/features/jobsAndApplications/data/data_sources/jobs_remote_data_source.dart';
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
  Future<JobEntity> toggleSaveJob(String jobId) async {
    final response = await apiConsumer.post(EndPoint.saveJob(jobId));

    if (response is Map<String, dynamic>) {
      final isSaved = response[ApiKey.isSaved] as bool? ?? true;
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
      isSaved: true,
    );
  }

  @override
  Future<JobEntity> applyForJob(String jobId) async {
    final response = await apiConsumer.post(
      EndPoint.applications,
      data: {ApiKey.jobId: int.tryParse(jobId) ?? jobId},
    );

    if (response is Map<String, dynamic>) {
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
