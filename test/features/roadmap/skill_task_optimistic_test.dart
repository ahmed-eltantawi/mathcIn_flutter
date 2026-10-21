import 'dart:async';

import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/core/errors/error_model.dart';
import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/networking/network_info.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:MatchIn/features/roadmap/data/data_sources/roadmap_local_data_source.dart';
import 'package:MatchIn/features/roadmap/data/data_sources/roadmap_local_data_source_impl.dart';
import 'package:MatchIn/features/roadmap/data/data_sources/roadmap_remote_data_source.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_milestone_model.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_model.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_node.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_pagination_model.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_task_model.dart';
import 'package:MatchIn/features/roadmap/data/models/skill_task.dart';
import 'package:MatchIn/features/roadmap/data/repositories/roadmap_repository_impl.dart';
import 'package:MatchIn/features/roadmap/domain/entities/complete_roadmap_task_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmaps_params.dart';
import 'package:MatchIn/features/roadmap/domain/repositories/roadmap_repository.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/complete_roadmap_task_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/generate_roadmap_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/get_cached_roadmap_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/get_roadmap_details_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/get_roadmaps_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/refresh_roadmap_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/sync_roadmap_ops_use_case.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/roadmap_cubit/roadmap_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/skill_task_cubit/skill_task_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/widgets/skill_details_sheet.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeOptimisticRemote extends Fake implements RoadmapRemoteDataSource {
  RoadmapModel? detailsResponse;
  final Completer<Either<Failure, RoadmapTaskModel>> completeGate = Completer();
  int completeCalls = 0;
  CompleteRoadmapTaskParams? lastCompleteParams;

  @override
  Future<({List<RoadmapModel> roadmaps, RoadmapPaginationModel pagination})>
  getRoadmaps({RoadmapsParams? params}) async {
    throw UnimplementedError();
  }

  @override
  Future<RoadmapModel> getRoadmapDetails(int roadmapId) async =>
      detailsResponse!;

  @override
  Future<RoadmapTaskModel> completeRoadmapTask(
    CompleteRoadmapTaskParams params,
  ) async {
    completeCalls++;
    lastCompleteParams = params;
    final result = await completeGate.future;
    return result.fold(
      (failure) => throw ServerException(
        errorModel: ErrorModel(statusCode: 500, errorMessage: failure.message),
      ),
      (task) => task,
    );
  }
}

class FakeOptimisticNetwork extends Fake implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;
}

RoadmapModel incompleteDetails() => const RoadmapModel(
  id: 1,
  title: 'Cloud Architect',
  milestones: [
    RoadmapMilestoneModel(
      id: 1,
      title: 'Containers',
      order: 1,
      tasks: [RoadmapTaskModel(id: 7, title: 'Docker lab')],
    ),
  ],
);

Future<
  ({
    RoadmapRepositoryImpl repository,
    RoadmapLocalDataSource local,
    FakeOptimisticRemote remote,
    SharedPreferencesService prefs,
  })
>
setupStack() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final helper = SharedPreferencesHelper(preferences: prefs);
  final local = RoadmapLocalDataSourceImpl(sharedPreferencesHelper: helper);
  final remote = FakeOptimisticRemote();
  final repository = RoadmapRepositoryImpl(
    remoteDataSource: remote,
    localDataSource: local,
    networkInfo: FakeOptimisticNetwork(),
  );
  return (
    repository: repository,
    local: local,
    remote: remote,
    prefs: SharedPreferencesService(helper),
  );
}

SkillTaskCubit buildSkillCubit(RoadmapRepository repository) => SkillTaskCubit(
  completeRoadmapTaskUseCase: CompleteRoadmapTaskUseCase(
    repository: repository,
  ),
  repository: repository,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Optimistic task completion', () {
    test('paints locally first, then confirms with the backend id', () async {
      final stack = await setupStack();
      await stack.local.cacheRoadmapDetails(incompleteDetails());
      final cubit = buildSkillCubit(stack.repository);
      addTearDown(cubit.close);

      final emitted = <SkillTaskState>[];
      final sub = cubit.stream.listen(emitted.add);
      final call = cubit.completeTask(taskId: 7, roadmapId: 1);
      // Let the optimistic apply land while the PATCH is still gated.
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      // UI state updated without waiting for the network round-trip.
      expect(
        emitted.whereType<SkillTaskOptimisticUpdate>().map((s) => s.taskId),
        contains(7),
      );
      final cached = await stack.local.getCachedRoadmapDetails(1);
      expect(cached!.milestones.first.tasks.first.isCompleted, isTrue);

      stack.remote.completeGate.complete(
        const Right(
          RoadmapTaskModel(
            id: 7,
            title: 'Docker lab',
            isCompleted: true,
            completedAt: '2026-10-15T08:04:37.117Z',
          ),
        ),
      );
      await call;
      await sub.cancel();

      expect(cubit.state, isA<SkillTaskCompleteSuccess>());
      expect(stack.remote.completeCalls, 1);
      expect(stack.remote.lastCompleteParams?.taskId, 7);
    });

    test('confirmed failure rolls the optimistic mark back', () async {
      final stack = await setupStack();
      await stack.local.cacheRoadmapDetails(incompleteDetails());
      final cubit = buildSkillCubit(stack.repository);
      addTearDown(cubit.close);

      final call = cubit.completeTask(taskId: 7, roadmapId: 1);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state, isA<SkillTaskOptimisticUpdate>());

      stack.remote.completeGate.complete(
        const Left<Failure, RoadmapTaskModel>(
          ServerFailure(message: 'Task already completed.'),
        ),
      );
      await call;

      // Failure surfaces and the local projection is reverted, so the
      // UI never shows a completion the backend rejected.
      expect(cubit.state, isA<SkillTaskCompleteFailure>());
      final cached = await stack.local.getCachedRoadmapDetails(1);
      expect(cached!.milestones.first.tasks.first.isCompleted, isFalse);
    });

    test('skips the optimistic emit without a cached roadmap', () async {
      final stack = await setupStack();
      final cubit = buildSkillCubit(stack.repository);
      addTearDown(cubit.close);

      final emitted = <SkillTaskState>[];
      final sub = cubit.stream.listen(emitted.add);
      final call = cubit.completeTask(taskId: 7, roadmapId: 1);
      stack.remote.completeGate.complete(
        const Right(RoadmapTaskModel(id: 7, title: 'Docker lab')),
      );
      await call;
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(emitted.whereType<SkillTaskOptimisticUpdate>(), isEmpty);
      expect(cubit.state, isA<SkillTaskCompleteSuccess>());
    });
  });

  group('Completion sheet instant feedback', () {
    Future<void> pumpSheet(
      WidgetTester tester, {
      required RoadmapCubit roadmapCubit,
      required SkillTaskCubit skillTaskCubit,
    }) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 845),
          builder: (_, _) => MaterialApp(
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            home: Scaffold(
              body: MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: roadmapCubit),
                  BlocProvider.value(value: skillTaskCubit),
                ],
                child: const SkillDetailsSheet(node: _sheetNode),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
    }

    Finder checkboxCircle() => find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).shape == BoxShape.circle,
    );

    testWidgets('check appears before the PATCH resolves', (tester) async {
      final stack = await setupStack();
      await stack.local.cacheRoadmapDetails(incompleteDetails());
      stack.remote.detailsResponse = incompleteDetails();
      final repository = stack.repository;
      final roadmapCubit = RoadmapCubit(
        sharedPreferencesService: stack.prefs,
        getRoadmapsUseCase: GetRoadmapsUseCase(repository: repository),
        getRoadmapDetailsUseCase: GetRoadmapDetailsUseCase(
          repository: repository,
        ),
        generateRoadmapUseCase: GenerateRoadmapUseCase(repository: repository),
        refreshRoadmapUseCase: RefreshRoadmapUseCase(repository: repository),
        getCachedRoadmapUseCase: GetCachedRoadmapUseCase(
          repository: repository,
        ),
        syncRoadmapOpsUseCase: SyncRoadmapOpsUseCase(repository: repository),
      );
      final skillTaskCubit = buildSkillCubit(repository);
      addTearDown(roadmapCubit.close);
      addTearDown(skillTaskCubit.close);
      await roadmapCubit.selectRoadmap(1);
      await pumpSheet(
        tester,
        roadmapCubit: roadmapCubit,
        skillTaskCubit: skillTaskCubit,
      );

      expect(find.byIcon(Icons.check_rounded), findsNothing);
      await tester.tap(checkboxCircle());
      for (var i = 0; i < 8; i++) {
        await tester.pump();
      }

      // Optimistic paint: completed indicator without any PATCH response.
      expect(stack.remote.completeCalls, 1);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      stack.remote.completeGate.complete(
        const Right(
          RoadmapTaskModel(
            id: 7,
            title: 'Docker lab',
            isCompleted: true,
            completedAt: '2026-10-15T08:04:37.117Z',
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(find.text('Task completed successfully'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('failed PATCH rolls the visible check back', (tester) async {
      final stack = await setupStack();
      await stack.local.cacheRoadmapDetails(incompleteDetails());
      stack.remote.detailsResponse = incompleteDetails();
      final repository = stack.repository;
      final roadmapCubit = RoadmapCubit(
        sharedPreferencesService: stack.prefs,
        getRoadmapsUseCase: GetRoadmapsUseCase(repository: repository),
        getRoadmapDetailsUseCase: GetRoadmapDetailsUseCase(
          repository: repository,
        ),
        generateRoadmapUseCase: GenerateRoadmapUseCase(repository: repository),
        refreshRoadmapUseCase: RefreshRoadmapUseCase(repository: repository),
        getCachedRoadmapUseCase: GetCachedRoadmapUseCase(
          repository: repository,
        ),
        syncRoadmapOpsUseCase: SyncRoadmapOpsUseCase(repository: repository),
      );
      final skillTaskCubit = buildSkillCubit(repository);
      addTearDown(roadmapCubit.close);
      addTearDown(skillTaskCubit.close);
      await roadmapCubit.selectRoadmap(1);
      await pumpSheet(
        tester,
        roadmapCubit: roadmapCubit,
        skillTaskCubit: skillTaskCubit,
      );

      await tester.tap(checkboxCircle());
      for (var i = 0; i < 8; i++) {
        await tester.pump();
      }
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      stack.remote.completeGate.complete(
        const Left<Failure, RoadmapTaskModel>(
          ServerFailure(message: 'Task completion failed.'),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.check_rounded), findsNothing);
      expect(find.text('Task completion failed.'), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });
}

const _sheetNode = RoadmapNode(
  id: '7',
  title: 'Docker lab',
  subtitle: 'Containers',
  status: RoadmapTaskStatus.active,
  tasks: [SkillTask(id: '7', title: 'Docker lab', duration: '6h')],
);
