import 'package:MatchIn/features/jobsAndApplications/domain/use_case/apply_for_job_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/get_jobs_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/toggle_save_job_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/jobs_state.dart';

class JobsCubit extends Cubit<JobsState> {
  JobsCubit({
    required this.getJobsUseCase,
    required this.toggleSaveJobUseCase,
    required this.applyForJobUseCase,
  }) : super(const JobsInitial());

  final GetJobsUseCase getJobsUseCase;
  final ToggleSaveJobUseCase toggleSaveJobUseCase;
  final ApplyForJobUseCase applyForJobUseCase;

  Future<void> getJobs() async {
    emit(const JobsLoading());

    final result = await getJobsUseCase();

    result.fold(
      (failure) => emit(JobsError(failure.message)),
      (jobs) => emit(
        jobs.isEmpty ? const JobsEmpty() : JobsLoaded(jobs),
      ),
    );
  }

  Future<void> toggleSaveJob(String jobId) async {
    final currentState = state;
    if (currentState is! JobsLoaded) return;

    final result = await toggleSaveJobUseCase(jobId);

    result.fold(
      (failure) => emit(JobsError(failure.message)),
      (updatedJob) {
        final updatedJobs = currentState.jobs
            .map(
              (job) => job.id == updatedJob.id
                  ? updatedJob
                  : job,
            )
            .toList();
        emit(JobsLoaded(updatedJobs));
      },
    );
  }

  Future<void> applyForJob(String jobId) async {
    final currentState = state;
    if (currentState is! JobsLoaded) return;

    final result = await applyForJobUseCase(jobId);

    result.fold(
      (failure) => emit(JobsError(failure.message)),
      (updatedJob) {
        final updatedJobs = currentState.jobs
            .map(
              (job) => job.id == updatedJob.id
                  ? updatedJob
                  : job,
            )
            .toList();
        emit(JobsLoaded(updatedJobs));
      },
    );
  }
}
