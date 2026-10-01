import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_filter_params.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/apply_for_job_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/get_cached_jobs_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/get_jobs_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/toggle_save_job_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/jobs_feed_state.dart';

class JobsFeedCubit extends Cubit<JobsFeedState> {
  JobsFeedCubit({
    required this.getJobsUseCase,
    required this.getCachedJobsUseCase,
    required this.toggleSaveJobUseCase,
    required this.applyForJobUseCase,
  }) : super(const JobsFeedInitial());

  final GetJobsUseCase getJobsUseCase;
  final GetCachedJobsUseCase getCachedJobsUseCase;
  final ToggleSaveJobUseCase toggleSaveJobUseCase;
  final ApplyForJobUseCase applyForJobUseCase;

  JobFilterParams _currentFilterParams = const JobFilterParams();
  Timer? _debounceTimer;

  JobFilterParams get currentFilterParams => _currentFilterParams;

  Future<void> getJobs({
    JobFilterParams? params,
    bool isRefresh = false,
  }) async {
    if (params != null) {
      _currentFilterParams = params;
    }

    final targetParams = _currentFilterParams;

    if (!isRefresh &&
        (state is JobsFeedInitial || state is JobsFeedLoading)) {
      final cachedResult = await getCachedJobsUseCase(params: targetParams);
      cachedResult.fold(
        (_) {},
        (cachedData) {
          if (cachedData != null && cachedData.jobs.isNotEmpty) {
            emit(
              JobsFeedLoaded(
                jobs: cachedData.jobs,
                pagination: cachedData.pagination,
                filterParams: targetParams,
                isFromCache: true,
              ),
            );
          }
        },
      );
    }

    final currentState = state;
    if (isRefresh && currentState is JobsFeedLoaded) {
      emit(currentState.copyWith(isRefreshing: true));
    } else if (state is! JobsFeedLoaded) {
      emit(const JobsFeedLoading());
    }

    final result = await getJobsUseCase(params: targetParams);

    result.fold(
      (failure) {
        final stateOnFailure = state;
        if (stateOnFailure is JobsFeedLoaded) {
          emit(
            stateOnFailure.copyWith(
              isRefreshing: false,
              isPaginationLoading: false,
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
              filterParams: targetParams,
              isFromCache: false,
            ),
          );
        }
      },
    );
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
            isFromCache: false,
            isPaginationLoading: false,
          ),
        );
      },
    );
  }

  Future<void> refreshJobs() async {
    final resetParams = _currentFilterParams.copyWith(page: 1);
    await getJobs(params: resetParams, isRefresh: true);
  }

  void searchJobs(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      final trimmed = query.trim();
      final newParams = _currentFilterParams.copyWith(
        search: trimmed.isEmpty ? null : trimmed,
        sort: trimmed.isNotEmpty ? 'relevance' : null,
        page: 1,
      );
      getJobs(params: newParams);
    });
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

    final result = await toggleSaveJobUseCase(jobId);

    result.fold(
      (failure) {
        emit(currentState.copyWith(errorMessage: failure.message));
      },
      (updatedJob) {
        final updatedJobs = currentState.jobs
            .map((job) => job.id == updatedJob.id ? updatedJob : job)
            .toList();
        emit(currentState.copyWith(jobs: updatedJobs));
      },
    );
  }

  Future<void> applyForJob(String jobId) async {
    final currentState = state;
    if (currentState is! JobsFeedLoaded) return;

    final result = await applyForJobUseCase(jobId);

    result.fold(
      (failure) {
        emit(currentState.copyWith(errorMessage: failure.message));
      },
      (updatedJob) {
        final updatedJobs = currentState.jobs
            .map((job) => job.id == updatedJob.id ? updatedJob : job)
            .toList();
        emit(currentState.copyWith(jobs: updatedJobs));
      },
    );
  }

  JobEntity? getJobById(String jobId) {
    final currentState = state;

    if (currentState is JobsFeedLoaded) {
      for (final job in currentState.jobs) {
        if (job.id == jobId) return job;
      }
    } else if (currentState is JobsFeedOfflineWithCache) {
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
