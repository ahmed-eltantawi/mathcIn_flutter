import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:MatchIn/features/roadmap/domain/entities/paginated_roadmaps_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_pagination_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmaps_params.dart';
import 'package:MatchIn/features/roadmap/domain/repositories/roadmap_repository.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/get_roadmap_details_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/get_roadmaps_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/generate_roadmap_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/refresh_roadmap_use_case.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/roadmap_cubit/roadmap_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/widgets/roadmap_selector_sheet.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeSheetRepository extends Fake implements RoadmapRepository {
  FakeSheetRepository(this.pages);

  final List<Either<Failure, PaginatedRoadmapsEntity>> pages;
  int listCalls = 0;

  @override
  Future<Either<Failure, PaginatedRoadmapsEntity>> getRoadmaps({
    RoadmapsParams? params,
  }) async {
    final result = pages[listCalls.clamp(0, pages.length - 1)];
    listCalls++;
    return result;
  }

  @override
  Future<Either<Failure, RoadmapEntity>> getRoadmapDetails(
    int roadmapId,
  ) async {
    return Right(RoadmapEntity(id: roadmapId, title: 'Details $roadmapId'));
  }
}

const _page1 = Right<Failure, PaginatedRoadmapsEntity>(
  PaginatedRoadmapsEntity(
    roadmaps: [
      RoadmapEntity(id: 1, title: 'Cloud Architect', targetRole: 'Cloud'),
      RoadmapEntity(id: 2, title: 'Backend Pro', targetRole: 'Backend'),
    ],
    pagination: RoadmapPaginationEntity(
      currentPage: 1,
      lastPage: 2,
      perPage: 15,
      total: 3,
    ),
  ),
);

const _page2 = Right<Failure, PaginatedRoadmapsEntity>(
  PaginatedRoadmapsEntity(
    roadmaps: [RoadmapEntity(id: 3, title: 'Mobile Pro')],
    pagination: RoadmapPaginationEntity(
      currentPage: 2,
      lastPage: 2,
      perPage: 15,
      total: 3,
    ),
  ),
);

Future<RoadmapCubit> _readyCubit(FakeSheetRepository repo) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final cubit = RoadmapCubit(
    sharedPreferencesService: SharedPreferencesService(
      SharedPreferencesHelper(preferences: prefs),
    ),
    getRoadmapsUseCase: GetRoadmapsUseCase(repository: repo),
    getRoadmapDetailsUseCase: GetRoadmapDetailsUseCase(repository: repo),
    generateRoadmapUseCase: GenerateRoadmapUseCase(repository: repo),
    refreshRoadmapUseCase: RefreshRoadmapUseCase(repository: repo),
  );
  addTearDown(cubit.close);
  await cubit.loadRoadmaps();
  return cubit;
}

Future<void> _pumpHost(
  WidgetTester tester,
  RoadmapCubit cubit, {
  required void Function(BuildContext context) onOpen,
}) async {
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
            value: cubit,
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => onOpen(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('RoadmapSelectorSheet', () {
    testWidgets('selecting a row returns its backend id', (tester) async {
      final cubit = await _readyCubit(FakeSheetRepository([_page1]));
      int? selected;
      await _pumpHost(
        tester,
        cubit,
        onOpen: (context) async {
          selected = await RoadmapSelectorSheet.show(context, cubit: cubit);
        },
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Cloud Architect'), findsOneWidget);
      expect(find.text('Backend Pro'), findsOneWidget);

      await tester.tap(find.text('Backend Pro'));
      await tester.pumpAndSettle();

      expect(selected, 2);
    });

    testWidgets('load more appends rows', (tester) async {
      final cubit = await _readyCubit(FakeSheetRepository([_page1, _page2]));
      await _pumpHost(
        tester,
        cubit,
        onOpen: (context) => RoadmapSelectorSheet.show(context, cubit: cubit),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Load More'));
      await tester.pumpAndSettle();

      expect(find.text('Mobile Pro'), findsOneWidget);
      expect(find.text('Cloud Architect'), findsOneWidget);
      expect(find.text('Load More'), findsNothing);
    });

    testWidgets('failed load more keeps rows and shows feedback', (
      tester,
    ) async {
      final cubit = await _readyCubit(
        FakeSheetRepository([
          _page1,
          const Left(ServerFailure(message: 'Down')),
        ]),
      );
      await _pumpHost(
        tester,
        cubit,
        onOpen: (context) => RoadmapSelectorSheet.show(context, cubit: cubit),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Load More'));
      await tester.pumpAndSettle();

      expect(find.text('Cloud Architect'), findsOneWidget);
      expect(find.text('Backend Pro'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('generate row opens the generation form', (tester) async {
      final cubit = await _readyCubit(FakeSheetRepository([_page1]));
      await _pumpHost(
        tester,
        cubit,
        onOpen: (context) => RoadmapSelectorSheet.show(context, cubit: cubit),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Generate Roadmap'));
      await tester.pumpAndSettle();

      expect(find.text('Target role'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
    });
  });
}
