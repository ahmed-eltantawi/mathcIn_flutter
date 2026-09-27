import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';

abstract class JobsRemoteDataSource {
  Future<List<JobEntity>> getJobs();

  Future<JobEntity> toggleSaveJob(String jobId);

  Future<JobEntity> applyForJob(String jobId);
}
