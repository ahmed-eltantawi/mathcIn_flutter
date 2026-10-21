import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_item_model.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_node.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_sync_op.dart';
import 'package:MatchIn/features/roadmap/domain/entities/award_xp_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/award_xp_response_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/candidate_xp_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_xp_metrics_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/treasure_rewards.dart';
import 'package:MatchIn/features/roadmap/domain/repositories/roadmap_repository.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/award_xp_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/get_candidate_xp_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/get_roadmap_xp_use_case.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/treasure_cubit/treasure_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/xp_cubit/xp_cubit.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeXpRepository extends Fake implements RoadmapRepository {
  Either<Failure, CandidateXpEntity>? candidateXpResult;
  Either<Failure, RoadmapXpMetricsEntity>? roadmapXpResult;
  Either<Failure, AwardXpResponseEntity>? awardXpResult;
  int awardXpCalls = 0;
  final Map<int, Set<int>> collected = {};
  final Map<int, Set<int>> synced = {};

  @override
  Future<Either<Failure, CandidateXpEntity>> getCandidateXp({
    int? roadmapId,
  }) async => candidateXpResult!;

  @override
  Future<Either<Failure, RoadmapXpMetricsEntity>> getRoadmapXp(
    int roadmapId,
  ) async => roadmapXpResult!;

  @override
  Future<Either<Failure, AwardXpResponseEntity>> awardXp(
    AwardXpParams params, {
    required String opKey,
  }) async {
    awardXpCalls++;
    return awardXpResult!;
  }

  @override
  Future<Set<int>> getCollectedTreasures(int roadmapId) async =>
      Set<int>.of(collected[roadmapId] ?? const {});

  @override
  Future<void> collectTreasure(int roadmapId, int milestoneIndex) async {
    collected.putIfAbsent(roadmapId, () => <int>{}).add(milestoneIndex);
  }

  @override
  Future<Set<int>> getSyncedTreasures(int roadmapId) async =>
      Set<int>.of(synced[roadmapId] ?? const {});
}

RoadmapNode node(int index, {bool completed = false}) => RoadmapNode(
  id: '$index',
  title: 'Task $index',
  status: completed
      ? RoadmapTaskStatus.completed
      : (index == 1 ? RoadmapTaskStatus.active : RoadmapTaskStatus.locked),
  tasks: const [],
);

void main() {
  group('Treasure eligibility (every five task nodes)', () {
    test('unlocks box 1 at 5, box 2 at 10, box 3 at 15 completions', () {
      List<RoadmapNode> nodes(int total, int completedCount) => List.generate(
        total,
        (i) => node(i + 1, completed: i < completedCount),
      );

      expect(RoadmapItem.isMilestoneUnlocked(nodes(15, 5), 1), isTrue);
      expect(RoadmapItem.isMilestoneUnlocked(nodes(15, 5), 2), isFalse);
      expect(RoadmapItem.isMilestoneUnlocked(nodes(15, 10), 2), isTrue);
      expect(RoadmapItem.isMilestoneUnlocked(nodes(15, 15), 3), isTrue);
      expect(RoadmapItem.isMilestoneUnlocked(nodes(15, 14), 3), isFalse);
    });

    test('requires every leading node completed, not just the fifth', () {
      // Fifth node completed while an earlier one is not: still locked.
      final nodes = List.generate(5, (i) => node(i + 1, completed: true));
      final tampered = [...nodes];
      tampered[1] = node(2);
      expect(RoadmapItem.isMilestoneUnlocked(tampered, 1), isFalse);
    });

    test('short roadmaps never unlock', () {
      final nodes = List.generate(4, (i) => node(i + 1, completed: true));
      expect(RoadmapItem.isMilestoneUnlocked(nodes, 1), isFalse);
      expect(RoadmapItem.isMilestoneUnlocked(nodes, 0), isFalse);
    });

    test('reward constants stay +50 XP per five nodes', () {
      expect(TreasureRewards.nodesPerMilestone, 5);
      expect(TreasureRewards.xpPerMilestone, 50);
      expect(TreasureRewards.unlockedMilestones(10), [1, 2]);
    });
  });

  group('TreasureCubit rewards', () {
    test('first claim collects once; repeats are no-ops', () async {
      final repo = FakeXpRepository()
        ..awardXpResult = const Right(
          AwardXpResponseEntity(xpAdded: 50, earnedXp: 300),
        );
      final cubit = TreasureCubit(
        repository: repo,
        awardXpUseCase: AwardXpUseCase(repository: repo),
      );
      addTearDown(cubit.close);

      await cubit.loadLedger(1);
      expect(
        await cubit.claimTreasure(roadmapId: 1, milestoneIndex: 1),
        isTrue,
      );
      expect(
        await cubit.claimTreasure(roadmapId: 1, milestoneIndex: 1),
        isFalse,
      );
      expect(repo.awardXpCalls, 1);

      final state = cubit.state as TreasureLoaded;
      expect(state.collectedTreasures, contains(1));
    });

    test(
      'offline claim stays collected with XP pending, no double award',
      () async {
        final repo = FakeXpRepository()
          ..awardXpResult = const Left(OfflineFailure());
        final cubit = TreasureCubit(
          repository: repo,
          awardXpUseCase: AwardXpUseCase(repository: repo),
        );
        addTearDown(cubit.close);

        expect(
          await cubit.claimTreasure(roadmapId: 7, milestoneIndex: 2),
          isTrue,
        );

        final state = cubit.state as TreasureLoaded;
        expect(state.roadmapId, 7);
        expect(state.collectedTreasures, contains(2));
        // Server never confirmed: XP stays pending, never false-awarded.
        expect(state.pendingXpTreasures, contains(2));
        expect(state.syncedTreasures.contains(2), isFalse);
      },
    );

    test('ledgers are scoped per roadmap', () async {
      final repo = FakeXpRepository()
        ..awardXpResult = const Right(
          AwardXpResponseEntity(xpAdded: 50, earnedXp: 300),
        );
      final cubit = TreasureCubit(
        repository: repo,
        awardXpUseCase: AwardXpUseCase(repository: repo),
      );
      addTearDown(cubit.close);

      await cubit.claimTreasure(roadmapId: 1, milestoneIndex: 1);
      await cubit.loadLedger(2);

      expect((cubit.state as TreasureLoaded).collectedTreasures, isEmpty);
    });
  });

  group('RoadmapXpCubit', () {
    test('loads authoritative XP and flags level-ups exactly once', () async {
      final repo = FakeXpRepository()
        ..candidateXpResult = const Right(
          CandidateXpEntity(totalXp: 275, level: 3, levelTitle: 'Seeker'),
        );
      final cubit = RoadmapXpCubit(
        getCandidateXpUseCase: GetCandidateXpUseCase(repository: repo),
        getRoadmapXpUseCase: GetRoadmapXpUseCase(repository: repo),
      );
      addTearDown(cubit.close);

      await cubit.loadCandidateXp();
      var state = cubit.state as XpLoaded;
      expect(state.candidateXp.totalXp, 275);
      expect(state.justLeveledUp, isFalse);

      // Same level again: no replayed animation.
      await cubit.loadCandidateXp();
      state = cubit.state as XpLoaded;
      expect(state.justLeveledUp, isFalse);

      // Genuine transition raises the flag once, then it is consumed.
      repo.candidateXpResult = const Right(
        CandidateXpEntity(totalXp: 320, level: 4, levelTitle: 'Riser'),
      );
      await cubit.loadCandidateXp();
      expect((cubit.state as XpLoaded).justLeveledUp, isTrue);
      cubit.acknowledgeLevelUp();
      expect((cubit.state as XpLoaded).justLeveledUp, isFalse);
    });

    test('keeps cached display on failure instead of erroring', () async {
      final repo = FakeXpRepository()
        ..candidateXpResult = const Right(
          CandidateXpEntity(totalXp: 275, level: 3),
        );
      final cubit = RoadmapXpCubit(
        getCandidateXpUseCase: GetCandidateXpUseCase(repository: repo),
        getRoadmapXpUseCase: GetRoadmapXpUseCase(repository: repo),
      );
      addTearDown(cubit.close);

      await cubit.loadCandidateXp();
      repo.candidateXpResult = const Left(ServerFailure(message: 'Down'));
      await cubit.loadCandidateXp();

      final state = cubit.state as XpLoaded;
      expect(state.candidateXp.totalXp, 275);
    });
  });

  group('RoadmapSyncOp', () {
    test('stable keys dedup and backoff is bounded', () {
      expect(RoadmapSyncOp.treasureKey(1, 2), 'treasure_1_2');
      expect(RoadmapSyncOp.completeTaskKey(7), 'complete_7');
      expect(RoadmapSyncOp.backoffDelayMs(1), 8000);
      expect(RoadmapSyncOp.backoffDelayMs(100), 300000);

      final op = const RoadmapSyncOp(
        opKey: 'complete_7',
        type: RoadmapSyncOp.typeCompleteTask,
        payload: {'taskId': 7},
        createdAtMs: 0,
      );
      final roundTripped = RoadmapSyncOp.fromJson(op.toJson());
      expect(roundTripped.opKey, 'complete_7');
      expect(roundTripped.isDue(0), isTrue);
      final retried = op.withAttempt(1000);
      expect(retried.attempts, 1);
      expect(retried.isDue(1000), isFalse);
    });
  });
}
