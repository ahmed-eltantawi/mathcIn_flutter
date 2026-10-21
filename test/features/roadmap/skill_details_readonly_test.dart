import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_node.dart';
import 'package:MatchIn/features/roadmap/data/models/skill_task.dart';
import 'package:MatchIn/features/roadmap/domain/entities/complete_roadmap_task_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_task.dart';
import 'package:MatchIn/features/roadmap/domain/repositories/roadmap_repository.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/complete_roadmap_task_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/get_cached_roadmap_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/get_roadmap_details_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/get_roadmaps_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/generate_roadmap_use_case.dart';
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

class CountingRepository extends Fake implements RoadmapRepository {
  int completeCalls = 0;

  @override
  Future<Either<Failure, RoadmapTask>> completeRoadmapTask(
    CompleteRoadmapTaskParams params,
  ) async {
    completeCalls++;
    return const Right(RoadmapTask(id: 1, title: 'Docker lab'));
  }
}

class _UnusedRepository extends Fake implements RoadmapRepository {}

Future<void> _pumpSheet(
  WidgetTester tester, {
  required RoadmapNode node,
  RoadmapRepository? skillRepository,
}) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final roadmapCubit = RoadmapCubit(
    sharedPreferencesService: SharedPreferencesService(
      SharedPreferencesHelper(preferences: prefs),
    ),
    getRoadmapsUseCase: GetRoadmapsUseCase(repository: _UnusedRepository()),
    getRoadmapDetailsUseCase: GetRoadmapDetailsUseCase(
      repository: _UnusedRepository(),
    ),
    generateRoadmapUseCase: GenerateRoadmapUseCase(
      repository: _UnusedRepository(),
    ),
    refreshRoadmapUseCase: RefreshRoadmapUseCase(
      repository: _UnusedRepository(),
    ),
    getCachedRoadmapUseCase: GetCachedRoadmapUseCase(
      repository: _UnusedRepository(),
    ),
    syncRoadmapOpsUseCase: SyncRoadmapOpsUseCase(
      repository: _UnusedRepository(),
    ),
  );
  final skillRepo = skillRepository ?? _UnusedRepository();
  final skillTaskCubit = SkillTaskCubit(
    completeRoadmapTaskUseCase: CompleteRoadmapTaskUseCase(
      repository: skillRepo,
    ),
    repository: skillRepo,
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
            child: SkillDetailsSheet(node: node),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Checkbox circle of a task card.
Finder _checkboxCircle() => find.byWidgetPredicate(
  (widget) =>
      widget is Container &&
      widget.decoration is BoxDecoration &&
      (widget.decoration as BoxDecoration).shape == BoxShape.circle,
);

void main() {
  group('SkillDetailsSheet completion guards', () {
    testWidgets('completed task tap issues no PATCH', (tester) async {
      final repo = CountingRepository();
      const node = RoadmapNode(
        title: 'Containers',
        status: RoadmapTaskStatus.active,
        tasks: [
          SkillTask(
            id: '1',
            title: 'Docker lab',
            duration: '6h',
            isCompleted: true,
          ),
        ],
      );
      await _pumpSheet(tester, node: node, skillRepository: repo);

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      await tester.tap(_checkboxCircle());
      await tester.pumpAndSettle();

      expect(repo.completeCalls, 0);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('unparseable task id issues no PATCH and no crash', (
      tester,
    ) async {
      final repo = CountingRepository();
      const node = RoadmapNode(
        title: 'Containers',
        status: RoadmapTaskStatus.active,
        tasks: [SkillTask(id: 'dart_1', title: 'Dart basics', duration: '2h')],
      );
      await _pumpSheet(tester, node: node, skillRepository: repo);

      await tester.tap(_checkboxCircle());
      await tester.pumpAndSettle();

      expect(repo.completeCalls, 0);
      expect(find.text('Dart basics'), findsOneWidget);
    });
  });
}
