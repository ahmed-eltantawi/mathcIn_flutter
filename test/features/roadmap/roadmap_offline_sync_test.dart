import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/core/errors/error_model.dart';
import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/networking/network_info.dart';
import 'package:MatchIn/features/roadmap/data/data_sources/roadmap_local_data_source.dart';
import 'package:MatchIn/features/roadmap/data/data_sources/roadmap_local_data_source_impl.dart';
import 'package:MatchIn/features/roadmap/data/data_sources/roadmap_remote_data_source.dart';
import 'package:MatchIn/features/roadmap/data/models/award_xp_response_model.dart';
import 'package:MatchIn/features/roadmap/data/models/candidate_xp_model.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_model.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_milestone_model.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_task_model.dart';
import 'package:MatchIn/features/roadmap/data/repositories/roadmap_repository_impl.dart';
import 'package:MatchIn/features/roadmap/domain/entities/award_xp_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/complete_roadmap_task_params.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeSyncRemote extends Fake implements RoadmapRemoteDataSource {
  Object? completeError;
  RoadmapTaskModel? completeResponse;
  int completeCalls = 0;

  Object? detailsError;
  RoadmapModel? detailsResponse;
  int detailsCalls = 0;

  Object? awardError;
  AwardXpResponseModel? awardResponse;
  int awardCalls = 0;

  Object? candidateXpError;
  CandidateXpModel? candidateXpResponse;

  @override
  Future<RoadmapTaskModel> completeRoadmapTask(
    CompleteRoadmapTaskParams params,
  ) async {
    completeCalls++;
    if (completeError != null) throw completeError!;
    return completeResponse!;
  }

  @override
  Future<RoadmapModel> getRoadmapDetails(int roadmapId) async {
    detailsCalls++;
    if (detailsError != null) throw detailsError!;
    return detailsResponse!;
  }

  @override
  Future<AwardXpResponseModel> awardXp(AwardXpParams params) async {
    awardCalls++;
    if (awardError != null) throw awardError!;
    return awardResponse!;
  }

  @override
  Future<CandidateXpModel> getCandidateXp({int? roadmapId}) async {
    if (candidateXpError != null) throw candidateXpError!;
    return candidateXpResponse!;
  }
}

class FakeSyncNetwork extends Fake implements NetworkInfo {
  FakeSyncNetwork({this.connected = true});

  bool connected;

  @override
  Future<bool> get isConnected async => connected;
}

RoadmapModel detailsWithTask({required bool completed}) => RoadmapModel(
  id: 1,
  title: 'Cloud Architect',
  milestones: [
    RoadmapMilestoneModel(
      id: 1,
      title: 'Containers',
      order: 1,
      tasks: [
        RoadmapTaskModel(
          id: 7,
          title: 'Docker lab',
          isCompleted: completed,
          completedAt: completed ? '2026-10-15T08:04:37.117Z' : null,
        ),
      ],
    ),
  ],
);

Future<RoadmapLocalDataSource> freshLocal() async {
  final prefs = await SharedPreferences.getInstance();
  return RoadmapLocalDataSourceImpl(
    sharedPreferencesHelper: SharedPreferencesHelper(preferences: prefs),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeSyncRemote remote;
  late FakeSyncNetwork network;
  late RoadmapLocalDataSource local;
  late RoadmapRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    remote = FakeSyncRemote();
    network = FakeSyncNetwork();
    local = await freshLocal();
    repository = RoadmapRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      networkInfo: network,
    );
  });

  group('Offline-first reads', () {
    test('details served from cache while offline', () async {
      await local.cacheRoadmapDetails(detailsWithTask(completed: false));

      network.connected = false;
      final result = await repository.getRoadmapDetails(1);

      expect(result.isRight(), isTrue);
    });

    test('offline without cache returns OfflineFailure', () async {
      network.connected = false;

      final result = await repository.getRoadmapDetails(1);

      expect(result.isLeft(), isTrue);
      expect((result as Left).value, isA<OfflineFailure>());
    });

    test('server error falls back to cached details', () async {
      await local.cacheRoadmapDetails(detailsWithTask(completed: false));
      remote.detailsError = ServerException(
        errorModel: const ErrorModel(statusCode: 500, errorMessage: 'Down'),
      );
      remote.detailsResponse = detailsWithTask(completed: true);

      final result = await repository.getRoadmapDetails(1);

      expect(result.isRight(), isTrue);
      expect(remote.detailsCalls, 1);
    });

    test('candidate XP served from cache while offline', () async {
      await local.cacheCandidateXp(
        const CandidateXpModel(totalXp: 275, level: 3),
      );

      network.connected = false;
      final result = await repository.getCandidateXp();

      expect(result.isRight(), isTrue);
      expect((result as Right).value.totalXp, 275);
    });
  });

  group('Offline mutations', () {
    test(
      'complete offline applies locally, queues, survives restart',
      () async {
        await local.cacheRoadmapDetails(detailsWithTask(completed: false));
        network.connected = false;

        final result = await repository.completeTaskOfflineFirst(
          roadmapId: 1,
          params: const CompleteRoadmapTaskParams(taskId: 7),
        );

        expect(result.isRight(), isTrue);
        expect((result as Right).value.isCompleted, isTrue);
        expect(remote.completeCalls, 0);

        // Durable across restarts: a fresh data source sees the same queue
        // and the locally applied completion.
        final restarted = await freshLocal();
        final ops = await restarted.getPendingOps();
        expect(ops.map((op) => op.opKey), contains('complete_7'));
        final cached = await restarted.getCachedRoadmapDetails(1);
        expect(cached!.milestones.first.tasks.first.isCompleted, isTrue);
      },
    );

    test('duplicate offline completions collapse to one queued op', () async {
      await local.cacheRoadmapDetails(detailsWithTask(completed: false));
      network.connected = false;

      await repository.completeTaskOfflineFirst(
        roadmapId: 1,
        params: const CompleteRoadmapTaskParams(taskId: 7),
      );
      await repository.completeTaskOfflineFirst(
        roadmapId: 1,
        params: const CompleteRoadmapTaskParams(taskId: 7),
      );

      final ops = await repository.getPendingOps();
      expect(ops.where((op) => op.opKey == 'complete_7'), hasLength(1));
    });

    test('award XP offline queues without confirming XP', () async {
      network.connected = false;

      final result = await repository.awardXp(
        const AwardXpParams(xp: 50, reason: 'Treasure 1', roadmapId: 1),
        opKey: 'treasure_1_1',
      );

      expect(result.isLeft(), isTrue);
      expect(remote.awardCalls, 0);
      final ops = await repository.getPendingOps();
      expect(ops.map((op) => op.opKey), contains('treasure_1_1'));
      // Nothing confirmed locally.
      expect(await repository.getSyncedTreasures(1), isEmpty);
    });
  });

  group('Background sync', () {
    test('replays queued completion then reconciles details', () async {
      await local.cacheRoadmapDetails(detailsWithTask(completed: false));
      network.connected = false;
      await repository.completeTaskOfflineFirst(
        roadmapId: 1,
        params: const CompleteRoadmapTaskParams(taskId: 7),
      );

      network.connected = true;
      remote.completeResponse = const RoadmapTaskModel(
        id: 7,
        title: 'Docker lab',
        isCompleted: true,
        completedAt: '2026-10-15T08:04:37.117Z',
      );
      remote.detailsResponse = detailsWithTask(completed: true);

      final report = await repository.syncPendingOps();

      expect(report.succeeded, 1);
      expect(report.remaining, 0);
      expect(remote.completeCalls, 1);
      final cached = await local.getCachedRoadmapDetails(1);
      expect(
        cached!.milestones.first.tasks.first.completedAt,
        '2026-10-15T08:04:37.117Z',
      );
    });

    test('already-completed server state clears the op idempotently', () async {
      await local.cacheRoadmapDetails(detailsWithTask(completed: true));
      network.connected = false;
      await repository.completeTaskOfflineFirst(
        roadmapId: 1,
        params: const CompleteRoadmapTaskParams(taskId: 7),
      );

      network.connected = true;
      remote.completeError = ServerException(
        errorModel: const ErrorModel(
          statusCode: 422,
          errorMessage: 'Task already completed.',
        ),
      );
      remote.detailsResponse = detailsWithTask(completed: true);

      final report = await repository.syncPendingOps();

      expect(report.succeeded, 1);
      expect(await repository.getPendingOps(), isEmpty);
    });

    test('transient failures stay queued with backoff metadata', () async {
      network.connected = false;
      await repository.completeTaskOfflineFirst(
        roadmapId: null,
        params: const CompleteRoadmapTaskParams(taskId: 7),
      );

      network.connected = true;
      remote.completeError = ServerException(
        errorModel: const ErrorModel(statusCode: 500, errorMessage: 'Down'),
      );

      final report = await repository.syncPendingOps();

      expect(report.succeeded, 0);
      final ops = await repository.getPendingOps();
      expect(ops, hasLength(1));
      expect(ops.first.attempts, 1);
      expect(ops.first.nextRetryAtMs, isNotNull);
    });

    test('auth expiry stops the pass and keeps ops queued', () async {
      network.connected = false;
      await repository.completeTaskOfflineFirst(
        roadmapId: null,
        params: const CompleteRoadmapTaskParams(taskId: 7),
      );

      network.connected = true;
      remote.completeError = ServerException(
        errorModel: const ErrorModel(
          statusCode: 401,
          errorMessage: 'Unauthenticated or token expired.',
        ),
      );

      final report = await repository.syncPendingOps();

      expect(report.stoppedForAuth, isTrue);
      expect(await repository.getPendingOps(), hasLength(1));
    });

    test('queued treasure award syncs +50 XP exactly once', () async {
      network.connected = false;
      await repository.awardXp(
        const AwardXpParams(xp: 50, reason: 'Treasure 1', roadmapId: 1),
        opKey: 'treasure_1_1',
      );

      network.connected = true;
      remote.awardResponse = const AwardXpResponseModel(
        xpAdded: 50,
        earnedXp: 300,
      );
      remote.candidateXpResponse = const CandidateXpModel(
        totalXp: 300,
        level: 3,
      );

      final first = await repository.syncPendingOps();
      final second = await repository.syncPendingOps();

      expect(first.succeeded, 1);
      expect(remote.awardCalls, 1);
      expect(second.succeeded, 0);
      expect(await repository.getSyncedTreasures(1), contains(1));
      final xp = await local.getCachedCandidateXp();
      expect(xp!.totalXp, 300);
    });
  });
}
