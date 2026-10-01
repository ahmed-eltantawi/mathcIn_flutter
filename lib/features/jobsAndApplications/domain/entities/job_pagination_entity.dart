import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:equatable/equatable.dart';

class JobPaginationEntity extends Equatable {
  const JobPaginationEntity({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.from,
    this.to,
  });

  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int? from;
  final int? to;

  bool get hasNextPage => currentPage < lastPage;

  @override
  List<Object?> get props => [
        currentPage,
        lastPage,
        perPage,
        total,
        from,
        to,
      ];
}

class PaginatedJobsEntity extends Equatable {
  const PaginatedJobsEntity({
    required this.jobs,
    this.pagination,
  });

  final List<JobEntity> jobs;
  final JobPaginationEntity? pagination;

  @override
  List<Object?> get props => [jobs, pagination];
}
