import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/profile/domain/entities/add_candidate_skill_params.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_skill_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/skill_search_result_entity.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:MatchIn/features/profile/domain/use_cases/add_candidate_skill_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_candidate_skills_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/remove_candidate_skill_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/search_skills_use_case.dart';
import 'package:MatchIn/features/profile/presentation/cubits/skills_cubit/skills_cubit.dart';
import 'package:MatchIn/features/profile/presentation/views/edit_skills_view.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_skills_widgets/skills_view_body.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSkillsScreenRepository extends Fake implements ProfileRepository {
  Either<Failure, List<CandidateSkillEntity>>? listResult;
  Either<Failure, CandidateSkillEntity>? addResult;
  Either<Failure, Unit>? removeResult = const Right(unit);

  @override
  Future<Either<Failure, List<CandidateSkillEntity>>>
  getCandidateSkills() async {
    return listResult!;
  }

  @override
  Future<Either<Failure, CandidateSkillEntity>> addCandidateSkill(
    AddCandidateSkillParams params,
  ) async {
    return addResult!;
  }

  @override
  Future<Either<Failure, Unit>> removeCandidateSkill(
    int candidateSkillId,
  ) async {
    return removeResult!;
  }

  @override
  Future<Either<Failure, List<SkillSearchResultEntity>>> searchSkills(
    String query,
  ) async {
    return const Right([]);
  }
}

const _flutter = CandidateSkillEntity(
  id: 1,
  skillId: 101,
  name: 'Flutter',
  source: 'manual',
);

const _docker = CandidateSkillEntity(
  id: 2,
  skillId: 102,
  name: 'Docker',
  source: 'manual',
);

const _cvSkill = CandidateSkillEntity(
  id: 3,
  skillId: 103,
  name: 'REST APIs',
  source: 'cv',
);

Future<void> pumpHarness(
  WidgetTester tester, {
  required FakeSkillsScreenRepository repo,
  required List<bool?> results,
}) async {
  tester.view.physicalSize = const Size(1170, 2535);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  getIt.registerFactory<SkillsCubit>(
    () => SkillsCubit(
      getCandidateSkillsUseCase: GetCandidateSkillsUseCase(repository: repo),
      addCandidateSkillUseCase: AddCandidateSkillUseCase(repository: repo),
      removeCandidateSkillUseCase: RemoveCandidateSkillUseCase(
        repository: repo,
      ),
      searchSkillsUseCase: SearchSkillsUseCase(repository: repo),
    ),
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
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  final value = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(builder: (_) => const EditSkillsView()),
                  );
                  results.add(value);
                },
                child: const Text('open skills'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> openSkills(WidgetTester tester) async {
  await tester.tap(find.text('open skills'));
  await tester.pumpAndSettle();
  expect(find.byType(SkillsViewBody), findsOneWidget);
}

Future<void> tapHeaderBack(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
  await tester.pumpAndSettle();
}

void main() {
  late FakeSkillsScreenRepository repo;
  late List<bool?> results;

  setUp(() {
    repo = FakeSkillsScreenRepository();
    results = [];
  });

  tearDown(() async {
    await getIt.reset();
  });

  group('EditSkillsView exit paths', () {
    testWidgets('header Back returns false for a no-change session', (
      tester,
    ) async {
      repo.listResult = const Right([_flutter]);
      await pumpHarness(tester, repo: repo, results: results);
      await openSkills(tester);

      await tapHeaderBack(tester);

      expect(results, [false]);
      expect(find.byType(SkillsViewBody), findsNothing);
    });

    testWidgets('system Back returns false for a no-change session', (
      tester,
    ) async {
      repo.listResult = const Right([_flutter]);
      await pumpHarness(tester, repo: repo, results: results);
      await openSkills(tester);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(results, [false]);
      expect(find.byType(SkillsViewBody), findsNothing);
    });

    testWidgets('header Back returns true once after a successful add', (
      tester,
    ) async {
      repo.listResult = const Right([_flutter]);
      repo.addResult = const Right(_docker);
      await pumpHarness(tester, repo: repo, results: results);
      await openSkills(tester);

      await tester.enterText(find.byType(TextField), 'Docker');
      await tester.tap(find.widgetWithText(FilledButton, 'Add'));
      await tester.pumpAndSettle();

      await tapHeaderBack(tester);

      expect(results, [true]);
      expect(find.byType(SkillsViewBody), findsNothing);
    });
  });

  group('EditSkillsView add flow', () {
    testWidgets('clears the input only after confirmed successful Add', (
      tester,
    ) async {
      repo.listResult = const Right([_flutter]);
      repo.addResult = const Right(_docker);
      await pumpHarness(tester, repo: repo, results: results);
      await openSkills(tester);

      await tester.enterText(find.byType(TextField), 'Docker');
      await tester.tap(find.widgetWithText(FilledButton, 'Add'));
      await tester.pumpAndSettle();

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, isEmpty);
      expect(find.text('Docker'), findsOneWidget);
    });

    testWidgets('preserves entered text after failed Add', (tester) async {
      repo.listResult = const Right([_flutter]);
      repo.addResult = const Left(ServerFailure(message: 'Add failed'));
      await pumpHarness(tester, repo: repo, results: results);
      await openSkills(tester);

      await tester.enterText(find.byType(TextField), 'Docker');
      await tester.tap(find.widgetWithText(FilledButton, 'Add'));
      await tester.pumpAndSettle();

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, 'Docker');
      expect(find.text('Add failed'), findsOneWidget);
    });
  });

  group('EditSkillsView delete flow', () {
    testWidgets('keeps the list visible after failed Delete', (tester) async {
      repo.listResult = const Right([_flutter]);
      repo.removeResult = const Left(ServerFailure(message: 'Delete failed'));
      await pumpHarness(tester, repo: repo, results: results);
      await openSkills(tester);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Delete failed'), findsOneWidget);
      expect(find.text('Flutter'), findsOneWidget);
    });
  });

  group('EditSkillsView loading', () {
    testWidgets('retry after GET failure loads the list', (tester) async {
      repo.listResult = const Left(OfflineFailure());
      await pumpHarness(tester, repo: repo, results: results);
      await openSkills(tester);

      expect(find.byType(SkillsViewBody), findsOneWidget);

      repo.listResult = const Right([_flutter]);
      await tester.tap(find.byIcon(Icons.refresh_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Flutter'), findsOneWidget);
    });

    testWidgets('displays non-manual skills instead of discarding them', (
      tester,
    ) async {
      repo.listResult = const Right([_flutter, _cvSkill]);
      await pumpHarness(tester, repo: repo, results: results);
      await openSkills(tester);

      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('REST APIs'), findsOneWidget);
    });
  });
}
