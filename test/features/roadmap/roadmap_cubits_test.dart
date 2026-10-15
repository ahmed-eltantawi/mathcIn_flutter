import 'dart:async';

import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:MatchIn/features/roadmap/domain/entities/complete_roadmap_task_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/refresh_roadmap_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/generate_roadmap_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/paginated_roadmaps_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_milestone.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_pagination_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_task.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmaps_params.dart';
import 'package:MatchIn/features/roadmap/domain/repositories/roadmap_repository.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/complete_roadmap_task_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/get_roadmap_details_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/get_roadmaps_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/generate_roadmap_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/refresh_roadmap_use_case.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/roadmap_cubit/roadmap_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/skill_task_cubit/skill_task_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/treasure_cubit/treasure_cubit.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeRoadmapRepository extends Fake implements RoadmapRepository {
  Either<Failure, PaginatedRoadmapsEntity>? listResult;
  Either<Failure, RoadmapEntity>? detailsResult;
  Either<Failure, RoadmapEntity>? generateResult;
  Either<Failure, RoadmapTask>? completeResult;
  Either<Failure, RoadmapEntity>? refreshResult;
  int listCalls = 0;
  int detailsCalls = 0;
  int generateCalls = 0;
  int completeCalls = 0;
  int refreshCalls = 0;
  CompleteRoadmapTaskParams? lastCompleteParams;
  RefreshRoadmapParams? lastRefreshParams;

  @override
  Future<Either<Failure, PaginatedRoadmapsEntity>> getRoadmaps({
    RoadmapsParams? params,
  }) async {
    listCalls++;
    return listResult!;
  }

  @override
  Future<Either<Failure, RoadmapEntity>> getRoadmapDetails(
    int roadmapId,
  ) async {
    detailsCalls++;
    return detailsResult!;
  }

  @override
  Future<Either<Failure, RoadmapEntity>> generateRoadmap(
    GenerateRoadmapParams params,
  ) async {
    generateCalls++;
    return generateResult!;
  }

  @override
  Future<Either<Failure, RoadmapTask>> completeRoadmapTask(
    CompleteRoadmapTaskParams params,
  ) async {
    completeCalls++;
    lastCompleteParams = params;
    return completeResult!;
  }

  @override
  Future<Either<Failure, RoadmapEntity>> refreshRoadmap(
    RefreshRoadmapParams params,
  ) async {
    refreshCalls++;
    lastRefreshParams = params;
    return refreshResult!;
  }
}

/// Repository fake that holds completion requests behind a gate so
/// duplicate in-flight calls can be observed.
class GatedCompleteRepository extends Fake implements RoadmapRepository {
  int calls = 0;
  final Completer<Either<Failure, RoadmapTask>> gate = Completer();

  @override
  Future<Either<Failure, RoadmapTask>> completeRoadmapTask(
    CompleteRoadmapTaskParams params,
  ) async {
    calls++;
    return gate.future;
  }
}

/// Repository fake that holds refresh requests behind a gate so
/// duplicate in-flight calls can be observed.
class GatedRefreshRepository extends FakeRoadmapRepository {
  final Completer<Either<Failure, RoadmapEntity>> gate = Completer();

  @override
  Future<Either<Failure, RoadmapEntity>> refreshRoadmap(
    RefreshRoadmapParams params,
  ) async {
    refreshCalls++;
    lastRefreshParams = params;
    return gate.future;
  }
}

/// Repository fake that holds generate requests behind a gate.
class GatedGenerateRepository extends FakeRoadmapRepository {
  final Completer<Either<Failure, RoadmapEntity>> gate = Completer();

  @override
  Future<Either<Failure, RoadmapEntity>> generateRoadmap(
    GenerateRoadmapParams params,
  ) async {
    generateCalls++;
    return gate.future;
  }
}

const _page1 = PaginatedRoadmapsEntity(
  roadmaps: [
    RoadmapEntity(
      id: 1,
      title: 'Cloud Architect',
      targetRole: 'Cloud Architect',
    ),
    RoadmapEntity(id: 2, title: 'Backend Pro', targetRole: 'Backend'),
  ],
  pagination: RoadmapPaginationEntity(
    currentPage: 1,
    lastPage: 2,
    perPage: 15,
    total: 3,
  ),
);

const _details = RoadmapEntity(
  id: 1,
  title: 'Cloud Architect',
  milestones: [
    RoadmapMilestone(
      id: 1,
      title: 'Containers',
      order: 1,
      tasks: [RoadmapTask(id: 1, title: 'Docker lab', isCompleted: true)],
    ),
  ],
);

RoadmapCubit buildRoadmapCubit(
  SharedPreferencesService prefs,
  FakeRoadmapRepository repo,
) => RoadmapCubit(
  sharedPreferencesService: prefs,
  getRoadmapsUseCase: GetRoadmapsUseCase(repository: repo),
  getRoadmapDetailsUseCase: GetRoadmapDetailsUseCase(repository: repo),
  generateRoadmapUseCase: GenerateRoadmapUseCase(repository: repo),
  refreshRoadmapUseCase: RefreshRoadmapUseCase(repository: repo),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferencesService sharedPreferencesService;
  late TreasureCubit treasureCubit;
  late SkillTaskCubit skillTaskCubit;
  late FakeRoadmapRepository skillTaskRepo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final helper = SharedPreferencesHelper(preferences: prefs);
    sharedPreferencesService = SharedPreferencesService(helper);

    treasureCubit = TreasureCubit(
      sharedPreferencesService: sharedPreferencesService,
    );
    skillTaskRepo = FakeRoadmapRepository();
    skillTaskCubit = SkillTaskCubit(
      completeRoadmapTaskUseCase: CompleteRoadmapTaskUseCase(
        repository: skillTaskRepo,
      ),
    );
  });

  group('Roadmap Features Cubit Unit Tests', () {
    test('RoadmapCubit loads list then auto-selects first details', () async {
      final repo = FakeRoadmapRepository()
        ..listResult = const Right(_page1)
        ..detailsResult = const Right(_details);
      final cubit = buildRoadmapCubit(sharedPreferencesService, repo);

      await cubit.loadRoadmaps();

      expect(cubit.state, isA<RoadmapDetailsSuccess>());
      final state = cubit.state as RoadmapDetailsSuccess;
      expect(state.details.id, 1);
      expect(repo.listCalls, 1);
      expect(repo.detailsCalls, 1);
      await cubit.close();
    });

    test('RoadmapCubit shows empty state without details call', () async {
      final repo = FakeRoadmapRepository()
        ..listResult = const Right(
          PaginatedRoadmapsEntity(
            roadmaps: [],
            pagination: RoadmapPaginationEntity(
              currentPage: 1,
              lastPage: 1,
              perPage: 15,
              total: 0,
            ),
          ),
        );
      final cubit = buildRoadmapCubit(sharedPreferencesService, repo);

      await cubit.loadRoadmaps();

      expect(cubit.state, isA<RoadmapsSuccess>());
      expect((cubit.state as RoadmapsSuccess).roadmaps, isEmpty);
      expect(repo.detailsCalls, 0);
      await cubit.close();
    });

    test('RoadmapCubit emits failure on list error', () async {
      final repo = FakeRoadmapRepository()
        ..listResult = const Left(ServerFailure(message: 'Down'));
      final cubit = buildRoadmapCubit(sharedPreferencesService, repo);

      await cubit.loadRoadmaps();

      expect(cubit.state, isA<RoadmapFailure>());
      await cubit.close();
    });

    test('RoadmapCubit emits failure on offline list load', () async {
      final repo = FakeRoadmapRepository()
        ..listResult = const Left(OfflineFailure());
      final cubit = buildRoadmapCubit(sharedPreferencesService, repo);

      await cubit.loadRoadmaps();

      expect(cubit.state, isA<RoadmapFailure>());
      await cubit.close();
    });

    test('RoadmapCubit loadMore appends and restores details', () async {
      const page2 = PaginatedRoadmapsEntity(
        roadmaps: [RoadmapEntity(id: 3, title: 'Mobile Pro')],
        pagination: RoadmapPaginationEntity(
          currentPage: 2,
          lastPage: 2,
          perPage: 15,
          total: 3,
        ),
      );
      final repo = FakeRoadmapRepository()
        ..listResult = const Right(_page1)
        ..detailsResult = const Right(_details);
      final cubit = buildRoadmapCubit(sharedPreferencesService, repo);

      await cubit.loadRoadmaps();
      repo.listResult = const Right(page2);
      final ok = await cubit.loadMoreRoadmaps();

      expect(ok, isTrue);
      expect(cubit.cachedRoadmaps.length, 3);
      expect(cubit.state, isA<RoadmapDetailsSuccess>());
      await cubit.close();
    });

    test('RoadmapCubit loadMore returns false without more pages', () async {
      final repo = FakeRoadmapRepository()
        ..listResult = const Right(_page1)
        ..detailsResult = const Right(_details);
      final cubit = buildRoadmapCubit(sharedPreferencesService, repo);

      await cubit.loadRoadmaps();
      expect(cubit.hasMorePages, isTrue);

      repo.listResult = const Right(
        PaginatedRoadmapsEntity(
          roadmaps: [],
          pagination: RoadmapPaginationEntity(
            currentPage: 2,
            lastPage: 2,
            perPage: 15,
            total: 3,
          ),
        ),
      );
      await cubit.loadMoreRoadmaps();
      expect(cubit.hasMorePages, isFalse);

      final calls = repo.listCalls;
      expect(await cubit.loadMoreRoadmaps(), isFalse);
      expect(repo.listCalls, calls);
      await cubit.close();
    });

    test('RoadmapCubit retry reloads details when selected', () async {
      final repo = FakeRoadmapRepository()
        ..listResult = const Right(_page1)
        ..detailsResult = const Right(_details);
      final cubit = buildRoadmapCubit(sharedPreferencesService, repo);

      await cubit.loadRoadmaps();
      final calls = repo.detailsCalls;
      await cubit.retry();

      expect(repo.detailsCalls, calls + 1);
      expect(cubit.state, isA<RoadmapDetailsSuccess>());
      await cubit.close();
    });

    test('RoadmapCubit generate selects the new roadmap', () async {
      const generated = RoadmapEntity(id: 9, title: 'Fresh AI Roadmap');
      final repo = FakeRoadmapRepository()
        ..listResult = const Right(_page1)
        ..detailsResult = const Right(_details)
        ..generateResult = const Right(generated);
      final cubit = buildRoadmapCubit(sharedPreferencesService, repo);

      await cubit.loadRoadmaps();
      await cubit.generateRoadmap(
        const GenerateRoadmapParams(targetRole: 'Backend Engineer'),
      );

      expect(repo.generateCalls, 1);
      expect(cubit.selectedRoadmapId, 9);
      expect(cubit.state, isA<RoadmapDetailsSuccess>());
      expect((cubit.state as RoadmapDetailsSuccess).details.id, 9);
      await cubit.close();
    });

    test('RoadmapCubit generate failure preserves displayed roadmap', () async {
      final repo = FakeRoadmapRepository()
        ..listResult = const Right(_page1)
        ..detailsResult = const Right(_details)
        ..generateResult = const Left(
          ServerFailure(message: 'The given data was invalid.'),
        );
      final cubit = buildRoadmapCubit(sharedPreferencesService, repo);

      await cubit.loadRoadmaps();
      await cubit.generateRoadmap(
        const GenerateRoadmapParams(targetRole: 'Backend Engineer'),
      );

      expect(cubit.state, isA<RoadmapGenerateFailure>());
      final state = cubit.state as RoadmapGenerateFailure;
      expect(state.details?.id, 1);
      expect(cubit.selectedRoadmapId, 1);
      await cubit.close();
    });

    test('RoadmapCubit generate maps 422 field errors', () async {
      final repo = FakeRoadmapRepository()
        ..generateResult = const Left(
          ServerFailure(
            message: 'The given data was invalid.',
            fieldErrors: {
              'target_role': ['The target role field is required.'],
            },
          ),
        );
      final cubit = buildRoadmapCubit(sharedPreferencesService, repo);

      await cubit.generateRoadmap(
        const GenerateRoadmapParams(targetRole: 'Backend Engineer'),
      );

      expect(cubit.state, isA<RoadmapGenerateFailure>());
      final state = cubit.state as RoadmapGenerateFailure;
      expect(state.fieldErrors['target_role'], [
        'The target role field is required.',
      ]);
      await cubit.close();
    });

    test('RoadmapCubit generate surfaces offline failure', () async {
      final repo = FakeRoadmapRepository()
        ..generateResult = const Left(OfflineFailure());
      final cubit = buildRoadmapCubit(sharedPreferencesService, repo);

      await cubit.generateRoadmap(
        const GenerateRoadmapParams(targetRole: 'Backend Engineer'),
      );

      expect(cubit.state, isA<RoadmapGenerateFailure>());
      await cubit.close();
    });

    test('RoadmapCubit prevents duplicate generation requests', () async {
      const generated = RoadmapEntity(id: 9, title: 'Fresh AI Roadmap');
      final repo = FakeRoadmapRepository()
        ..generateResult = const Right(generated);
      final cubit = buildRoadmapCubit(sharedPreferencesService, repo);

      await Future.wait([
        cubit.generateRoadmap(
          const GenerateRoadmapParams(targetRole: 'Backend Engineer'),
        ),
        cubit.generateRoadmap(
          const GenerateRoadmapParams(targetRole: 'Backend Engineer'),
        ),
      ]);

      expect(repo.generateCalls, 1);
      await cubit.close();
    });

    test('TreasureCubit loads and claims treasure milestone', () async {
      treasureCubit.loadCollectedTreasures();
      expect(treasureCubit.state, isA<TreasureLoaded>());

      await treasureCubit.claimTreasureReward(1);
      final state = treasureCubit.state as TreasureLoaded;
      expect(state.collectedTreasures.contains(1), isTrue);
    });

    test('SkillTaskCubit completes a task through the backend', () async {
      skillTaskRepo.completeResult = const Right(
        RoadmapTask(
          id: 7,
          title: 'Docker lab',
          isCompleted: true,
          completedAt: '2026-10-14T22:33:10.515Z',
        ),
      );

      await skillTaskCubit.completeTask(taskId: 7);

      expect(skillTaskRepo.completeCalls, 1);
      expect(skillTaskRepo.lastCompleteParams?.taskId, 7);
      final state = skillTaskCubit.state;
      expect(state, isA<SkillTaskCompleteSuccess>());
      expect((state as SkillTaskCompleteSuccess).taskId, 7);
      expect(state.completedAt, '2026-10-14T22:33:10.515Z');
      // Backend flow writes nothing to SharedPreferences.
      expect(sharedPreferencesService.getCompletedTasks(), isEmpty);
      await skillTaskCubit.close();
    });

    test('SkillTaskCubit surfaces failure without touching prefs', () async {
      skillTaskRepo.completeResult = const Left(
        ServerFailure(
          message: 'Task already completed.',
          fieldErrors: {
            'task': ['Task already completed.'],
          },
        ),
      );

      await skillTaskCubit.completeTask(taskId: 7);

      final state = skillTaskCubit.state;
      expect(state, isA<SkillTaskCompleteFailure>());
      final failure = state as SkillTaskCompleteFailure;
      expect(failure.taskId, 7);
      expect(failure.message, 'Task already completed.');
      expect(failure.fieldErrors['task'], ['Task already completed.']);
      expect(sharedPreferencesService.getCompletedTasks(), isEmpty);
      await skillTaskCubit.close();
    });

    test('SkillTaskCubit surfaces offline failure', () async {
      skillTaskRepo.completeResult = const Left(OfflineFailure());

      await skillTaskCubit.completeTask(taskId: 7);

      final state = skillTaskCubit.state;
      expect(state, isA<SkillTaskCompleteFailure>());
      expect((state as SkillTaskCompleteFailure).message, 'You are offline');
      await skillTaskCubit.close();
    });

    test('SkillTaskCubit collapses duplicate in-flight requests', () async {
      final gatedRepo = GatedCompleteRepository();
      final cubit = SkillTaskCubit(
        completeRoadmapTaskUseCase: CompleteRoadmapTaskUseCase(
          repository: gatedRepo,
        ),
      );

      unawaited(cubit.completeTask(taskId: 7));
      unawaited(cubit.completeTask(taskId: 7));
      await Future<void>.delayed(Duration.zero);
      expect(gatedRepo.calls, 1);
      expect(cubit.state.isCompleting(7), isTrue);

      gatedRepo.gate.complete(
        const Right(RoadmapTask(id: 7, title: 'Docker lab')),
      );
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state, isA<SkillTaskCompleteSuccess>());
      await cubit.close();
    });

    test(
      'RoadmapCubit refreshSelectedRoadmapDetails emits fresh details',
      () async {
        final repo = FakeRoadmapRepository()
          ..listResult = const Right(_page1)
          ..detailsResult = const Right(_details);
        final cubit = buildRoadmapCubit(sharedPreferencesService, repo);

        await cubit.loadRoadmaps();
        expect(cubit.state, isA<RoadmapDetailsSuccess>());

        const refreshed = RoadmapEntity(id: 1, title: 'Cloud Refreshed');
        repo.detailsResult = const Right(refreshed);
        final ok = await cubit.refreshSelectedRoadmapDetails();

        expect(ok, isTrue);
        final state = cubit.state as RoadmapDetailsSuccess;
        expect(state.details.title, 'Cloud Refreshed');
        await cubit.close();
      },
    );

    test('RoadmapCubit refresh failure preserves displayed roadmap', () async {
      final repo = FakeRoadmapRepository()
        ..listResult = const Right(_page1)
        ..detailsResult = const Right(_details);
      final cubit = buildRoadmapCubit(sharedPreferencesService, repo);

      await cubit.loadRoadmaps();
      repo.detailsResult = const Left(
        ServerFailure(message: 'Server exploded'),
      );
      final ok = await cubit.refreshSelectedRoadmapDetails();

      expect(ok, isFalse);
      final state = cubit.state as RoadmapDetailsSuccess;
      expect(state.details.title, 'Cloud Architect');
      await cubit.close();
    });

    test('RoadmapCubit refresh without selection returns false', () async {
      final repo = FakeRoadmapRepository();
      final cubit = buildRoadmapCubit(sharedPreferencesService, repo);

      expect(await cubit.refreshSelectedRoadmapDetails(), isFalse);
      expect(repo.detailsCalls, 0);
      await cubit.close();
    });

    test('RoadmapCubit aiRefresh replaces displayed roadmap', () async {
      final repo = FakeRoadmapRepository()
        ..listResult = const Right(_page1)
        ..detailsResult = const Right(_details)
        ..refreshResult = const Right(
          RoadmapEntity(id: 1, title: 'AI Refreshed', completionPercentage: 35),
        );
      final cubit = buildRoadmapCubit(sharedPreferencesService, repo);

      await cubit.loadRoadmaps();
      await cubit.aiRefreshSelectedRoadmap(
        reason: 'Focus more on backend skills',
      );

      expect(repo.refreshCalls, 1);
      expect(repo.lastRefreshParams?.roadmapId, 1);
      expect(repo.lastRefreshParams?.reason, 'Focus more on backend skills');
      // No follow-up GET after a valid POST response.
      expect(repo.detailsCalls, 1);
      final state = cubit.state as RoadmapDetailsSuccess;
      expect(state.details.title, 'AI Refreshed');
      expect(state.details.completionPercentage, 35);
      await cubit.close();
    });

    test(
      'RoadmapCubit aiRefresh keeps content visible while loading',
      () async {
        final gatedRepo = GatedRefreshRepository()
          ..listResult = const Right(_page1)
          ..detailsResult = const Right(_details);
        final cubit = buildRoadmapCubit(sharedPreferencesService, gatedRepo);

        await cubit.loadRoadmaps();
        unawaited(cubit.aiRefreshSelectedRoadmap());
        await Future<void>.delayed(Duration.zero);

        final state = cubit.state;
        expect(state, isA<RoadmapAiRefreshing>());
        expect(
          (state as RoadmapAiRefreshing).details?.title,
          'Cloud Architect',
        );
        gatedRepo.gate.complete(const Right(_details));
        await cubit.close();
      },
    );

    test('RoadmapCubit aiRefresh failure preserves roadmap', () async {
      final repo = FakeRoadmapRepository()
        ..listResult = const Right(_page1)
        ..detailsResult = const Right(_details)
        ..refreshResult = const Left(
          ServerFailure(
            message: 'The given data was invalid.',
            fieldErrors: {
              'reason': ['The reason is too long.'],
            },
          ),
        );
      final cubit = buildRoadmapCubit(sharedPreferencesService, repo);

      await cubit.loadRoadmaps();
      await cubit.aiRefreshSelectedRoadmap(reason: 'x');

      final state = cubit.state;
      expect(state, isA<RoadmapAiRefreshFailure>());
      final failure = state as RoadmapAiRefreshFailure;
      expect(failure.message, 'The given data was invalid.');
      expect(failure.fieldErrors['reason'], ['The reason is too long.']);
      expect(failure.details?.title, 'Cloud Architect');
      expect(cubit.selectedRoadmapId, 1);
      await cubit.close();
    });

    test('RoadmapCubit aiRefresh duplicate requests collapse', () async {
      final gatedRepo = GatedRefreshRepository()
        ..listResult = const Right(_page1)
        ..detailsResult = const Right(_details);
      final cubit = buildRoadmapCubit(sharedPreferencesService, gatedRepo);

      await cubit.loadRoadmaps();
      unawaited(cubit.aiRefreshSelectedRoadmap());
      unawaited(cubit.aiRefreshSelectedRoadmap());
      await Future<void>.delayed(Duration.zero);

      expect(gatedRepo.refreshCalls, 1);
      gatedRepo.gate.complete(const Right(_details));
      await cubit.close();
    });

    test('RoadmapCubit generate blocked during aiRefresh', () async {
      final gatedRepo = GatedRefreshRepository()
        ..listResult = const Right(_page1)
        ..detailsResult = const Right(_details);
      final cubit = buildRoadmapCubit(sharedPreferencesService, gatedRepo);

      await cubit.loadRoadmaps();
      unawaited(cubit.aiRefreshSelectedRoadmap());
      await Future<void>.delayed(Duration.zero);
      await cubit.generateRoadmap(
        const GenerateRoadmapParams(targetRole: 'Backend'),
      );

      expect(gatedRepo.generateCalls, 0);
      gatedRepo.gate.complete(const Right(_details));
      await cubit.close();
    });

    test('RoadmapCubit aiRefresh blocked during generate', () async {
      final gatedRepo = GatedGenerateRepository()
        ..listResult = const Right(_page1)
        ..detailsResult = const Right(_details);
      final cubit = buildRoadmapCubit(sharedPreferencesService, gatedRepo);

      await cubit.loadRoadmaps();
      unawaited(
        cubit.generateRoadmap(const GenerateRoadmapParams(targetRole: 'X')),
      );
      await Future<void>.delayed(Duration.zero);
      await cubit.aiRefreshSelectedRoadmap();

      expect(gatedRepo.refreshCalls, 0);
      gatedRepo.gate.complete(const Right(_details));
      await cubit.close();
    });

    test('RoadmapCubit selection blocked during aiRefresh', () async {
      final gatedRepo = GatedRefreshRepository()
        ..listResult = const Right(_page1)
        ..detailsResult = const Right(_details);
      final cubit = buildRoadmapCubit(sharedPreferencesService, gatedRepo);

      await cubit.loadRoadmaps();
      final detailsCallsBefore = gatedRepo.detailsCalls;
      unawaited(cubit.aiRefreshSelectedRoadmap());
      await Future<void>.delayed(Duration.zero);
      await cubit.selectRoadmap(2);
      await cubit.loadRoadmapDetails(2);

      expect(cubit.selectedRoadmapId, 1);
      expect(gatedRepo.detailsCalls, detailsCallsBefore);
      gatedRepo.gate.complete(const Right(_details));
      await cubit.close();
    });

    test('RoadmapCubit aiRefresh reconciles a changed roadmap id', () async {
      final repo = FakeRoadmapRepository()
        ..listResult = const Right(_page1)
        ..detailsResult = const Right(_details)
        ..refreshResult = const Right(
          RoadmapEntity(id: 9, title: 'Regenerated'),
        );
      final cubit = buildRoadmapCubit(sharedPreferencesService, repo);

      await cubit.loadRoadmaps();
      await cubit.aiRefreshSelectedRoadmap();

      expect(cubit.selectedRoadmapId, 9);
      final state = cubit.state as RoadmapDetailsSuccess;
      expect(state.details.id, 9);
      final ids = cubit.cachedRoadmaps.map((roadmap) => roadmap.id);
      expect(ids, contains(9));
      expect(ids.where((id) => id == 1), isEmpty);
      expect(ids.where((id) => id == 9), hasLength(1));
      await cubit.close();
    });

    test(
      'RoadmapCubit adds rewarded ad XP (+50 XP) and persists state',
      () async {
        final repo = FakeRoadmapRepository()
          ..listResult = const Right(_page1)
          ..detailsResult = const Right(_details);
        final cubit = buildRoadmapCubit(sharedPreferencesService, repo);

        await cubit.loadRoadmaps();
        expect(cubit.state, isA<RoadmapDetailsSuccess>());

        await cubit.addRewardedAdXp(50);
        final state = cubit.state as RoadmapDetailsSuccess;
        expect(state.rewardedAdXp, equals(50));
        expect(sharedPreferencesService.getRewardedAdXp(), equals(50));
        await cubit.close();
      },
    );
  });
}
