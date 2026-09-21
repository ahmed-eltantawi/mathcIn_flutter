import 'package:dartz/dartz.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';

abstract class JobsRepository {
  Future<Either<Failure, List<JobEntity>>> getJobs();

  Future<Either<Failure, JobEntity>> toggleSaveJob(
    String jobId,
  );

  Future<Either<Failure, JobEntity>> applyForJob(
    String jobId,
  );
}
