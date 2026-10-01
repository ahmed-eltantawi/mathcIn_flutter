import 'package:dartz/dartz.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_filter_params.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_pagination_entity.dart';

abstract class JobsRepository {
  Future<Either<Failure, PaginatedJobsEntity>> getJobs({
    JobFilterParams? params,
  });

  Future<Either<Failure, PaginatedJobsEntity?>> getCachedJobs({
    JobFilterParams? params,
  });

  Future<Either<Failure, JobEntity>> toggleSaveJob(
    String jobId,
  );

  Future<Either<Failure, JobEntity>> applyForJob(
    String jobId,
  );
}
