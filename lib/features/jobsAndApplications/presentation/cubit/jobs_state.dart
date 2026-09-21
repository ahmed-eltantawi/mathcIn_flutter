import 'package:equatable/equatable.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';

sealed class JobsState extends Equatable {
  const JobsState();

  @override
  List<Object?> get props => [];
}

final class JobsInitial extends JobsState {
  const JobsInitial();
}

final class JobsLoading extends JobsState {
  const JobsLoading();
}

final class JobsLoaded extends JobsState {
  const JobsLoaded(this.jobs);

  final List<JobEntity> jobs;

  @override
  List<Object?> get props => [jobs];
}

final class JobsEmpty extends JobsState {
  const JobsEmpty();
}

final class JobsError extends JobsState {
  const JobsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
