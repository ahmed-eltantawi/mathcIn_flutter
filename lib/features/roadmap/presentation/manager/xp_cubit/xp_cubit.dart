import 'package:MatchIn/features/roadmap/domain/entities/candidate_xp_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_xp_metrics_entity.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/get_candidate_xp_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/get_roadmap_xp_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'xp_state.dart';

/// Candidate-wide and per-roadmap XP, backed by authoritative backend
/// values with a durable local cache for offline display.
///
/// No XP total is ever invented here: [CandidateXpEntity] and
/// [RoadmapXpMetricsEntity] come from `GET /roadmaps/xp` and
/// `GET /roadmaps/{roadmap}/xp` (or their caches). The level-up flag is
/// raised only on an observed transition to a higher level, so repeated
/// API responses never replay the animation.
class RoadmapXpCubit extends Cubit<RoadmapXpState> {
  RoadmapXpCubit({
    required this.getCandidateXpUseCase,
    required this.getRoadmapXpUseCase,
  }) : super(const XpInitial());

  final GetCandidateXpUseCase getCandidateXpUseCase;
  final GetRoadmapXpUseCase getRoadmapXpUseCase;

  bool _loadingCandidate = false;
  final Set<int> _loadingRoadmaps = {};

  Future<void> loadCandidateXp() async {
    if (_loadingCandidate) return;
    final previous = state is XpLoaded ? (state as XpLoaded).candidateXp : null;
    // Keep cached display visible: full loading only on first load.
    if (previous == null && state is! XpLoading) emit(const XpLoading());
    _loadingCandidate = true;
    try {
      final result = await getCandidateXpUseCase();
      if (isClosed) return;
      result.fold(
        (failure) {
          if (previous == null) {
            emit(XpFailure(message: failure.message));
          }
        },
        (xp) {
          final leveledUp = previous != null && xp.level > previous.level;
          emit(XpLoaded(candidateXp: xp, justLeveledUp: leveledUp));
        },
      );
    } finally {
      _loadingCandidate = false;
    }
  }

  Future<void> loadRoadmapXp(int roadmapId) async {
    if (_loadingRoadmaps.contains(roadmapId)) return;
    _loadingRoadmaps.add(roadmapId);
    try {
      final result = await getRoadmapXpUseCase(roadmapId);
      if (isClosed) return;
      result.fold((_) {}, (metrics) {
        final current = state;
        if (current is XpLoaded) {
          emit(
            XpLoaded(
              candidateXp: current.candidateXp,
              roadmapXp: metrics,
              justLeveledUp: false,
            ),
          );
        }
      });
    } finally {
      _loadingRoadmaps.remove(roadmapId);
    }
  }

  /// Clears the one-shot level-up flag after the UI played its animation.
  void acknowledgeLevelUp() {
    final current = state;
    if (current is XpLoaded && current.justLeveledUp) {
      emit(
        XpLoaded(
          candidateXp: current.candidateXp,
          roadmapXp: current.roadmapXp,
        ),
      );
    }
  }
}
