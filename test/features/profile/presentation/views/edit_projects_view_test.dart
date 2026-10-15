import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/profile/domain/entities/add_candidate_project_params.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_project_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/update_candidate_project_params.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:MatchIn/features/profile/domain/use_cases/add_candidate_project_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/delete_candidate_project_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_candidate_projects_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_project_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/update_candidate_project_use_case.dart';
import 'package:MatchIn/features/profile/presentation/cubits/projects_cubit/projects_cubit.dart';
import 'package:MatchIn/features/profile/presentation/views/edit_projects_view.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_projects_widgets/projects_view_body.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeProjectsScreenRepository extends Fake implements ProfileRepository {
  Either<Failure, List<CandidateProjectEntity>>? listResult;
  Either<Failure, CandidateProjectEntity?>? mutationResult;

  @override
  Future<Either<Failure, List<CandidateProjectEntity>>> getProjects() async {
    return listResult!;
  }

  @override
  Future<Either<Failure, CandidateProjectEntity?>> addCandidateProject(
    AddCandidateProjectParams params,
  ) async {
    return mutationResult!;
  }

  @override
  Future<Either<Failure, CandidateProjectEntity?>> updateCandidateProject(
    UpdateCandidateProjectParams params,
  ) async {
    return mutationResult!;
  }

  @override
  Future<Either<Failure, Unit>> deleteCandidateProject(int projectId) async {
    return mutationResult!.fold(
      (failure) => Left(failure),
      (_) => const Right(unit),
    );
  }
}

const _first = CandidateProjectEntity(
  id: 1,
  name: 'Order Engine',
  description: 'Queue processing.',
  technologies: ['Dart'],
  source: 'manual',
);

const _added = CandidateProjectEntity(
  id: 2,
  name: 'Health Tracker',
  source: 'manual',
  technologies: [],
);

Future<void> pumpHarness(
  WidgetTester tester, {
  required FakeProjectsScreenRepository repo,
  required List<bool?> results,
}) async {
  tester.view.physicalSize = const Size(1170, 2535);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  getIt.registerFactory<ProjectsCubit>(
    () => ProjectsCubit(
      getProjectsUseCase: GetProjectsUseCase(repository: repo),
      getProjectUseCase: GetProjectUseCase(repository: repo),
      addCandidateProjectUseCase: AddCandidateProjectUseCase(repository: repo),
      updateCandidateProjectUseCase: UpdateCandidateProjectUseCase(
        repository: repo,
      ),
      deleteCandidateProjectUseCase: DeleteCandidateProjectUseCase(
        repository: repo,
      ),
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
                    MaterialPageRoute(builder: (_) => const EditProjectsView()),
                  );
                  results.add(value);
                },
                child: const Text('open projects'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> openProjects(WidgetTester tester) async {
  await tester.tap(find.text('open projects'));
  await tester.pumpAndSettle();
  expect(find.byType(ProjectsViewBody), findsOneWidget);
}

Future<void> scrollIntoView(
  WidgetTester tester,
  Finder target, {
  required double dy,
}) async {
  final list = find.byType(ListView);
  for (int i = 0; i < 25; i++) {
    await tester.pump();
    if (target.evaluate().isNotEmpty) {
      final targetRect = tester.getRect(target);
      final listRect = tester.getRect(list);
      if (targetRect.top >= listRect.top &&
          targetRect.bottom <= listRect.bottom) {
        return;
      }
    }
    await tester.drag(list, Offset(0, dy));
    await tester.pumpAndSettle();
  }
  fail('Target was not visible after scrolling');
}

Future<void> scrollToSave(WidgetTester tester) async {
  await scrollIntoView(
    tester,
    find.widgetWithText(FilledButton, 'Save Project'),
    dy: -400,
  );
  await tester.pumpAndSettle();
}

Future<void> tapHeaderBack(WidgetTester tester) async {
  await scrollIntoView(
    tester,
    find.byIcon(Icons.arrow_back_ios_new_rounded),
    dy: 400,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
  await tester.pumpAndSettle();
}

void main() {
  late FakeProjectsScreenRepository repo;
  late List<bool?> results;

  setUp(() {
    repo = FakeProjectsScreenRepository();
    results = [];
  });

  tearDown(() async {
    await getIt.reset();
  });

  group('EditProjectsView exit paths', () {
    testWidgets('header Back returns false for a no-change session', (
      tester,
    ) async {
      repo.listResult = const Right([_first]);
      await pumpHarness(tester, repo: repo, results: results);
      await openProjects(tester);

      await tapHeaderBack(tester);

      expect(results, [false]);
      expect(find.byType(ProjectsViewBody), findsNothing);
    });

    testWidgets('system Back returns false for a no-change session', (
      tester,
    ) async {
      repo.listResult = const Right([_first]);
      await pumpHarness(tester, repo: repo, results: results);
      await openProjects(tester);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(results, [false]);
      expect(find.byType(ProjectsViewBody), findsNothing);
    });

    testWidgets('header Back returns true after a successful add', (
      tester,
    ) async {
      repo.listResult = const Right([_first]);
      repo.mutationResult = const Right(_added);
      await pumpHarness(tester, repo: repo, results: results);
      await openProjects(tester);

      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Health Tracker');
      await scrollToSave(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Save Project'));
      await tester.pumpAndSettle();
      await tapHeaderBack(tester);

      expect(results, [true]);
      expect(find.byType(ProjectsViewBody), findsNothing);
    });

    testWidgets('Cancel after mutation keeps the screen, Back is single', (
      tester,
    ) async {
      repo.listResult = const Right([_first]);
      repo.mutationResult = const Right(_added);
      await pumpHarness(tester, repo: repo, results: results);
      await openProjects(tester);

      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Health Tracker');
      await scrollToSave(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Save Project'));
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await scrollIntoView(tester, find.byType(OutlinedButton), dy: -200);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();
      await scrollIntoView(tester, find.text('Cancel'), dy: -400);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(ProjectsViewBody), findsOneWidget);
      expect(results, isEmpty);

      await tapHeaderBack(tester);

      expect(results, [true]);
      expect(find.byType(ProjectsViewBody), findsNothing);
    });

    testWidgets('system Back returns true after a successful add', (
      tester,
    ) async {
      repo.listResult = const Right([_first]);
      repo.mutationResult = const Right(_added);
      await pumpHarness(tester, repo: repo, results: results);
      await openProjects(tester);

      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Health Tracker');
      await scrollToSave(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Save Project'));
      await tester.pumpAndSettle();

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(results, [true]);
      expect(find.byType(ProjectsViewBody), findsNothing);
    });
  });

  group('EditProjectsView delete flow', () {
    testWidgets('confirmation Cancel issues no request', (tester) async {
      repo.listResult = const Right([_first]);
      await pumpHarness(tester, repo: repo, results: results);
      await openProjects(tester);

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Delete project'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Order Engine'), findsOneWidget);
    });

    testWidgets('confirmation Delete removes the project', (tester) async {
      repo.listResult = const Right([_first]);
      repo.mutationResult = const Right(_first);
      await pumpHarness(tester, repo: repo, results: results);
      await openProjects(tester);

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Order Engine'), findsNothing);
    });

    testWidgets('failed Delete preserves the list', (tester) async {
      repo.listResult = const Right([_first]);
      repo.mutationResult = const Left(ServerFailure(message: 'Delete failed'));
      await pumpHarness(tester, repo: repo, results: results);
      await openProjects(tester);

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete failed'), findsOneWidget);
      expect(find.text('Order Engine'), findsOneWidget);
    });
  });

  group('EditProjectsView loading', () {
    testWidgets('retry after GET failure loads the list', (tester) async {
      repo.listResult = const Left(OfflineFailure());
      await pumpHarness(tester, repo: repo, results: results);
      await openProjects(tester);

      repo.listResult = const Right([_first]);
      await tester.tap(find.byIcon(Icons.refresh_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Order Engine'), findsOneWidget);
    });

    testWidgets('empty list shows the empty state', (tester) async {
      repo.listResult = const Right([]);
      await pumpHarness(tester, repo: repo, results: results);
      await openProjects(tester);

      expect(find.text('No projects added yet'), findsOneWidget);
    });
  });

  group('EditProjectsView links', () {
    testWidgets('malformed link shows localized feedback', (tester) async {
      const badLink = CandidateProjectEntity(
        id: 3,
        name: 'Broken Links',
        source: 'manual',
        technologies: [],
        projectUrl: 'not-a-url',
      );
      repo.listResult = const Right([badLink]);
      await pumpHarness(tester, repo: repo, results: results);
      await openProjects(tester);

      await tester.tap(find.text('View live project'));
      await tester.pumpAndSettle();

      expect(find.text('Something went wrong'), findsOneWidget);
    });
  });
}
