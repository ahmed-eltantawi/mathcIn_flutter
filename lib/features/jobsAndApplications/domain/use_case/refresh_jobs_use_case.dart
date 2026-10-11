import 'package:dartz/dartz.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_filter_params.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_pagination_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/repositories/jobs_repository.dart';

class RefreshJobsUseCase {
  const RefreshJobsUseCase({required this.repository});

  final JobsRepository repository;

  Future<Either<Failure, PaginatedJobsEntity>> call({
    JobFilterParams? params,
  }) {
    return repository.refreshJobs(params: params);
  }
}
