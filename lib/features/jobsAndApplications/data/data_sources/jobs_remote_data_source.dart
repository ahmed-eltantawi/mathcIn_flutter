import 'package:MatchIn/features/jobsAndApplications/data/models/paginated_jobs_model.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_filter_params.dart';

abstract class JobsRemoteDataSource {
  Future<PaginatedJobsModel> getJobs({JobFilterParams? params});

  Future<JobEntity> toggleSaveJob(String jobId, {bool? currentIsSaved});

  Future<JobEntity> applyForJob(String jobId);
}
