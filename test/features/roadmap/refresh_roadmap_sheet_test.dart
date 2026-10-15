import 'dart:async';

import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_node.dart';
import 'package:MatchIn/features/roadmap/data/models/skill_task.dart';
import 'package:MatchIn/features/roadmap/domain/entities/complete_roadmap_task_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/generate_roadmap_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/paginated_roadmaps_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/refresh_roadmap_params.dart';
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
import 'package:MatchIn/features/roadmap/presentation/widgets/refresh_roadmap_sheet.dart';
import 'package:MatchIn/features/roadmap/presentation/widgets/skill_details_sheet.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeRefreshFlowRepository extends Fake implements RoadmapRepository {
  Either<Failure, PaginatedRoadmapsEntity>? listResult;
  Either<Failure, RoadmapEntity>? detailsResult;
  Either<Failure, RoadmapEntity>? refreshResult;
  Either<Failure, RoadmapTask>? completeResult;
  int detailsCalls = 0;
  int refreshCalls = 0;
  int completeCalls = 0;
  RefreshRoadmapParams? lastRefreshParams;
  Object? lastRefreshBody;

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
  Future<Either<Failure, RoadmapEntity>> refreshRoadmap(
    RefreshRoadmapParams params,
  ) async {
    refreshCalls++;
    lastRefreshParams = params;
    return refreshResult!;
  }

  @override
  Future<Either<Failure, RoadmapTask>> completeRoadmapTask(
    CompleteRoadmapTaskParams params,
  ) async {
    completeCalls++;
    return completeResult!;
  }
}

class GatedRefreshFlowRepository extends FakeRefreshFlowRepository {
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

class GatedCompleteFlowRepository extends FakeRefreshFlowRepository {
  final Completer<Either<Failure, RoadmapTask>> gate = Completer();

  @override
  Future<Either<Failure, RoadmapTask>> completeRoadmapTask(
    CompleteRoadmapTaskParams params,
  ) async {
    completeCalls++;
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

const _details = RoadmapEntity(
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

const _refreshedDetails = RoadmapEntity(
  id: 1,
  title: 'AI Refreshed',
  completionPercentage: 35,
);

class _SheetHarness {
  _SheetHarness({
    required this.hostContext,
    required this.roadmapCubit,
    required this.skillTaskCubit,
    required this.prefsService,
  });

  final BuildContext hostContext;
  final RoadmapCubit roadmapCubit;
  final SkillTaskCubit skillTaskCubit;
  final SharedPreferencesService prefsService;
}

Future<_SheetHarness> _pumpHost(
  WidgetTester tester,
  FakeRefreshFlowRepository repo, {
  Locale? locale,
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
  repo.detailsResult = const Right(_details);
  await roadmapCubit.loadRoadmaps();

  late BuildContext hostContext;
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 845),
      builder: (_, _) => MaterialApp(
        locale: locale,
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
            child: Builder(
              builder: (context) {
                hostContext = context;
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return _SheetHarness(
    hostContext: hostContext,
    roadmapCubit: roadmapCubit,
    skillTaskCubit: skillTaskCubit,
    prefsService: prefsService,
  );
}

Future<void> _openSheet(_SheetHarness harness, WidgetTester tester) async {
  unawaited(
    RefreshRoadmapSheet.show(harness.hostContext, cubit: harness.roadmapCubit),
  );
  await tester.pumpAndSettle();
}

Finder _confirmButton() => find.widgetWithText(FilledButton, 'Confirm Refresh');

void main() {
  group('RefreshRoadmapSheet', () {
    testWidgets('opens with title, warning, reason field and actions', (
      tester,
    ) async {
      final repo = FakeRefreshFlowRepository();
      final harness = await _pumpHost(tester, repo);
      await _openSheet(harness, tester);

      expect(find.text('Refresh Roadmap'), findsWidgets);
      expect(
        find.text(
          'Refresh the selected roadmap using the latest available information.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Refreshing may change your roadmap milestones and tasks.'),
        findsOneWidget,
      );
      expect(find.text('Reason for refresh (optional)'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(_confirmButton(), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
    });

    testWidgets('confirm sends a trimmed reason and applies the result', (
      tester,
    ) async {
      final repo = FakeRefreshFlowRepository()
        ..refreshResult = const Right(_refreshedDetails);
      final harness = await _pumpHost(tester, repo);
      await _openSheet(harness, tester);

      await tester.enterText(find.byType(TextFormField), '  backend focus  ');
      await tester.tap(_confirmButton());
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(find.text('Roadmap refreshed successfully'), findsOneWidget);
      await tester.pumpAndSettle();

      expect(repo.refreshCalls, 1);
      expect(repo.lastRefreshParams?.roadmapId, 1);
      expect(repo.lastRefreshParams?.reason, 'backend focus');
      // Sheet closed and details replaced without a follow-up GET.
      expect(find.text('Refresh Roadmap'), findsNothing);
      expect(repo.detailsCalls, 1);
      final state = harness.roadmapCubit.state as RoadmapDetailsSuccess;
      expect(state.details.title, 'AI Refreshed');
      // XP and local stores untouched.
      expect(harness.prefsService.getRewardedAdXp(), 0);
      expect(harness.prefsService.getCollectedTreasures(), isEmpty);
      expect(harness.prefsService.getCompletedTasks(), isEmpty);
    });

    testWidgets('confirm without reason posts and closes', (tester) async {
      final repo = FakeRefreshFlowRepository()
        ..refreshResult = const Right(_refreshedDetails);
      final harness = await _pumpHost(tester, repo);
      await _openSheet(harness, tester);

      await tester.tap(_confirmButton());
      await tester.pumpAndSettle();

      expect(repo.lastRefreshParams?.reason, isNull);
      expect(find.text('Refresh Roadmap'), findsNothing);
    });

    testWidgets('loading disables input and blocks duplicate taps', (
      tester,
    ) async {
      final repo = GatedRefreshFlowRepository()
        ..refreshResult = const Right(_refreshedDetails);
      final harness = await _pumpHost(tester, repo);
      await _openSheet(harness, tester);

      await tester.tap(_confirmButton());
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester.widget<TextFormField>(find.byType(TextFormField)).enabled,
        isFalse,
      );

      // Second tap while busy issues nothing (the button shows a spinner,
      // so it is targeted by type here).
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      expect(repo.refreshCalls, 1);

      repo.gate.complete(const Right(_refreshedDetails));
      await tester.pumpAndSettle();
      expect(find.text('Refresh Roadmap'), findsNothing);
    });

    testWidgets('failure preserves reason and allows retry', (tester) async {
      final repo = FakeRefreshFlowRepository()
        ..refreshResult = const Left(
          ServerFailure(
            message: 'The given data was invalid.',
            fieldErrors: {
              'reason': ['The reason is too long.'],
            },
          ),
        );
      final harness = await _pumpHost(tester, repo);
      await _openSheet(harness, tester);

      await tester.enterText(find.byType(TextFormField), 'my reason');
      await tester.tap(_confirmButton());
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Sheet stays open with the reason intact and errors visible.
      expect(find.text('Refresh Roadmap'), findsWidgets);
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField))
            .controller
            ?.text,
        'my reason',
      );
      expect(find.text('The given data was invalid.'), findsOneWidget);
      expect(find.text('The reason is too long.'), findsOneWidget);
      // Previous roadmap preserved.
      final failed = harness.roadmapCubit.state as RoadmapAiRefreshFailure;
      expect(failed.details?.title, 'Cloud Architect');

      // Retry with a fixed backend succeeds.
      repo.refreshResult = const Right(_refreshedDetails);
      await tester.tap(_confirmButton());
      await tester.pumpAndSettle();
      expect(repo.refreshCalls, 2);
      expect(find.text('Refresh Roadmap'), findsNothing);
    });

    testWidgets('confirm is disabled while a task completion is in flight', (
      tester,
    ) async {
      final repo = GatedCompleteFlowRepository()
        ..completeResult = const Right(RoadmapTask(id: 7, title: 'Docker lab'));
      final harness = await _pumpHost(tester, repo);
      unawaited(harness.skillTaskCubit.completeTask(taskId: 7));
      await _openSheet(harness, tester);

      expect(tester.widget<FilledButton>(_confirmButton()).enabled, isFalse);

      repo.gate.complete(const Right(RoadmapTask(id: 7, title: 'Docker lab')));
      await tester.pumpAndSettle();
    });

    testWidgets('task toggle is disabled during AI refresh', (tester) async {
      final repo = GatedRefreshFlowRepository();
      final harness = await _pumpHost(tester, repo);
      unawaited(harness.roadmapCubit.aiRefreshSelectedRoadmap());
      await tester.pump();

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
                  BlocProvider.value(value: harness.roadmapCubit),
                  BlocProvider.value(value: harness.skillTaskCubit),
                ],
                child: const SkillDetailsSheet(
                  node: RoadmapNode(
                    id: '1',
                    title: 'Containers',
                    status: RoadmapTaskStatus.active,
                    tasks: [
                      SkillTask(id: '7', title: 'Docker lab', duration: '6h'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final circles = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).shape == BoxShape.circle,
      );
      await tester.tap(circles);
      await tester.pumpAndSettle();

      expect(repo.completeCalls, 0);
      expect(find.text('Docker lab'), findsOneWidget);
      repo.gate.complete(const Right(_details));
      await tester.pumpAndSettle();
    });

    testWidgets('renders Arabic strings in Arabic locale', (tester) async {
      final repo = FakeRefreshFlowRepository();
      final harness = await _pumpHost(tester, repo, locale: const Locale('ar'));
      await _openSheet(harness, tester);

      expect(find.text('تحديث خارطة الطريق'), findsWidgets);
      expect(find.text('تأكيد التحديث'), findsOneWidget);
      expect(
        find.text('قد يؤدي التحديث إلى تغيير مراحل خارطة الطريق ومهامها.'),
        findsOneWidget,
      );
    });
  });
}
