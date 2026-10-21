import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:MatchIn/features/roadmap/domain/entities/paginated_roadmaps_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_milestone.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_pagination_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_task.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmaps_params.dart';
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
import 'package:MatchIn/features/roadmap/presentation/utils/roadmap_node_mapper.dart';
import 'package:MatchIn/features/roadmap/presentation/widgets/roadmap_list_widget.dart';
import 'package:MatchIn/features/roadmap/presentation/widgets/roadmap_node.dart';
import 'package:MatchIn/features/roadmap/presentation/widgets/roadmap_view_body.dart';
import 'package:MatchIn/features/roadmap/presentation/widgets/treasure_box_node.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeRenderRepository extends Fake implements RoadmapRepository {
  Either<Failure, PaginatedRoadmapsEntity>? listResult;
  Either<Failure, RoadmapEntity>? detailsResult;

  @override
  Future<Either<Failure, PaginatedRoadmapsEntity>> getRoadmaps({
    RoadmapsParams? params,
  }) async => listResult!;

  @override
  Future<Either<Failure, RoadmapEntity>> getRoadmapDetails(
    int roadmapId,
  ) async => detailsResult!;
}

RoadmapEntity detailsWith(int taskCount, {int completed = 0}) {
  final first = List.generate(
    taskCount,
    (i) => RoadmapTask(
      id: i + 1,
      title: 'Task ${i + 1}',
      isCompleted: i < completed,
    ),
  );
  return RoadmapEntity(
    id: 1,
    title: 'Cloud Architect',
    targetRole: 'Cloud Architect',
    milestones: [
      RoadmapMilestone(id: 1, title: 'Phase one', order: 1, tasks: first),
    ],
  );
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

RoadmapCubit buildCubit(
  SharedPreferencesService prefs,
  FakeRenderRepository repo,
) => RoadmapCubit(
  sharedPreferencesService: prefs,
  getRoadmapsUseCase: GetRoadmapsUseCase(repository: repo),
  getRoadmapDetailsUseCase: GetRoadmapDetailsUseCase(repository: repo),
  generateRoadmapUseCase: GenerateRoadmapUseCase(repository: repo),
  refreshRoadmapUseCase: RefreshRoadmapUseCase(repository: repo),
  getCachedRoadmapUseCase: GetCachedRoadmapUseCase(repository: repo),
  syncRoadmapOpsUseCase: SyncRoadmapOpsUseCase(repository: repo),
);

Future<SharedPreferencesService> freshPrefs() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return SharedPreferencesService(SharedPreferencesHelper(preferences: prefs));
}

/// Pumps the winding list exactly as the details view feeds it: backend
/// milestones mapped to visual nodes. (The full body additionally needs
/// app-theme extensions, so it is covered separately by the empty-state
/// test, which never builds the themed XP/ad widgets.)
Future<void> pumpList(
  WidgetTester tester,
  RoadmapEntity details, {
  required RoadmapCubit roadmapCubit,
}) async {
  final skillRepo = FakeRenderRepository();
  final skillCubit = SkillTaskCubit(
    completeRoadmapTaskUseCase: CompleteRoadmapTaskUseCase(
      repository: skillRepo,
    ),
    repository: skillRepo,
  );
  addTearDown(skillCubit.close);
  addTearDown(roadmapCubit.close);

  final nodes = RoadmapNodeMapper.mapMilestones(
    details.milestones,
    durationLabel: (hours) => '${hours}h',
  );

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
              BlocProvider.value(value: skillCubit),
            ],
            child: RoadmapListWidget(nodes: nodes),
          ),
        ),
      ),
    ),
  );
  // Bounded pumps only: floating Lottie decorations repeat forever, so
  // pumpAndSettle would never terminate.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump();
}

void main() {
  group('Roadmap node rendering from API data', () {
    testWidgets('every valid task renders as a node in order', (tester) async {
      final prefsService = await freshPrefs();
      final repo = FakeRenderRepository()
        ..listResult = const Right(_page)
        ..detailsResult = Right(detailsWith(3, completed: 1));
      final roadmapCubit = buildCubit(prefsService, repo);
      await roadmapCubit.loadRoadmaps();
      await pumpList(
        tester,
        detailsWith(3, completed: 1),
        roadmapCubit: roadmapCubit,
      );

      expect(find.byType(RoadmapTaskNode), findsNWidgets(3));
      expect(find.text('Task 1'), findsOneWidget);
      expect(find.text('Task 2'), findsOneWidget);
      expect(find.text('Task 3'), findsOneWidget);
      // Fewer than five nodes: no treasure box on the path.
      expect(find.byType(TreasureBoxNodeWidget), findsNothing);
    });

    testWidgets('five completions unlock the first treasure box', (
      tester,
    ) async {
      final prefsService = await freshPrefs();
      final repo = FakeRenderRepository()
        ..listResult = const Right(_page)
        ..detailsResult = Right(detailsWith(6, completed: 5));
      final roadmapCubit = buildCubit(prefsService, repo);
      await roadmapCubit.loadRoadmaps();
      await pumpList(
        tester,
        detailsWith(6, completed: 5),
        roadmapCubit: roadmapCubit,
      );

      expect(find.byType(RoadmapTaskNode), findsNWidgets(6));
      expect(find.byType(TreasureBoxNodeWidget), findsOneWidget);
      expect(find.text('🎁 Claim +50 XP!'), findsOneWidget);
    });

    testWidgets('incomplete fifth node keeps the box locked', (tester) async {
      final prefsService = await freshPrefs();
      final repo = FakeRenderRepository()
        ..listResult = const Right(_page)
        ..detailsResult = Right(detailsWith(6, completed: 4));
      final roadmapCubit = buildCubit(prefsService, repo);
      await roadmapCubit.loadRoadmaps();
      await pumpList(
        tester,
        detailsWith(6, completed: 4),
        roadmapCubit: roadmapCubit,
      );

      expect(find.byType(TreasureBoxNodeWidget), findsOneWidget);
      expect(find.text('🔒 +50 XP Milestone'), findsOneWidget);
      expect(find.text('🎁 Claim +50 XP!'), findsNothing);
    });

    testWidgets('long roadmaps scroll without losing nodes', (tester) async {
      final prefsService = await freshPrefs();
      final repo = FakeRenderRepository()
        ..listResult = const Right(_page)
        ..detailsResult = Right(detailsWith(12, completed: 3));
      final roadmapCubit = buildCubit(prefsService, repo);
      await roadmapCubit.loadRoadmaps();
      await pumpList(
        tester,
        detailsWith(12, completed: 3),
        roadmapCubit: roadmapCubit,
      );

      expect(find.byType(RoadmapTaskNode), findsNWidgets(12));
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -600),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(RoadmapTaskNode), findsNWidgets(12));
    });

    testWidgets('empty milestones show the localized empty state', (
      tester,
    ) async {
      final prefsService = await freshPrefs();
      final repo = FakeRenderRepository()
        ..listResult = const Right(_page)
        ..detailsResult = const Right(
          RoadmapEntity(id: 1, title: 'Empty roadmap'),
        );
      final roadmapCubit = buildCubit(prefsService, repo);
      addTearDown(roadmapCubit.close);
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
              body: BlocProvider.value(
                value: roadmapCubit,
                child: const RoadmapViewBody(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RoadmapTaskNode), findsNothing);
      expect(find.text('No roadmaps yet'), findsOneWidget);
    });

    testWidgets('long titles and subtitles truncate with ellipsis', (
      tester,
    ) async {
      const longTitle =
          'Study core documentation and patterns for Core Fundamentals '
          'with additional advanced topics and extended learning material';
      const longSubtitle =
          'A very long milestone description that would otherwise push '
          'neighboring nodes out of their intended winding-path positions';
      final prefsService = await freshPrefs();
      final repo = FakeRenderRepository()
        ..listResult = const Right(_page)
        ..detailsResult = Right(detailsWith(1));
      final roadmapCubit = buildCubit(prefsService, repo);
      await roadmapCubit.loadRoadmaps();
      await pumpList(
        tester,
        RoadmapEntity(
          id: 1,
          title: 'R',
          milestones: [
            RoadmapMilestone(
              id: 1,
              title: longSubtitle,
              order: 1,
              tasks: [
                RoadmapTask(id: 1, title: longTitle),
                RoadmapTask(id: 2, title: 'Short'),
              ],
            ),
          ],
        ),
        roadmapCubit: roadmapCubit,
      );

      final titleText = tester.widget<Text>(
        find.text(longTitle, skipOffstage: false),
      );
      expect(titleText.maxLines, 3);
      expect(titleText.overflow, TextOverflow.ellipsis);
      expect(titleText.textAlign, TextAlign.center);
      final subtitleTexts = tester.widgetList<Text>(
        find.text(longSubtitle, skipOffstage: false),
      );
      // Both nodes share the milestone subtitle; each copy truncates.
      expect(subtitleTexts, hasLength(2));
      for (final subtitleText in subtitleTexts) {
        expect(subtitleText.maxLines, 2);
        expect(subtitleText.overflow, TextOverflow.ellipsis);
        expect(subtitleText.textAlign, TextAlign.center);
      }
      // Stored data is untouched; only the presentation truncates, and
      // the path still lays out without overflow errors.
      expect(find.byType(RoadmapTaskNode), findsNWidgets(2));
    });

    testWidgets('arabic titles truncate within the node bounds', (
      tester,
    ) async {
      const arabicTitle =
          'دراسة الوثائق الأساسية والأنماط المتقدمة مع مواد تعليمية إضافية طويلة جدا';
      final prefsService = await freshPrefs();
      final repo = FakeRenderRepository()
        ..listResult = const Right(_page)
        ..detailsResult = Right(detailsWith(1));
      final roadmapCubit = buildCubit(prefsService, repo);
      await roadmapCubit.loadRoadmaps();
      await pumpList(
        tester,
        RoadmapEntity(
          id: 1,
          title: 'R',
          milestones: [
            RoadmapMilestone(
              id: 1,
              title: 'M',
              order: 1,
              tasks: [RoadmapTask(id: 1, title: arabicTitle)],
            ),
          ],
        ),
        roadmapCubit: roadmapCubit,
      );

      final titleText = tester.widget<Text>(
        find.text(arabicTitle, skipOffstage: false),
      );
      expect(titleText.maxLines, 3);
      expect(titleText.overflow, TextOverflow.ellipsis);
      expect(find.byType(RoadmapTaskNode), findsOneWidget);
    });
  });
}
