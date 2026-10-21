import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:MatchIn/features/roadmap/domain/entities/generate_roadmap_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/refresh_roadmap_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmaps_params.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/generate_roadmap_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/get_cached_roadmap_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/refresh_roadmap_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/get_roadmap_details_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/get_roadmaps_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/sync_roadmap_ops_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'roadmap_state.dart';

/// Offline-first roadmap flow: list → select → details.
///
/// Cached roadmaps render immediately; the network refreshes them in the
/// background and the UI updates reactively when fresh data arrives.
/// Offline mutations stay queued durably and [syncPending] replays them
/// when connectivity returns. UI-only XP ([rewardedAdXp]) stays in
/// [SharedPreferencesService].
class RoadmapCubit extends Cubit<RoadmapState> {
  RoadmapCubit({
    required this.sharedPreferencesService,
    required this.getRoadmapsUseCase,
    required this.getRoadmapDetailsUseCase,
    required this.generateRoadmapUseCase,
    required this.refreshRoadmapUseCase,
    required this.getCachedRoadmapUseCase,
    required this.syncRoadmapOpsUseCase,
  }) : super(RoadmapInitial());

  final SharedPreferencesService sharedPreferencesService;
  final GetRoadmapsUseCase getRoadmapsUseCase;
  final GetRoadmapDetailsUseCase getRoadmapDetailsUseCase;
  final GenerateRoadmapUseCase generateRoadmapUseCase;
  final RefreshRoadmapUseCase refreshRoadmapUseCase;
  final GetCachedRoadmapUseCase getCachedRoadmapUseCase;
  final SyncRoadmapOpsUseCase syncRoadmapOpsUseCase;

  List<RoadmapEntity> _cachedRoadmaps = [];
  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;
  int? _selectedRoadmapId;
  RoadmapEntity? _lastDetails;
  bool _loadingMore = false;
  bool _generating = false;
  bool _refreshingList = false;
  bool _aiRefreshing = false;
  bool _syncing = false;

  /// Roadmaps loaded so far, for the selector sheet.
  List<RoadmapEntity> get cachedRoadmaps =>
      List<RoadmapEntity>.unmodifiable(_cachedRoadmaps);

  int? get selectedRoadmapId => _selectedRoadmapId;

  bool get hasMorePages => _currentPage < _lastPage;

  /// Loads the first page and auto-selects the first roadmap.
  /// Cached roadmaps render instantly and are never hidden behind a
  /// loading spinner: the network refreshes them silently in the
  /// background. Awaits the chained details load so callers observe
  /// settled state.
  Future<void> loadRoadmaps() async {
    if (state is RoadmapsLoading) return;
    final cached = await _safeCachedRoadmaps();
    if (isClosed) return;
    if (cached != null && cached.isNotEmpty) {
      _cachedRoadmaps = cached;
      _currentPage = 1;
      _lastPage = 1;
      _total = cached.length;
      final pending = await _safePendingCount();
      if (isClosed) return;
      emit(
        RoadmapsSuccess(
          roadmaps: List<RoadmapEntity>.unmodifiable(_cachedRoadmaps),
          currentPage: _currentPage,
          lastPage: _lastPage,
          total: _total,
          isOffline: true,
          pendingOpsCount: pending,
        ),
      );
      if (_selectedRoadmapId == null) {
        await selectRoadmap(_cachedRoadmaps.first.id);
        if (isClosed) return;
      }
      // Silent background refresh: fresh rows update the snapshot (the
      // selector sheet reads it directly) without flashing loading over
      // valid cached content.
      await _refreshListSilently();
      return;
    }
    emit(RoadmapsLoading());

    final result = await getRoadmapsUseCase(params: const RoadmapsParams());
    if (isClosed) return;

    int? autoSelectId;
    result.fold(
      (failure) {
        if (_cachedRoadmaps.isNotEmpty) {
          emit(
            RoadmapsSuccess(
              roadmaps: List<RoadmapEntity>.unmodifiable(_cachedRoadmaps),
              currentPage: _currentPage,
              lastPage: _lastPage,
              total: _total,
              isOffline: failure is OfflineFailure,
            ),
          );
        } else {
          emit(RoadmapFailure(errorMessage: failure.message));
        }
      },
      (page) {
        _cachedRoadmaps = page.roadmaps;
        _currentPage = page.pagination.currentPage;
        _lastPage = page.pagination.lastPage;
        _total = page.pagination.total;
        emit(
          RoadmapsSuccess(
            roadmaps: List<RoadmapEntity>.unmodifiable(_cachedRoadmaps),
            currentPage: _currentPage,
            lastPage: _lastPage,
            total: _total,
          ),
        );
        if (_selectedRoadmapId == null && _cachedRoadmaps.isNotEmpty) {
          autoSelectId = _cachedRoadmaps.first.id;
        }
      },
    );
    final int? selectedId = autoSelectId;
    if (selectedId != null) {
      await selectRoadmap(selectedId);
    }
  }

  /// Appends the next page. Emits [RoadmapsSuccess] so the selector
  /// sheet refreshes, then restores the details view when one is open.
  /// Returns false without emitting when there is nothing to load or
  /// the request fails; cached items are always preserved.
  Future<bool> loadMoreRoadmaps() async {
    if (_loadingMore) return false;
    if (!hasMorePages) return false;
    _loadingMore = true;
    try {
      final result = await getRoadmapsUseCase(
        params: RoadmapsParams(page: _currentPage + 1),
      );
      if (isClosed) return false;
      var appended = false;
      result.fold((_) {}, (page) {
        _cachedRoadmaps = [..._cachedRoadmaps, ...page.roadmaps];
        _currentPage = page.pagination.currentPage;
        _lastPage = page.pagination.lastPage;
        _total = page.pagination.total;
        appended = true;
      });
      if (!appended) return false;
      final pending = await _safePendingCount();
      if (isClosed) return false;
      emit(
        RoadmapsSuccess(
          roadmaps: List<RoadmapEntity>.unmodifiable(_cachedRoadmaps),
          currentPage: _currentPage,
          lastPage: _lastPage,
          total: _total,
          pendingOpsCount: pending,
        ),
      );
      await _restoreDetails();
      return true;
    } finally {
      _loadingMore = false;
    }
  }

  /// Selects a roadmap and loads its details. Ignored while an AI
  /// refresh is active so a stale selection cannot overwrite it.
  Future<void> selectRoadmap(int roadmapId) async {
    if (_aiRefreshing) return;
    _selectedRoadmapId = roadmapId;
    await loadRoadmapDetails(roadmapId);
  }

  /// Loads one roadmap's details with milestones and tasks.
  /// Cached details render instantly; the network refreshes them in the
  /// background without hiding valid cache. Ignored while an AI refresh
  /// is active so an older GET response cannot overwrite a newer
  /// successful refresh.
  Future<void> loadRoadmapDetails(int roadmapId) async {
    if (_aiRefreshing) return;
    if (state is RoadmapLoading) return;
    final cached = await _safeCachedDetails(roadmapId);
    if (isClosed) return;
    if (cached != null) {
      _lastDetails = cached;
      final pending = await _safePendingCount();
      if (isClosed) return;
      emit(
        RoadmapDetailsSuccess(
          details: cached,
          rewardedAdXp: sharedPreferencesService.getRewardedAdXp(),
          isOffline: true,
          pendingOpsCount: pending,
        ),
      );
    } else {
      emit(RoadmapLoading());
    }

    final result = await getRoadmapDetailsUseCase(roadmapId);
    if (isClosed) return;

    result.fold(
      (failure) {
        if (_lastDetails != null && _selectedRoadmapId == roadmapId) {
          emit(
            RoadmapDetailsSuccess(
              details: _lastDetails!,
              rewardedAdXp: sharedPreferencesService.getRewardedAdXp(),
              isOffline: failure is OfflineFailure,
              pendingOpsCount: 0,
            ),
          );
          _refreshPendingCount();
        } else if (_lastDetails == null) {
          emit(RoadmapFailure(errorMessage: failure.message));
        }
      },
      (details) {
        // Stale-response guard: a superseded selection must not
        // overwrite the current view. No selection means no race.
        if (_selectedRoadmapId != null && _selectedRoadmapId != roadmapId) {
          return;
        }
        _lastDetails = details;
        emit(
          RoadmapDetailsSuccess(
            details: details,
            rewardedAdXp: sharedPreferencesService.getRewardedAdXp(),
          ),
        );
        _refreshPendingCount();
      },
    );
  }

  /// Retries the current context: details when a roadmap is selected,
  /// otherwise the list.
  Future<void> retry() async {
    final selectedId = _selectedRoadmapId;
    if (selectedId != null) {
      await loadRoadmapDetails(selectedId);
    } else {
      await loadRoadmaps();
    }
  }

  /// Silently refreshes the selected roadmap's details (used after a
  /// task completion): on success the fresh details are emitted; on
  /// failure nothing is emitted so the displayed roadmap is preserved.
  /// Offline it re-reads the durable local cache so queued completions
  /// appear immediately. Returns true when the details were refreshed.
  Future<bool> refreshSelectedRoadmapDetails() async {
    final selectedId = _selectedRoadmapId;
    if (selectedId == null) return false;
    if (state is RoadmapLoading || state is RoadmapsLoading) return false;

    final result = await getRoadmapDetailsUseCase(selectedId);
    if (isClosed) return false;
    var refreshed = false;
    var fromNetwork = false;
    result.fold((_) {}, (details) {
      _lastDetails = details;
      refreshed = true;
      fromNetwork = true;
    });
    if (!refreshed) {
      // Offline or failed refresh: fall back to the durable cache, which
      // already holds locally applied completions.
      final cached = await _safeCachedDetails(selectedId);
      if (isClosed || cached == null) return false;
      _lastDetails = cached;
      refreshed = true;
    }
    final pending = await _safePendingCount();
    if (isClosed) return false;
    emit(
      RoadmapDetailsSuccess(
        details: _lastDetails!,
        rewardedAdXp: sharedPreferencesService.getRewardedAdXp(),
        isOffline: !fromNetwork,
        pendingOpsCount: pending,
      ),
    );
    return true;
  }

  /// Re-reads the selected roadmap from the durable local cache and
  /// emits it immediately without any network wait. Callers invoke it
  /// right after mutating local state (optimistic paint, rollback
  /// repaint, queued offline mutation), so the cache is the freshest
  /// source at that point. Returns true when local details were emitted.
  Future<bool> refreshFromLocalCache() async {
    final selectedId = _selectedRoadmapId;
    if (selectedId == null) return false;
    final cached = await _safeCachedDetails(selectedId);
    if (isClosed || cached == null) return false;
    _lastDetails = cached;
    final pending = await _safePendingCount();
    if (isClosed) return false;
    emit(
      RoadmapDetailsSuccess(
        details: cached,
        rewardedAdXp: sharedPreferencesService.getRewardedAdXp(),
        pendingOpsCount: pending,
      ),
    );
    return true;
  }

  /// Replays durable pending ops (manual retry + connectivity-restore
  /// path). Refreshes the displayed details when sync made progress.
  /// Returns true when at least one op synchronized.
  Future<bool> syncPending() async {
    if (_syncing) return false;
    _syncing = true;
    try {
      final report = await syncRoadmapOpsUseCase();
      if (isClosed) return false;
      if (report.didWork) {
        await refreshSelectedRoadmapDetails();
        return true;
      }
      await _refreshPendingCount();
      return false;
    } finally {
      _syncing = false;
    }
  }

  /// Reloads the first page for the selector sheet without disturbing
  /// the details view: on success the list snapshot refreshes and the
  /// current details are restored; on failure cached items are kept.
  /// Returns false when nothing was refreshed.
  Future<bool> refreshRoadmapList() async {
    if (_refreshingList) return false;
    if (state is RoadmapsLoading || state is RoadmapLoading) return false;
    _refreshingList = true;
    try {
      final result = await getRoadmapsUseCase(params: const RoadmapsParams());
      if (isClosed) return false;
      var refreshed = false;
      result.fold((_) {}, (page) {
        _cachedRoadmaps = page.roadmaps;
        _currentPage = page.pagination.currentPage;
        _lastPage = page.pagination.lastPage;
        _total = page.pagination.total;
        refreshed = true;
      });
      if (!refreshed) return false;
      emit(
        RoadmapsSuccess(
          roadmaps: List<RoadmapEntity>.unmodifiable(_cachedRoadmaps),
          currentPage: _currentPage,
          lastPage: _lastPage,
          total: _total,
        ),
      );
      await _restoreDetails();
      return true;
    } finally {
      _refreshingList = false;
    }
  }

  /// Generates a roadmap via AI. Emits progress preserving current
  /// content, then either the new details or a content-preserving
  /// failure for inline display. Duplicate calls collapse into one.
  Future<void> generateRoadmap(GenerateRoadmapParams params) async {
    if (_generating || _aiRefreshing) return;
    _generating = true;
    try {
      emit(
        RoadmapGenerating(
          details: _lastDetails,
          rewardedAdXp: sharedPreferencesService.getRewardedAdXp(),
        ),
      );
      final result = await generateRoadmapUseCase(params);
      if (isClosed) return;
      result.fold(
        (failure) => emit(
          RoadmapGenerateFailure(
            message: failure.message,
            fieldErrors: failure is ServerFailure
                ? failure.fieldErrors
                : const {},
            details: _lastDetails,
            rewardedAdXp: sharedPreferencesService.getRewardedAdXp(),
          ),
        ),
        (roadmap) {
          _selectedRoadmapId = roadmap.id;
          _lastDetails = roadmap;
          emit(
            RoadmapDetailsSuccess(
              details: roadmap,
              rewardedAdXp: sharedPreferencesService.getRewardedAdXp(),
            ),
          );
        },
      );
    } finally {
      _generating = false;
    }
  }

  /// Refreshes the selected roadmap with AI. Keeps the current content
  /// visible (no full-screen loading), collapses duplicate calls, and
  /// refuses to run alongside generation. The returned roadmap is
  /// authoritative: selection and the cached list entry are reconciled
  /// with its id, which may differ from the requested one. No follow-up
  /// GET is issued after a valid response.
  Future<void> aiRefreshSelectedRoadmap({String? reason}) async {
    if (_aiRefreshing || _generating) return;
    if (state is RoadmapLoading || state is RoadmapsLoading) return;
    final selectedId = _selectedRoadmapId;
    final baseline = _lastDetails;
    if (selectedId == null || baseline == null) return;
    _aiRefreshing = true;
    try {
      emit(
        RoadmapAiRefreshing(
          details: baseline,
          rewardedAdXp: sharedPreferencesService.getRewardedAdXp(),
        ),
      );
      final result = await refreshRoadmapUseCase(
        RefreshRoadmapParams(roadmapId: selectedId, reason: reason),
      );
      if (isClosed) return;
      result.fold(
        (failure) => emit(
          RoadmapAiRefreshFailure(
            message: failure.message,
            fieldErrors: failure is ServerFailure
                ? failure.fieldErrors
                : const {},
            details: _lastDetails,
            rewardedAdXp: sharedPreferencesService.getRewardedAdXp(),
          ),
        ),
        (roadmap) {
          _selectedRoadmapId = roadmap.id;
          final updated = List<RoadmapEntity>.of(_cachedRoadmaps);
          final sameIndex = updated.indexWhere(
            (cached) => cached.id == roadmap.id,
          );
          if (sameIndex >= 0) {
            updated[sameIndex] = roadmap;
          } else {
            final oldIndex = updated.indexWhere(
              (cached) => cached.id == selectedId,
            );
            if (oldIndex >= 0) {
              updated[oldIndex] = roadmap;
            } else {
              updated.add(roadmap);
            }
          }
          _cachedRoadmaps = updated;
          _lastDetails = roadmap;
          emit(
            RoadmapDetailsSuccess(
              details: roadmap,
              rewardedAdXp: sharedPreferencesService.getRewardedAdXp(),
            ),
          );
        },
      );
    } finally {
      _aiRefreshing = false;
    }
  }

  Future<void> addRewardedAdXp(int amount) async {
    try {
      final currentXp = sharedPreferencesService.getRewardedAdXp();
      final updatedXp = currentXp + amount;
      await sharedPreferencesService.saveRewardedAdXp(updatedXp);

      final lastDetails = _lastDetails;
      if (state is RoadmapDetailsSuccess && lastDetails != null) {
        final current = state as RoadmapDetailsSuccess;
        emit(
          RoadmapDetailsSuccess(
            details: lastDetails,
            rewardedAdXp: updatedXp,
            isOffline: current.isOffline,
            pendingOpsCount: current.pendingOpsCount,
          ),
        );
      } else if (_selectedRoadmapId != null) {
        await loadRoadmapDetails(_selectedRoadmapId!);
      } else {
        await loadRoadmaps();
      }
    } catch (e) {
      emit(RoadmapFailure(errorMessage: e.toString()));
    }
  }

  //! ===== Durable-cache + sync helpers =====

  /// Re-fetches the first page without emitting: the snapshot backing the
  /// selector sheet stays current while whatever is on screen (usually
  /// the details view) is never replaced by loading.
  Future<void> _refreshListSilently() async {
    final result = await getRoadmapsUseCase(params: const RoadmapsParams());
    if (isClosed) return;
    result.fold((_) {}, (page) {
      _cachedRoadmaps = page.roadmaps;
      _currentPage = page.pagination.currentPage;
      _lastPage = page.pagination.lastPage;
      _total = page.pagination.total;
    });
  }

  Future<List<RoadmapEntity>?> _safeCachedRoadmaps() async {
    try {
      return await getCachedRoadmapUseCase.cachedRoadmaps();
    } catch (_) {
      return null;
    }
  }

  Future<RoadmapEntity?> _safeCachedDetails(int roadmapId) async {
    try {
      return await getCachedRoadmapUseCase.cachedRoadmapDetails(roadmapId);
    } catch (_) {
      return null;
    }
  }

  Future<int> _safePendingCount() async {
    try {
      return await syncRoadmapOpsUseCase.pendingCount();
    } catch (_) {
      return 0;
    }
  }

  Future<void> _refreshPendingCount() async {
    if (isClosed) return;
    final current = state;
    if (current is! RoadmapDetailsSuccess) return;
    final pending = await _safePendingCount();
    if (isClosed) return;
    final latest = state;
    if (latest is RoadmapDetailsSuccess && latest.pendingOpsCount != pending) {
      emit(
        RoadmapDetailsSuccess(
          details: latest.details,
          rewardedAdXp: latest.rewardedAdXp,
          isOffline: latest.isOffline,
          pendingOpsCount: pending,
        ),
      );
    }
  }

  Future<void> _restoreDetails() async {
    final lastDetails = _lastDetails;
    if (lastDetails != null && !isClosed) {
      final pending = await _safePendingCount();
      if (isClosed) return;
      emit(
        RoadmapDetailsSuccess(
          details: lastDetails,
          rewardedAdXp: sharedPreferencesService.getRewardedAdXp(),
          pendingOpsCount: pending,
        ),
      );
    }
  }
}
