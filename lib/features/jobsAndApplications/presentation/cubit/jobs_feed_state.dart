import 'package:equatable/equatable.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_filter_params.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_pagination_entity.dart';

sealed class JobsFeedState extends Equatable {
  const JobsFeedState();

  ///* Returns the active [JobFilterParams] carried by this state.
  ///* Subclasses that carry filter context override this getter.
  JobFilterParams? get filterParams => null;

  @override
  List<Object?> get props => [];
}

final class JobsFeedInitial extends JobsFeedState {
  const JobsFeedInitial();
}

///* [JobsFeedLoading] now carries [filterParams] so the filter-chip row can
///* immediately reflect the pending selection while the API call is in flight.
///* This is the root-cause fix for the filter UI not updating immediately.
final class JobsFeedLoading extends JobsFeedState {
  const JobsFeedLoading({this.filterParams});

  @override
  final JobFilterParams? filterParams;

  @override
  List<Object?> get props => [filterParams];
}

final class JobsFeedLoaded extends JobsFeedState {
  const JobsFeedLoaded({
    required this.jobs,
    this.pagination,
    this.filterParams,
    this.isPaginationLoading = false,
    this.isRefreshing = false,
    this.isFromCache = false,
    this.errorMessage,
  });

  final List<JobEntity> jobs;
  final JobPaginationEntity? pagination;
  @override
  final JobFilterParams? filterParams;
  final bool isPaginationLoading;
  final bool isRefreshing;
  final bool isFromCache;
  final String? errorMessage;

  JobsFeedLoaded copyWith({
    List<JobEntity>? jobs,
    JobPaginationEntity? pagination,
    JobFilterParams? filterParams,
    bool? isPaginationLoading,
    bool? isRefreshing,
    bool? isFromCache,
    String? errorMessage,
  }) {
    return JobsFeedLoaded(
      jobs: jobs ?? this.jobs,
      pagination: pagination ?? this.pagination,
      filterParams: filterParams ?? this.filterParams,
      isPaginationLoading: isPaginationLoading ?? this.isPaginationLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isFromCache: isFromCache ?? this.isFromCache,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        jobs,
        pagination,
        filterParams,
        isPaginationLoading,
        isRefreshing,
        isFromCache,
        errorMessage,
      ];
}

final class JobsFeedEmpty extends JobsFeedState {
  const JobsFeedEmpty();
}

final class JobsFeedError extends JobsFeedState {
  const JobsFeedError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class JobsFeedOfflineWithCache extends JobsFeedState {
  const JobsFeedOfflineWithCache({
    required this.jobs,
    this.pagination,
    this.message,
  });

  final List<JobEntity> jobs;
  final JobPaginationEntity? pagination;
  final String? message;

  @override
  List<Object?> get props => [jobs, pagination, message];
}
