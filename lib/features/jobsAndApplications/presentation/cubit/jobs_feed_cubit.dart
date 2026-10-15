import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_filter_params.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/apply_for_job_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/get_cached_jobs_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/get_jobs_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/refresh_jobs_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/search_jobs_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/toggle_save_job_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/jobs_feed_state.dart';

class JobsFeedCubit extends Cubit<JobsFeedState> {
  JobsFeedCubit({
    required this.getJobsUseCase,
    required this.getCachedJobsUseCase,
    required this.searchJobsUseCase,
    required this.refreshJobsUseCase,
    required this.toggleSaveJobUseCase,
    required this.applyForJobUseCase,
  }) : super(const JobsFeedInitial());

  final GetJobsUseCase getJobsUseCase;
  final GetCachedJobsUseCase getCachedJobsUseCase;
  final SearchJobsUseCase searchJobsUseCase;
  final RefreshJobsUseCase refreshJobsUseCase;
  final ToggleSaveJobUseCase toggleSaveJobUseCase;
  final ApplyForJobUseCase applyForJobUseCase;

  JobFilterParams _currentFilterParams = const JobFilterParams();
  Timer? _debounceTimer;

  //! ===== Optimistic save handling =====
  // Tracks job ids with an in-flight save/unsave request so rapid taps
  // on the bookmark icon cannot fire duplicate requests or corrupt state.
  final Set<String> _pendingSaveJobIds = <String>{};

  JobFilterParams get currentFilterParams => _currentFilterParams;

  //! ===== Refresh guard =====
  // Tracks an in-flight pull-to-refresh so repeated pulls cannot fire
  // overlapping requests or corrupt state.
  bool _isRefreshingJobs = false;

  Future<void> getJobs({JobFilterParams? params}) async {
    if (params != null) {
      _currentFilterParams = params;
    }

    // 1. Emit cached jobs immediately when available (offline-first).
    final cachedResult = await getCachedJobsUseCase(
      params: _currentFilterParams,
    );
    final cachedEntity = cachedResult.fold((_) => null, (entity) => entity);
    final hasCache =
        cachedEntity != null && cachedEntity.jobs.isNotEmpty;
    if (hasCache) {
      emit(
        JobsFeedLoaded(
          jobs: cachedEntity.jobs,
          pagination: cachedEntity.pagination,
          filterParams: _currentFilterParams,
          isFromCache: true,
          isRefreshing: true,
        ),
      );
    } else {
      //! ===== Emit loading with current filter params =====
      // Passing filterParams ensures the filter-chip BlocBuilder rebuilds
      // immediately with the selected filter rather than waiting for the API.
      emit(JobsFeedLoading(filterParams: _currentFilterParams));
    }

    // 2. Refresh from remote in the background; preserve cache on failure.
    final result = await getJobsUseCase(params: _currentFilterParams);

    result.fold(
      (failure) {
        if (hasCache) {
          final currentState = state;
          if (currentState is JobsFeedLoaded) {
            emit(
              currentState.copyWith(
                isRefreshing: false,
                isFromCache: true,
                errorMessage: failure.message,
              ),
            );
          }
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
              filterParams: _currentFilterParams,
              isFromCache: paginatedEntity.isFromCache,
            ),
          );
        }
      },
    );
  }

  Future<void> refreshJobs() async {
    if (_isRefreshingJobs) return;
    _isRefreshingJobs = true;
    try {
      await _performRefresh();
    } finally {
      _isRefreshingJobs = false;
    }
  }

  Future<void> _performRefresh() async {
    final resetParams = _currentFilterParams.copyWith(page: 1);
    _currentFilterParams = resetParams;

    final currentState = state;
    if (currentState is JobsFeedLoaded) {
      emit(currentState.copyWith(isRefreshing: true));
    } else {
      emit(JobsFeedLoading(filterParams: resetParams));
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

      emit(JobsFeedLoading(filterParams: newParams));

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
    // Prevent rapid repeated taps from firing duplicate requests.
    if (_pendingSaveJobIds.contains(jobId)) return;

    JobEntity? targetJob;
    for (final job in currentState.jobs) {
      if (job.id == jobId) {
        targetJob = job;
        break;
      }
    }
    // Never fall back to another job: toggling an id that is not on screen
    // must not flip some unrelated job locally while the server toggles id.
    if (targetJob == null) return;
    final currentIsSaved = targetJob.isSaved;
    final desiredIsSaved = !currentIsSaved;

    // --- Optimistic UI update: flip the icon immediately, without waiting
    // --- for local persistence or the remote save/unsave request.
    _pendingSaveJobIds.add(jobId);
    final optimisticJobs = currentState.jobs.map((job) {
      if (job.id == jobId) {
        return job.copyWith(isSaved: desiredIsSaved);
      }
      return job;
    }).toList();
    emit(currentState.copyWith(jobs: optimisticJobs, errorMessage: null));

    final result = await toggleSaveJobUseCase(
      jobId,
      currentIsSaved: currentIsSaved,
    );
    _pendingSaveJobIds.remove(jobId);

    result.fold(
      (failure) {
        // --- Reconcile: revert the optimistic flip so local state stays
        // --- truthful, and surface the error without a false success.
        final latestState = state;
        if (latestState is JobsFeedLoaded) {
          final revertedJobs = latestState.jobs.map((job) {
            if (job.id == jobId) {
              return job.copyWith(isSaved: currentIsSaved);
            }
            return job;
          }).toList();
          emit(latestState.copyWith(jobs: revertedJobs, errorMessage: failure.message));
        }
      },
      (updatedEntity) {
        // Reconcile with the server-confirmed value when it differs.
        final latestState = state;
        if (latestState is JobsFeedLoaded) {
          if (updatedEntity.isSaved != desiredIsSaved) {
            final reconciledJobs = latestState.jobs.map((job) {
              if (job.id == jobId) {
                return job.copyWith(isSaved: updatedEntity.isSaved);
              }
              return job;
            }).toList();
            emit(latestState.copyWith(jobs: reconciledJobs, errorMessage: null));
          }
        }
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
