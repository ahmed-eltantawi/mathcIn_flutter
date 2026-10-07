import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_filter_params.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/apply_for_job_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/get_jobs_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/refresh_jobs_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/search_jobs_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/toggle_save_job_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/jobs_feed_state.dart';

class JobsFeedCubit extends Cubit<JobsFeedState> {
  JobsFeedCubit({
    required this.getJobsUseCase,
    required this.searchJobsUseCase,
    required this.refreshJobsUseCase,
    required this.toggleSaveJobUseCase,
    required this.applyForJobUseCase,
  }) : super(const JobsFeedInitial());

  final GetJobsUseCase getJobsUseCase;
  final SearchJobsUseCase searchJobsUseCase;
  final RefreshJobsUseCase refreshJobsUseCase;
  final ToggleSaveJobUseCase toggleSaveJobUseCase;
  final ApplyForJobUseCase applyForJobUseCase;

  JobFilterParams _currentFilterParams = const JobFilterParams();
  Timer? _debounceTimer;

  JobFilterParams get currentFilterParams => _currentFilterParams;

  Future<void> getJobs({JobFilterParams? params}) async {
    if (params != null) {
      _currentFilterParams = params;
    }

    emit(const JobsFeedLoading());

    final result = await getJobsUseCase(params: _currentFilterParams);

    result.fold(
      (failure) => emit(JobsFeedError(failure.message)),
      (paginatedEntity) {
        if (paginatedEntity.jobs.isEmpty) {
          emit(const JobsFeedEmpty());
        } else {
          emit(
            JobsFeedLoaded(
              jobs: paginatedEntity.jobs,
              pagination: paginatedEntity.pagination,
              filterParams: _currentFilterParams,
              isFromCache: paginatedEntity.isFromCache,
            ),
          );
        }
      },
    );
  }

  Future<void> refreshJobs() async {
    final resetParams = _currentFilterParams.copyWith(page: 1);
    _currentFilterParams = resetParams;

    final currentState = state;
    if (currentState is JobsFeedLoaded) {
      emit(currentState.copyWith(isRefreshing: true));
    } else {
      emit(const JobsFeedLoading());
    }

    final result = await refreshJobsUseCase(params: resetParams);

    result.fold(
      (failure) {
        final stateOnFailure = state;
        if (stateOnFailure is JobsFeedLoaded) {
          emit(
            stateOnFailure.copyWith(
              isRefreshing: false,
              errorMessage: failure.message,
            ),
          );
        } else {
          emit(JobsFeedError(failure.message));
        }
      },
      (paginatedEntity) {
        if (paginatedEntity.jobs.isEmpty) {
          emit(const JobsFeedEmpty());
        } else {
          emit(
            JobsFeedLoaded(
              jobs: paginatedEntity.jobs,
              pagination: paginatedEntity.pagination,
              filterParams: resetParams,
              isFromCache: paginatedEntity.isFromCache,
            ),
          );
        }
      },
    );
  }

  void searchJobs(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      final trimmed = query.trim();
      final newParams = _currentFilterParams.copyWith(
        search: trimmed.isEmpty ? null : trimmed,
        sort: trimmed.isNotEmpty ? 'relevance' : null,
        page: 1,
      );
      _currentFilterParams = newParams;

      emit(const JobsFeedLoading());

      final result = trimmed.isEmpty
          ? await getJobsUseCase(params: newParams)
          : await searchJobsUseCase(query: trimmed, params: newParams);

      result.fold(
        (failure) => emit(JobsFeedError(failure.message)),
        (paginatedEntity) {
          if (paginatedEntity.jobs.isEmpty) {
            emit(const JobsFeedEmpty());
          } else {
            emit(
              JobsFeedLoaded(
                jobs: paginatedEntity.jobs,
                pagination: paginatedEntity.pagination,
                filterParams: newParams,
                isFromCache: paginatedEntity.isFromCache,
              ),
            );
          }
        },
      );
    });
  }

  Future<void> loadMoreJobs() async {
    final currentState = state;
    if (currentState is! JobsFeedLoaded) return;
    if (currentState.isPaginationLoading || currentState.isRefreshing) return;

    final pagination = currentState.pagination;
    if (pagination != null && !pagination.hasNextPage) return;

    final nextPage = (pagination?.currentPage ?? 1) + 1;
    emit(currentState.copyWith(isPaginationLoading: true));

    final nextParams = _currentFilterParams.copyWith(page: nextPage);
    final result = await getJobsUseCase(params: nextParams);

    result.fold(
      (failure) {
        emit(
          currentState.copyWith(
            isPaginationLoading: false,
            errorMessage: failure.message,
          ),
        );
      },
      (paginatedEntity) {
        final updatedJobs = List<JobEntity>.from(currentState.jobs)
          ..addAll(paginatedEntity.jobs);
        _currentFilterParams = nextParams;
        emit(
          JobsFeedLoaded(
            jobs: updatedJobs,
            pagination: paginatedEntity.pagination,
            filterParams: nextParams,
            isFromCache: paginatedEntity.isFromCache,
            isPaginationLoading: false,
          ),
        );
      },
    );
  }

  Future<void> setWorkMode(String? workMode) async {
    final newParams = _currentFilterParams.copyWith(
      workMode: workMode,
      page: 1,
    );
    await getJobs(params: newParams);
  }

  Future<void> setEmploymentType(String? employmentType) async {
    final newParams = _currentFilterParams.copyWith(
      employmentType: employmentType,
      page: 1,
    );
    await getJobs(params: newParams);
  }

  Future<void> setExperienceLevel(String? experienceLevel) async {
    final newParams = _currentFilterParams.copyWith(
      experienceLevel: experienceLevel,
      page: 1,
    );
    await getJobs(params: newParams);
  }

  Future<void> applyFilterParams(JobFilterParams params) async {
    await getJobs(params: params.copyWith(page: 1));
  }

  Future<void> toggleSaveJob(String jobId) async {
    final currentState = state;
    if (currentState is! JobsFeedLoaded) return;

    final targetJob = currentState.jobs.firstWhere(
      (job) => job.id == jobId,
      orElse: () => currentState.jobs.first,
    );
    final currentIsSaved = targetJob.isSaved;

    final result = await toggleSaveJobUseCase(
      jobId,
      currentIsSaved: currentIsSaved,
    );

    result.fold(
      (failure) {
        emit(currentState.copyWith(errorMessage: failure.message));
      },
      (updatedEntity) {
        final updatedJobs = currentState.jobs.map((job) {
          if (job.id == jobId) {
            return job.copyWith(isSaved: updatedEntity.isSaved);
          }
          return job;
        }).toList();
        emit(currentState.copyWith(jobs: updatedJobs));
      },
    );
  }

  void updateJobSavedStatus({required String jobId, required bool isSaved}) {
    final currentState = state;
    if (currentState is JobsFeedLoaded) {
      final updatedJobs = currentState.jobs.map((job) {
        if (job.id == jobId) {
          return job.copyWith(isSaved: isSaved);
        }
        return job;
      }).toList();
      emit(currentState.copyWith(jobs: updatedJobs));
    }
  }

  Future<void> applyForJob(String jobId) async {
    final currentState = state;
    if (currentState is! JobsFeedLoaded) return;

    final result = await applyForJobUseCase(jobId);

    result.fold(
      (failure) {
        emit(currentState.copyWith(errorMessage: failure.message));
      },
      (_) {
        final updatedJobs = currentState.jobs.map((job) {
          if (job.id == jobId) {
            return job.copyWith(
              applicationStatus: JobApplicationStatus.pending,
            );
          }
          return job;
        }).toList();
        emit(currentState.copyWith(jobs: updatedJobs));
      },
    );
  }

  void resetSearch() {
    _debounceTimer?.cancel();
    final hasActiveSearch =
        _currentFilterParams.search != null &&
        _currentFilterParams.search!.isNotEmpty;
    if (!hasActiveSearch) return;

    final resetParams = const JobFilterParams();
    getJobs(params: resetParams);
  }

  JobEntity? getJobById(String jobId) {
    final currentState = state;

    if (currentState is JobsFeedLoaded) {
      for (final job in currentState.jobs) {
        if (job.id == jobId) return job;
      }
    }

    return null;
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
