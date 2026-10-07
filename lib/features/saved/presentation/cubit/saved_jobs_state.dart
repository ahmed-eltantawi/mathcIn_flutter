import 'package:equatable/equatable.dart';
import 'package:MatchIn/features/saved/domain/entities/saved_job_entity.dart';

abstract class SavedJobsState extends Equatable {
  const SavedJobsState();

  @override
  List<Object?> get props => [];
}

class SavedJobsInitial extends SavedJobsState {
  const SavedJobsInitial();
}

class SavedJobsLoading extends SavedJobsState {
  const SavedJobsLoading();
}

class SavedJobsLoaded extends SavedJobsState {
  const SavedJobsLoaded({
    required this.jobs,
    required this.currentPage,
    required this.hasMore,
    this.total = 0,
    this.isLoadingMore = false,
  });

  final List<SavedJobEntity> jobs;
  final int currentPage;
  final bool hasMore;
  final int total;
  final bool isLoadingMore;

  SavedJobsLoaded copyWith({
    List<SavedJobEntity>? jobs,
    int? currentPage,
    bool? hasMore,
    int? total,
    bool? isLoadingMore,
  }) {
    return SavedJobsLoaded(
      jobs: jobs ?? this.jobs,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      total: total ?? this.total,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [jobs, currentPage, hasMore, total, isLoadingMore];
}

class SavedJobsError extends SavedJobsState {
  const SavedJobsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
