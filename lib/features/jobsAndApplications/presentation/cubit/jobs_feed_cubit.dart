import 'package:MatchIn/features/jobsAndApplications/domain/use_case/apply_for_job_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/get_jobs_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/toggle_save_job_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/jobs_feed_state.dart';

class JobsFeedCubit extends Cubit<JobsFeedState> {
  JobsFeedCubit({
    required this.getJobsUseCase,
    required this.toggleSaveJobUseCase,
    required this.applyForJobUseCase,
  }) : super(const JobsFeedInitial());

  final GetJobsUseCase getJobsUseCase;
  final ToggleSaveJobUseCase toggleSaveJobUseCase;
  final ApplyForJobUseCase applyForJobUseCase;

  Future<void> getJobs() async {
    emit(const JobsFeedLoading());

    final result = await getJobsUseCase();

    result.fold(
      (failure) => emit(JobsFeedError(failure.message)),
      (jobs) => emit(
        jobs.isEmpty
            ? const JobsFeedEmpty()
            : JobsFeedLoaded(jobs),
      ),
    );
  }

  Future<void> toggleSaveJob(String jobId) async {
    final currentState = state;
    if (currentState is! JobsFeedLoaded) return;

    final result = await toggleSaveJobUseCase(jobId);

    result.fold(
      (failure) => emit(JobsFeedError(failure.message)),
      (updatedJob) {
        final updatedJobs = currentState.jobs
            .map(
              (job) => job.id == updatedJob.id
                  ? updatedJob
                  : job,
            )
            .toList();
        emit(JobsFeedLoaded(updatedJobs));
      },
    );
  }

  Future<void> applyForJob(String jobId) async {
    final currentState = state;
    if (currentState is! JobsFeedLoaded) return;

    final result = await applyForJobUseCase(jobId);

    result.fold(
      (failure) => emit(JobsFeedError(failure.message)),
      (updatedJob) {
        final updatedJobs = currentState.jobs
            .map(
              (job) => job.id == updatedJob.id
                  ? updatedJob
                  : job,
            )
            .toList();
        emit(JobsFeedLoaded(updatedJobs));
      },
    );
  }
}
