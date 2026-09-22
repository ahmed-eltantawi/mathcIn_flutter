import 'package:equatable/equatable.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';

sealed class JobsFeedState extends Equatable {
  const JobsFeedState();

  @override
  List<Object?> get props => [];
}

final class JobsFeedInitial extends JobsFeedState {
  const JobsFeedInitial();
}

final class JobsFeedLoading extends JobsFeedState {
  const JobsFeedLoading();
}

final class JobsFeedLoaded extends JobsFeedState {
  const JobsFeedLoaded(this.jobs);

  final List<JobEntity> jobs;

  @override
  List<Object?> get props => [jobs];
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
