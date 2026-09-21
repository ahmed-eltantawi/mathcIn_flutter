import 'package:dartz/dartz.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/repositories/jobs_repository.dart';

class GetJobsUseCase {
  const GetJobsUseCase({required this.repository});

  final JobsRepository repository;

  Future<Either<Failure, List<JobEntity>>> call() {
    return repository.getJobs();
  }
}
