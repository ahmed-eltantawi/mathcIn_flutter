import 'dart:async';

import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_node.dart';
import 'package:MatchIn/features/roadmap/data/models/skill_task.dart';
import 'package:MatchIn/features/roadmap/domain/entities/complete_roadmap_task_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/paginated_roadmaps_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_milestone.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_pagination_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_task.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmaps_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/generate_roadmap_params.dart';
import 'package:MatchIn/features/roadmap/domain/repositories/roadmap_repository.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/complete_roadmap_task_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/get_roadmap_details_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/get_roadmaps_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/generate_roadmap_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/refresh_roadmap_use_case.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/roadmap_cubit/roadmap_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/skill_task_cubit/skill_task_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/widgets/roadmap_list_widget.dart';
import 'package:MatchIn/features/roadmap/presentation/widgets/roadmap_node.dart';
import 'package:MatchIn/features/roadmap/presentation/widgets/skill_details_sheet.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeFlowRepository extends Fake implements RoadmapRepository {
  Either<Failure, PaginatedRoadmapsEntity>? listResult;
  Either<Failure, RoadmapEntity>? detailsResult;
  Either<Failure, RoadmapTask>? completeResult;
  int detailsCalls = 0;
  int completeCalls = 0;
  int? lastCompletedTaskId;

  @override
  Future<Either<Failure, PaginatedRoadmapsEntity>> getRoadmaps({
    RoadmapsParams? params,
  }) async {
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
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, RoadmapTask>> completeRoadmapTask(
    CompleteRoadmapTaskParams params,
  ) async {
    completeCalls++;
    lastCompletedTaskId = params.taskId;
    return completeResult!;
  }
}

class GatedFlowRepository extends FakeFlowRepository {
  final Completer<Either<Failure, RoadmapTask>> gate = Completer();

  @override
  Future<Either<Failure, RoadmapTask>> completeRoadmapTask(
    CompleteRoadmapTaskParams params,
  ) async {
    completeCalls++;
    lastCompletedTaskId = params.taskId;
    return gate.future;
  }
}

const _page = PaginatedRoadmapsEntity(
  roadmaps: [RoadmapEntity(id: 1, title: 'Cloud Architect')],
  pagination: RoadmapPaginationEntity(
    currentPage: 1,
    lastPage: 1,
    perPage: 15,
    total: 1,
  ),
);

const _incompleteDetails = RoadmapEntity(
  id: 1,
  title: 'Cloud Architect',
  milestones: [
    RoadmapMilestone(
      id: 1,
      title: 'Containers',
      order: 1,
      tasks: [RoadmapTask(id: 7, title: 'Docker lab')],
    ),
  ],
);

const _completedDetails = RoadmapEntity(
  id: 1,
  title: 'Cloud Architect',
  milestones: [
    RoadmapMilestone(
      id: 1,
      title: 'Containers',
      order: 1,
      tasks: [
        RoadmapTask(
          id: 7,
          title: 'Docker lab',
          isCompleted: true,
          completedAt: '2026-10-14T22:33:10.515Z',
        ),
      ],
    ),
  ],
);

const _sheetNode = RoadmapNode(
  id: '1',
  title: 'Containers',
  status: RoadmapTaskStatus.active,
  tasks: [SkillTask(id: '7', title: 'Docker lab', duration: '6h')],
);

/// Checkbox circle of a task card. Tapping its center hits the
/// header checkbox: a no-op when completion is disabled.
Finder _checkboxCircle() => find.byWidgetPredicate(
  (widget) =>
      widget is Container &&
      widget.decoration is BoxDecoration &&
      (widget.decoration as BoxDecoration).shape == BoxShape.circle,
);

Future<_FlowHarness> _pumpSheet(
  WidgetTester tester, {
  required FakeFlowRepository repo,
}) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final prefsService = SharedPreferencesService(
    SharedPreferencesHelper(preferences: prefs),
  );
  final roadmapCubit = RoadmapCubit(
    sharedPreferencesService: prefsService,
    getRoadmapsUseCase: GetRoadmapsUseCase(repository: repo),
    getRoadmapDetailsUseCase: GetRoadmapDetailsUseCase(repository: repo),
    generateRoadmapUseCase: GenerateRoadmapUseCase(repository: repo),
    refreshRoadmapUseCase: RefreshRoadmapUseCase(repository: repo),
  );
  final skillTaskCubit = SkillTaskCubit(
    completeRoadmapTaskUseCase: CompleteRoadmapTaskUseCase(repository: repo),
  );
  addTearDown(roadmapCubit.close);
  addTearDown(skillTaskCubit.close);

  repo.listResult = const Right(_page);
  repo.detailsResult = const Right(_incompleteDetails);
  await roadmapCubit.loadRoadmaps();

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
  await tester.pumpAndSettle();
  return _FlowHarness(roadmapCubit: roadmapCubit, prefsService: prefsService);
}

class _FlowHarness {
  _FlowHarness({required this.roadmapCubit, required this.prefsService});

  final RoadmapCubit roadmapCubit;
  final SharedPreferencesService prefsService;
}

void main() {
  group('SkillDetailsSheet task completion flow', () {
    testWidgets('tap PATCHes the backend id then refreshes details', (
      tester,
    ) async {
      final repo = FakeFlowRepository()
        ..completeResult = const Right(
          RoadmapTask(id: 7, title: 'Docker lab', isCompleted: true),
        );
      final harness = await _pumpSheet(tester, repo: repo);
      repo.detailsResult = const Right(_completedDetails);

      await tester.tap(_checkboxCircle());
      // Let the PATCH resolve and the success feedback appear without
      // advancing the clock past the snackbar lifetime.
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(find.text('Task completed successfully'), findsOneWidget);
      await tester.pumpAndSettle();

      expect(repo.completeCalls, 1);
      expect(repo.lastCompletedTaskId, 7);
      expect(find.text('Task completed successfully'), findsOneWidget);
      // Initial details load + silent refresh after PATCH.
      expect(repo.detailsCalls, 2);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      // XP and local completion stores stay untouched.
      expect(harness.prefsService.getCompletedTasks(), isEmpty);
      expect(harness.prefsService.getRewardedAdXp(), 0);
      expect(harness.prefsService.getCollectedTreasures(), isEmpty);
    });

    testWidgets('duplicate taps issue a single PATCH', (tester) async {
      final repo = GatedFlowRepository()
        ..listResult = const Right(_page)
        ..detailsResult = const Right(_incompleteDetails);
      await _pumpSheet(tester, repo: repo);

      await tester.tap(_checkboxCircle());
      await tester.pump();
      expect(repo.completeCalls, 1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Second tap while busy issues nothing.
      await tester.tap(_checkboxCircle());
      await tester.pump();
      expect(repo.completeCalls, 1);

      repo.gate.complete(const Right(RoadmapTask(id: 7, title: 'Docker lab')));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(find.text('Task completed successfully'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('failure keeps the sheet open with error feedback', (
      tester,
    ) async {
      final repo = FakeFlowRepository()
        ..completeResult = const Left(
          ServerFailure(message: 'Task already completed.'),
        );
      await _pumpSheet(tester, repo: repo);

      await tester.tap(_checkboxCircle());
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(find.text('Task already completed.'), findsOneWidget);
      await tester.pumpAndSettle();

      expect(repo.completeCalls, 1);
      // No silent refresh after a failed PATCH.
      expect(repo.detailsCalls, 1);
      // Sheet stays mounted on the same task, still incomplete.
      expect(find.text('Docker lab'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsNothing);
    });

    testWidgets('locked node stays inaccessible', (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final prefsService = SharedPreferencesService(
        SharedPreferencesHelper(preferences: prefs),
      );
      final repo = FakeFlowRepository();
      final roadmapCubit = RoadmapCubit(
        sharedPreferencesService: prefsService,
        getRoadmapsUseCase: GetRoadmapsUseCase(repository: repo),
        getRoadmapDetailsUseCase: GetRoadmapDetailsUseCase(repository: repo),
        generateRoadmapUseCase: GenerateRoadmapUseCase(repository: repo),
        refreshRoadmapUseCase: RefreshRoadmapUseCase(repository: repo),
      );
      final skillTaskCubit = SkillTaskCubit(
        completeRoadmapTaskUseCase: CompleteRoadmapTaskUseCase(
          repository: repo,
        ),
      );
      addTearDown(roadmapCubit.close);
      addTearDown(skillTaskCubit.close);

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
                child: const RoadmapListWidget(
                  nodes: [
                    RoadmapNode(
                      title: 'Locked skill',
                      status: RoadmapTaskStatus.locked,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(RoadmapTaskNode),
          matching: find.byType(GestureDetector),
        ),
      );
      await tester.pump();
      expect(
        find.text('Complete the previous task first to unlock!'),
        findsOneWidget,
      );
      await tester.pumpAndSettle();
      expect(find.byType(SkillDetailsSheet), findsNothing);
      expect(repo.completeCalls, 0);
    });
  });
}
