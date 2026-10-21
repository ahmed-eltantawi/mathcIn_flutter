import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_sync_op.dart';
import 'package:MatchIn/features/roadmap/domain/entities/award_xp_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/treasure_rewards.dart';
import 'package:MatchIn/features/roadmap/domain/repositories/roadmap_repository.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/award_xp_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'treasure_state.dart';

/// Per-roadmap treasure-box reward ledger with a guarded +50 XP award.
///
/// Eligibility is derived by the UI from actual task completion state;
/// this cubit owns persistence and idempotency:
/// - collection is recorded in a durable per-roadmap ledger (survives
///   restarts) and can happen exactly once per milestone;
/// - the +50 XP award goes through the single canonical
///   `PATCH /roadmaps/xp` route keyed by a stable op id, so repeated taps,
///   retries, and restarts never award twice;
/// - offline claims stay collected locally with XP pending until the
///   server confirms (never false XP).
class TreasureCubit extends Cubit<TreasureState> {
  TreasureCubit({required this.repository, required this.awardXpUseCase})
    : super(const TreasureInitial());

  final RoadmapRepository repository;
  final AwardXpUseCase awardXpUseCase;

  final Set<String> _claiming = {};

  Future<void> loadLedger(int roadmapId) async {
    try {
      final collected = await repository.getCollectedTreasures(roadmapId);
      final synced = await repository.getSyncedTreasures(roadmapId);
      if (isClosed) return;
      emit(
        TreasureLoaded(
          roadmapId: roadmapId,
          collectedTreasures: collected,
          syncedTreasures: synced,
        ),
      );
    } catch (e) {
      if (!isClosed) emit(TreasureFailure(errorMessage: e.toString()));
    }
  }

  /// Claims milestone [milestoneIndex] of [roadmapId].
  ///
  /// Returns true only when the reward is collected for the first time
  /// (callers show the success SnackBar only then). Repeated calls for
  /// an already-collected milestone are no-ops returning false.
  Future<bool> claimTreasure({
    required int roadmapId,
    required int milestoneIndex,
    int? taskId,
    int? milestoneId,
  }) async {
    final key = '${roadmapId}_$milestoneIndex';
    if (_claiming.contains(key)) return false;
    final current = state;
    if (current is TreasureLoaded &&
        current.roadmapId == roadmapId &&
        current.collectedTreasures.contains(milestoneIndex)) {
      return false;
    }
    _claiming.add(key);
    try {
      final collected = await repository.getCollectedTreasures(roadmapId);
      if (collected.contains(milestoneIndex)) {
        await _emitLedger(roadmapId);
        return false;
      }
      await repository.collectTreasure(roadmapId, milestoneIndex);
      await _emitLedger(roadmapId);

      final result = await awardXpUseCase(
        AwardXpParams(
          xp: TreasureRewards.xpPerMilestone,
          reason: TreasureRewards.reasonFor(milestoneIndex),
          roadmapId: roadmapId,
          taskId: taskId,
          milestoneId: milestoneId ?? milestoneIndex,
        ),
        opKey: RoadmapSyncOp.treasureKey(roadmapId, milestoneIndex),
      );
      // OfflineFailure here means the award was queued durably: the box
      // stays collected (open) with XP pending until sync confirms it.
      result.fold((failure) {
        if (failure is! OfflineFailure) {
          // Server rejections keep the local collection (single-claim
          // rule) but XP stays unconfirmed; a later retry reuses the
          // same stable op key instead of duplicating the reward.
        }
      }, (_) {});
      await _emitLedger(roadmapId);
      return true;
    } finally {
      _claiming.remove(key);
    }
  }

  Future<void> _emitLedger(int roadmapId) async {
    if (isClosed) return;
    try {
      final collected = await repository.getCollectedTreasures(roadmapId);
      final synced = await repository.getSyncedTreasures(roadmapId);
      if (isClosed) return;
      emit(
        TreasureLoaded(
          roadmapId: roadmapId,
          collectedTreasures: collected,
          syncedTreasures: synced,
        ),
      );
    } catch (e) {
      if (!isClosed) emit(TreasureFailure(errorMessage: e.toString()));
    }
  }
}
