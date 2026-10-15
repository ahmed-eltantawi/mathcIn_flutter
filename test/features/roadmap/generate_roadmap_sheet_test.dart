import 'dart:async';

import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:MatchIn/features/roadmap/domain/entities/generate_roadmap_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/paginated_roadmaps_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_milestone.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_pagination_entity.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_task.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmaps_params.dart';
import 'package:MatchIn/features/roadmap/domain/repositories/roadmap_repository.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/generate_roadmap_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/refresh_roadmap_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/get_roadmap_details_use_case.dart';
import 'package:MatchIn/features/roadmap/domain/use_cases/get_roadmaps_use_case.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/roadmap_cubit/roadmap_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/treasure_cubit/treasure_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/widgets/generate_roadmap_sheet.dart';
import 'package:MatchIn/features/roadmap/presentation/widgets/roadmap_view_body.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeGenerateRepository extends Fake implements RoadmapRepository {
  FakeGenerateRepository({this.listResult, this.generateResult});

  Either<Failure, PaginatedRoadmapsEntity>? listResult;
  Either<Failure, RoadmapEntity>? generateResult;
  int generateCalls = 0;
  CompleterGate? generateGate;

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
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, RoadmapEntity>> generateRoadmap(
    GenerateRoadmapParams params,
  ) async {
    generateCalls++;
    final gate = generateGate;
    if (gate != null) {
      await gate.future;
    }
    return generateResult!;
  }
}

/// Manual gate for holding a fake async call open across pumps.
class CompleterGate {
  final Completer<void> _completer = Completer<void>();

  Future<void> get future => _completer.future;

  void open() {
    if (!_completer.isCompleted) _completer.complete();
  }
}

const _emptyPage = PaginatedRoadmapsEntity(
  roadmaps: [],
  pagination: RoadmapPaginationEntity(
    currentPage: 1,
    lastPage: 1,
    perPage: 15,
    total: 0,
  ),
);

const _generated = RoadmapEntity(
  id: 9,
  title: 'Fresh AI Roadmap',
  milestones: [
    RoadmapMilestone(
      id: 1,
      title: 'Containers',
      order: 1,
      tasks: [RoadmapTask(id: 1, title: 'Docker lab', isCompleted: false)],
    ),
  ],
);

Future<RoadmapCubit> _buildCubit(FakeGenerateRepository repo) async {
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
  return cubit;
}

Future<void> _pumpSheetHost(
  WidgetTester tester,
  RoadmapCubit cubit, {
  required Future<void> Function(BuildContext context) onOpen,
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

Finder _sheetGenerateButton() => find.descendant(
  of: find.byType(GenerateRoadmapSheet),
  matching: find.widgetWithText(FilledButton, 'Generate Roadmap'),
);

Future<void> _fillRole(WidgetTester tester, String role) async {
  await tester.enterText(find.byType(TextFormField).first, role);
  await tester.pumpAndSettle();
}

void main() {
  group('GenerateRoadmapSheet', () {
    testWidgets('successful generation pops with the new id', (tester) async {
      final repo = FakeGenerateRepository(
        listResult: const Right(_emptyPage),
        generateResult: const Right(_generated),
      );
      final cubit = await _buildCubit(repo);
      int? result;
      await _pumpSheetHost(
        tester,
        cubit,
        onOpen: (context) async {
          result = await GenerateRoadmapSheet.show(context, cubit: cubit);
        },
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await _fillRole(tester, 'Backend Engineer');
      await tester.tap(_sheetGenerateButton());
      await tester.pumpAndSettle();

      expect(result, 9);
      expect(find.text('Roadmap generated successfully'), findsOneWidget);
      expect(repo.generateCalls, 1);
      expect(cubit.selectedRoadmapId, 9);
      expect(cubit.state, isA<RoadmapDetailsSuccess>());
    });

    testWidgets('shows progress while generating', (tester) async {
      final repo = FakeGenerateRepository(
        listResult: const Right(_emptyPage),
        generateResult: const Right(_generated),
      )..generateGate = CompleterGate();
      final cubit = await _buildCubit(repo);
      await _pumpSheetHost(
        tester,
        cubit,
        onOpen: (context) => GenerateRoadmapSheet.show(context, cubit: cubit),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await _fillRole(tester, 'Backend Engineer');
      await tester.tap(_sheetGenerateButton());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
      repo.generateGate!.open();
      await tester.pumpAndSettle();

      expect(find.text('Roadmap generated successfully'), findsOneWidget);
    });

    testWidgets('422 shows inline errors and preserves values', (tester) async {
      final repo = FakeGenerateRepository(
        listResult: const Right(_emptyPage),
        generateResult: const Left(
          ServerFailure(
            message: 'The given data was invalid.',
            fieldErrors: {
              'target_role': ['The target role field is required.'],
            },
          ),
        ),
      );
      final cubit = await _buildCubit(repo);
      await _pumpSheetHost(
        tester,
        cubit,
        onOpen: (context) => GenerateRoadmapSheet.show(context, cubit: cubit),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await _fillRole(tester, 'Backend Engineer');
      await tester.tap(_sheetGenerateButton());
      await tester.pumpAndSettle();

      expect(find.text('The target role field is required.'), findsOneWidget);
      expect(find.text('The given data was invalid.'), findsOneWidget);
      final field = tester.widget<TextFormField>(
        find.byType(TextFormField).first,
      );
      expect(field.controller!.text, 'Backend Engineer');
    });

    testWidgets('empty role is rejected without a request', (tester) async {
      final repo = FakeGenerateRepository(
        listResult: const Right(_emptyPage),
        generateResult: const Right(_generated),
      );
      final cubit = await _buildCubit(repo);
      await _pumpSheetHost(
        tester,
        cubit,
        onOpen: (context) => GenerateRoadmapSheet.show(context, cubit: cubit),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(_sheetGenerateButton());
      await tester.pumpAndSettle();

      expect(find.text('Required'), findsOneWidget);
      expect(repo.generateCalls, 0);
    });
  });

  group('Empty state generate entry', () {
    testWidgets('empty view offers generation', (tester) async {
      final repo = FakeGenerateRepository(
        listResult: const Right(_emptyPage),
        generateResult: const Right(_generated),
      );
      final cubit = await _buildCubit(repo);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final treasureCubit = TreasureCubit(
        sharedPreferencesService: SharedPreferencesService(
          SharedPreferencesHelper(preferences: prefs),
        ),
      );
      addTearDown(treasureCubit.close);

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
                  BlocProvider.value(value: cubit),
                  BlocProvider.value(value: treasureCubit),
                ],
                child: const RoadmapViewBody(),
              ),
            ),
          ),
        ),
      );

      await cubit.loadRoadmaps();
      await tester.pumpAndSettle();

      expect(find.text('No roadmaps yet'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Generate Roadmap'));
      await tester.pumpAndSettle();

      expect(find.text('Target role'), findsOneWidget);
    });
  });
}
