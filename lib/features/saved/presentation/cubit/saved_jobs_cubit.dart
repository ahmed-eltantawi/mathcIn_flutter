import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/jobs_feed_cubit.dart';
import 'package:MatchIn/features/saved/domain/entities/saved_job_entity.dart';
import 'package:MatchIn/features/saved/domain/use_cases/get_saved_jobs_use_case.dart';
import 'package:MatchIn/features/saved/domain/use_cases/set_saved_job_use_case.dart';
import 'package:MatchIn/features/saved/domain/use_cases/set_unsaved_job_use_case.dart';
import 'package:MatchIn/features/saved/domain/use_cases/sync_saved_jobs_use_case.dart';
import 'package:MatchIn/features/saved/presentation/cubit/saved_jobs_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Offline-first saved-jobs flow: the durable local snapshot is the
/// source of truth. Toggles persist + queue BEFORE any network attempt,
/// so the UI updates instantly and offline intent survives restarts.
/// A delayed API response can never overwrite a newer local action.
class SavedJobsCubit extends Cubit<SavedJobsState> {
  SavedJobsCubit({
    required this.getSavedJobsUseCase,
    required this.setSavedJobUseCase,
    required this.setUnsavedJobUseCase,
    required this.syncSavedJobsUseCase,
  }) : super(const SavedJobsInitial());

  final GetSavedJobsUseCase getSavedJobsUseCase;
  final SetSavedJobUseCase setSavedJobUseCase;
  final SetUnsavedJobUseCase setUnsavedJobUseCase;
  final SyncSavedJobsUseCase syncSavedJobsUseCase;

  //! ===== Optimistic bookmark handling =====
  // Guards against rapid repeated taps firing duplicate save/unsave calls.
  final Set<int> _pendingBookmarkIds = <int>{};
  bool _syncing = false;

  Future<void> fetchSavedJobs({bool isRefresh = false}) async {
    final currentState = state;
    if (isRefresh && currentState is SavedJobsLoaded) {
      // Keep displaying currently loaded jobs while refreshing
    } else if (state is! SavedJobsLoaded) {
      emit(const SavedJobsLoading());
    }

    final result = await getSavedJobsUseCase(page: 1, perPage: 15);

    if (isClosed) return;
    final pending = await _safePendingCount();
    if (isClosed) return;
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
            pendingCount: pending,
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

    if (isClosed) return;
    result.fold(
      (failure) {
        emit(currentState.copyWith(isLoadingMore: false));
      },
      (paginated) {
        // Deduplicate by stable backend id: local intentions and
        // overlapping pages must never create duplicate rows.
        final knownIds = currentState.jobs.map((job) => job.id).toSet();
        final freshJobs = paginated.jobs
            .where((job) => !knownIds.contains(job.id))
            .toList();
        final updatedJobs = List<SavedJobEntity>.from(currentState.jobs)
          ..addAll(freshJobs);
        emit(
          SavedJobsLoaded(
            jobs: updatedJobs,
            currentPage: paginated.currentPage,
            hasMore: paginated.hasMorePages,
            total: paginated.total,
            isLoadingMore: false,
            pendingCount: currentState.pendingCount,
          ),
        );
      },
    );
  }

  /// Local-first toggle: persists the intent durably and updates the UI
  /// immediately, then best-effort syncs in the background. Rapid taps
  /// collapse into one in-flight mutation per job.
  Future<void> toggleBookmark(SavedJobEntity job) async {
    final currentState = state;
    if (currentState is! SavedJobsLoaded) return;
    if (_pendingBookmarkIds.contains(job.id)) return;
    _pendingBookmarkIds.add(job.id);
    try {
      if (job.isSaved) {
        await _applyUnsave(currentState, job);
      } else {
        await _applySave(currentState, job);
      }
    } finally {
      _pendingBookmarkIds.remove(job.id);
    }
  }

  Future<void> _applyUnsave(
    SavedJobsLoaded currentState,
    SavedJobEntity job,
  ) async {
    // 1. UI + durable local removal first (never resurrectable by a
    //    delayed response).
    final updatedJobs = currentState.jobs.where((j) => j.id != job.id).toList();
    final pending = await _safePendingCount();
    if (isClosed) return;
    emit(
      currentState.copyWith(
        jobs: updatedJobs,
        total: currentState.total > 0 ? currentState.total - 1 : 0,
        pendingCount: pending,
      ),
    );
    _pushFeedStatus(job.id, false);

    // 2. Persist + queue, then background-sync.
    await setUnsavedJobUseCase(job.id);
    if (isClosed) return;
    await _syncInBackground();
  }

  Future<void> _applySave(
    SavedJobsLoaded currentState,
    SavedJobEntity job,
  ) async {
    // 1. Persist + queue first; UI updates from the local source of truth.
    await setSavedJobUseCase(job.copyWith(isSaved: true));
    if (isClosed) return;
    final localJobs = await _readLocalJobs();
    if (isClosed) return;
    if (localJobs != null) {
      final pending = await _safePendingCount();
      if (isClosed) return;
      emit(
        currentState.copyWith(
          jobs: localJobs,
          total: localJobs.length,
          pendingCount: pending,
        ),
      );
    }
    _pushFeedStatus(job.id, true);

    // 2. Background-sync the queued intent.
    await _syncInBackground();
  }

  /// Replays the durable queue (reconnect/foreground/manual path).
  /// Refreshes the visible list when sync made progress.
  Future<void> syncPendingJobs() async {
    if (_syncing) return;
    _syncing = true;
    try {
      final report = await syncSavedJobsUseCase();
      if (isClosed) return;
      if (report.didWork) {
        await fetchSavedJobs(isRefresh: true);
      } else {
        await _refreshPendingCount();
      }
    } finally {
      _syncing = false;
    }
  }

  Future<List<SavedJobEntity>?> _readLocalJobs() async {
    try {
      return await syncSavedJobsUseCase.repository.getLocalSavedJobs();
    } catch (_) {
      return null;
    }
  }

  Future<int> _safePendingCount() async {
    try {
      return await syncSavedJobsUseCase.pendingCount();
    } catch (_) {
      return 0;
    }
  }

  Future<void> _refreshPendingCount() async {
    if (isClosed) return;
    final current = state;
    if (current is! SavedJobsLoaded) return;
    final pending = await _safePendingCount();
    if (isClosed) return;
    final latest = state;
    if (latest is SavedJobsLoaded && latest.pendingCount != pending) {
      emit(latest.copyWith(pendingCount: pending));
    }
  }

  Future<void> _syncInBackground() async {
    if (_syncing) return;
    _syncing = true;
    try {
      await syncSavedJobsUseCase();
      if (isClosed) return;
      await _refreshPendingCount();
    } finally {
      _syncing = false;
    }
  }

  void _pushFeedStatus(int jobPostId, bool isSaved) {
    if (getIt.isRegistered<JobsFeedCubit>()) {
      getIt<JobsFeedCubit>().updateJobSavedStatus(
        jobId: jobPostId.toString(),
        isSaved: isSaved,
      );
    }
  }
}
