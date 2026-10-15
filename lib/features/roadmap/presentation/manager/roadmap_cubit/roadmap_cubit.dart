import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:MatchIn/features/roadmap/domain/entities/generate_roadmap_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/refresh_roadmap_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmaps_params.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/generate_roadmap_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/refresh_roadmap_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/get_roadmap_details_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/get_roadmaps_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'roadmap_state.dart';

/// Remote-only roadmap flow: list → select → details.
///
/// No mock fallback, no local data cache. UI-only XP
/// ([rewardedAdXp]) stays in [SharedPreferencesService].
class RoadmapCubit extends Cubit<RoadmapState> {
  RoadmapCubit({
    required this.sharedPreferencesService,
    required this.getRoadmapsUseCase,
    required this.getRoadmapDetailsUseCase,
    required this.generateRoadmapUseCase,
    required this.refreshRoadmapUseCase,
  }) : super(RoadmapInitial());

  final SharedPreferencesService sharedPreferencesService;
  final GetRoadmapsUseCase getRoadmapsUseCase;
  final GetRoadmapDetailsUseCase getRoadmapDetailsUseCase;
  final GenerateRoadmapUseCase generateRoadmapUseCase;
  final RefreshRoadmapUseCase refreshRoadmapUseCase;

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

  /// Roadmaps loaded so far, for the selector sheet.
  List<RoadmapEntity> get cachedRoadmaps =>
      List<RoadmapEntity>.unmodifiable(_cachedRoadmaps);

  int? get selectedRoadmapId => _selectedRoadmapId;

  bool get hasMorePages => _currentPage < _lastPage;

  /// Loads the first page and auto-selects the first roadmap.
  /// Awaits the chained details load so callers observe settled state.
  Future<void> loadRoadmaps() async {
    if (state is RoadmapsLoading) return;
    emit(RoadmapsLoading());

    final result = await getRoadmapsUseCase(params: const RoadmapsParams());
    if (isClosed) return;

    int? autoSelectId;
    result.fold(
      (failure) => emit(RoadmapFailure(errorMessage: failure.message)),
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
      emit(
        RoadmapsSuccess(
          roadmaps: List<RoadmapEntity>.unmodifiable(_cachedRoadmaps),
          currentPage: _currentPage,
          lastPage: _lastPage,
          total: _total,
        ),
      );
      final lastDetails = _lastDetails;
      if (lastDetails != null) {
        emit(
          RoadmapDetailsSuccess(
            details: lastDetails,
            rewardedAdXp: sharedPreferencesService.getRewardedAdXp(),
          ),
        );
      }
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
  /// Ignored while an AI refresh is active so an older GET response
  /// cannot overwrite a newer successful refresh.
  Future<void> loadRoadmapDetails(int roadmapId) async {
    if (_aiRefreshing) return;
    if (state is RoadmapLoading) return;
    emit(RoadmapLoading());

    final result = await getRoadmapDetailsUseCase(roadmapId);
    if (isClosed) return;

    result.fold(
      (failure) => emit(RoadmapFailure(errorMessage: failure.message)),
      (details) {
        _lastDetails = details;
        emit(
          RoadmapDetailsSuccess(
            details: details,
            rewardedAdXp: sharedPreferencesService.getRewardedAdXp(),
          ),
        );
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
  /// Returns true when the details were refreshed.
  Future<bool> refreshSelectedRoadmapDetails() async {
    final selectedId = _selectedRoadmapId;
    if (selectedId == null) return false;
    if (state is RoadmapLoading || state is RoadmapsLoading) return false;

    final result = await getRoadmapDetailsUseCase(selectedId);
    if (isClosed) return false;
    var refreshed = false;
    result.fold((_) {}, (details) {
      _lastDetails = details;
      refreshed = true;
    });
    if (!refreshed) return false;
    emit(
      RoadmapDetailsSuccess(
        details: _lastDetails!,
        rewardedAdXp: sharedPreferencesService.getRewardedAdXp(),
      ),
    );
    return true;
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
      final lastDetails = _lastDetails;
      if (lastDetails != null) {
        emit(
          RoadmapDetailsSuccess(
            details: lastDetails,
            rewardedAdXp: sharedPreferencesService.getRewardedAdXp(),
          ),
        );
      }
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
        emit(
          RoadmapDetailsSuccess(details: lastDetails, rewardedAdXp: updatedXp),
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
}
