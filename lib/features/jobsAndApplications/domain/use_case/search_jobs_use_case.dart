import 'package:dartz/dartz.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_filter_params.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_pagination_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/repositories/jobs_repository.dart';

class SearchJobsUseCase {
  const SearchJobsUseCase({required this.repository});

  final JobsRepository repository;

  Future<Either<Failure, PaginatedJobsEntity>> call({
    required String query,
    JobFilterParams? params,
  }) {
    return repository.searchJobs(query: query, params: params);
  }
}
