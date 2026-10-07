import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/jobs_feed_cubit.dart';
import 'package:MatchIn/features/saved/domain/entities/saved_job_entity.dart';
import 'package:MatchIn/features/saved/domain/use_cases/get_saved_jobs_use_case.dart';
import 'package:MatchIn/features/saved/domain/use_cases/save_job_use_case.dart';
import 'package:MatchIn/features/saved/domain/use_cases/unsave_job_use_case.dart';
import 'package:MatchIn/features/saved/presentation/cubit/saved_jobs_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SavedJobsCubit extends Cubit<SavedJobsState> {
  SavedJobsCubit({
    required this.getSavedJobsUseCase,
    required this.saveJobUseCase,
    required this.unsaveJobUseCase,
  }) : super(const SavedJobsInitial());

  final GetSavedJobsUseCase getSavedJobsUseCase;
  final SaveJobUseCase saveJobUseCase;
  final UnsaveJobUseCase unsaveJobUseCase;

  Future<void> fetchSavedJobs({bool isRefresh = false}) async {
    final currentState = state;
    if (isRefresh && currentState is SavedJobsLoaded) {
      // Keep displaying currently loaded jobs while refreshing
    } else if (state is! SavedJobsLoaded) {
      emit(const SavedJobsLoading());
    }

    final result = await getSavedJobsUseCase(page: 1, perPage: 15);

    result.fold(
      (failure) {
        if (state is! SavedJobsLoaded) {
          emit(SavedJobsError(message: failure.message));
        }
      },
      (paginated) {
        emit(
          SavedJobsLoaded(
            jobs: paginated.jobs,
            currentPage: paginated.currentPage,
            hasMore: paginated.hasMorePages,
            total: paginated.total,
          ),
        );
      },
    );
  }

  Future<void> loadMoreSavedJobs() async {
    final currentState = state;
    if (currentState is! SavedJobsLoaded) return;
    if (currentState.isLoadingMore || !currentState.hasMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;
    final result = await getSavedJobsUseCase(page: nextPage, perPage: 15);

    result.fold(
      (failure) {
        emit(currentState.copyWith(isLoadingMore: false));
      },
      (paginated) {
        final updatedJobs = List<SavedJobEntity>.from(currentState.jobs)
          ..addAll(paginated.jobs);
        emit(
          SavedJobsLoaded(
            jobs: updatedJobs,
            currentPage: paginated.currentPage,
            hasMore: paginated.hasMorePages,
            total: paginated.total,
            isLoadingMore: false,
          ),
        );
      },
    );
  }

  Future<void> toggleBookmark(SavedJobEntity job) async {
    final currentState = state;
    if (currentState is! SavedJobsLoaded) return;

    if (job.isSaved) {
      // Optimistically remove from saved jobs list
      final updatedJobs =
          currentState.jobs.where((j) => j.id != job.id).toList();
      emit(
        currentState.copyWith(
          jobs: updatedJobs,
          total: currentState.total > 0 ? currentState.total - 1 : 0,
        ),
      );

      final result = await unsaveJobUseCase(jobPostId: job.id);
      result.fold(
        (failure) {
          // Revert on failure
          emit(currentState);
        },
        (_) {
          // Sync with JobsFeedCubit
          if (getIt.isRegistered<JobsFeedCubit>()) {
            getIt<JobsFeedCubit>().updateJobSavedStatus(
              jobId: job.id.toString(),
              isSaved: false,
            );
          }
        },
      );
    } else {
      final result = await saveJobUseCase(jobPostId: job.id);
      result.fold(
        (failure) {},
        (_) {
          if (getIt.isRegistered<JobsFeedCubit>()) {
            getIt<JobsFeedCubit>().updateJobSavedStatus(
              jobId: job.id.toString(),
              isSaved: true,
            );
          }
          fetchSavedJobs(isRefresh: true);
        },
      );
    }
  }
}
