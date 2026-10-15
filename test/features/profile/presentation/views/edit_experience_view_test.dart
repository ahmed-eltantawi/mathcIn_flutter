import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/profile/data/data_sources/location/location_catalog.dart';
import 'package:MatchIn/features/profile/domain/entities/add_experience_params.dart';
import 'package:MatchIn/features/profile/domain/entities/experience_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/update_experience_params.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:MatchIn/features/profile/domain/use_cases/add_experience_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/delete_experience_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_experiences_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/update_experience_use_case.dart';
import 'package:MatchIn/features/profile/presentation/cubits/experience_cubit/edit_experience_cubit.dart';
import 'package:MatchIn/features/profile/presentation/views/edit_experience_view.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_experience_widgets/edit_experience_view_body.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeExitPathRepository extends Fake implements ProfileRepository {
  Either<Failure, List<ExperienceEntity>> listResult = const Right([]);

  @override
  Future<Either<Failure, List<ExperienceEntity>>> getExperiences() async {
    return listResult;
  }

  @override
  Future<Either<Failure, ExperienceEntity?>> addExperience(
    AddExperienceParams params,
  ) async {
    return const Right(
      ExperienceEntity(
        id: 2,
        jobTitle: 'Senior Backend Developer',
        companyName: 'PayMob',
        startDate: '2024-03-01',
      ),
    );
  }

  @override
  Future<Either<Failure, ExperienceEntity?>> updateExperience(
    UpdateExperienceParams params,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> deleteExperience(int experienceId) async {
    throw UnimplementedError();
  }
}

Future<void> pumpHarness(
  WidgetTester tester, {
  required FakeExitPathRepository repo,
  required List<bool?> results,
}) async {
  tester.view.physicalSize = const Size(1170, 2535);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  getIt.registerFactory<EditExperienceCubit>(
    () => EditExperienceCubit(
      getExperiencesUseCase: GetExperiencesUseCase(repository: repo),
      addExperienceUseCase: AddExperienceUseCase(repository: repo),
      updateExperienceUseCase: UpdateExperienceUseCase(repository: repo),
      deleteExperienceUseCase: DeleteExperienceUseCase(repository: repo),
    ),
  );
  getIt.registerLazySingleton<LocationCatalog>(() => const LocationCatalog());

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
                    MaterialPageRoute(
                      builder: (_) => const EditExperienceView(),
                    ),
                  );
                  results.add(value);
                },
                child: const Text('open experience'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> openExperience(WidgetTester tester) async {
  await tester.tap(find.text('open experience'));
  await tester.pumpAndSettle();
  expect(find.byType(EditExperienceViewBody), findsOneWidget);
}

Finder experienceListScrollable() => find.byType(ListView);

/// Scrolls the screen [ListView] until [target] is fully visible.
/// Uses manual drags because [Scrollable]-based finders are ambiguous
/// here: the multiline description field embeds its own vertical
/// [Scrollable] alongside the list one.
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
  final saveFinder = find.widgetWithText(FilledButton, 'Save experience');
  await scrollIntoView(tester, saveFinder, dy: -400);
  await tester.pumpAndSettle();
}

Future<void> tapSave(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(FilledButton, 'Save experience'));
  await tester.pumpAndSettle();
}

Future<void> tapHeaderBack(WidgetTester tester) async {
  await scrollIntoView(tester, find.byIcon(Icons.arrow_back), dy: 400);
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.arrow_back));
  await tester.pumpAndSettle();
}

Future<void> fillRequiredFields(WidgetTester tester) async {
  await tester.enterText(
    find.byType(TextFormField).at(0),
    'Senior Backend Developer',
  );
  await tester.enterText(find.byType(TextFormField).at(1), 'PayMob');
  await tester.pumpAndSettle();
}

void main() {
  late FakeExitPathRepository repo;
  late List<bool?> results;

  setUp(() {
    repo = FakeExitPathRepository();
    results = [];
  });

  tearDown(() async {
    await getIt.reset();
  });

  group('EditExperienceView exit paths', () {
    testWidgets('header Back returns false for a no-change session', (
      tester,
    ) async {
      await pumpHarness(tester, repo: repo, results: results);
      await openExperience(tester);

      await tapHeaderBack(tester);

      expect(results, [false]);
      expect(find.byType(EditExperienceViewBody), findsNothing);
    });

    testWidgets('system Back returns false for a no-change session', (
      tester,
    ) async {
      await pumpHarness(tester, repo: repo, results: results);
      await openExperience(tester);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(results, [false]);
      expect(find.byType(EditExperienceViewBody), findsNothing);
    });

    testWidgets('header Back returns true after a successful mutation', (
      tester,
    ) async {
      await pumpHarness(tester, repo: repo, results: results);
      await openExperience(tester);

      await fillRequiredFields(tester);
      await scrollToSave(tester);
      await tapSave(tester);
      await tapHeaderBack(tester);

      expect(results, [true]);
      expect(find.byType(EditExperienceViewBody), findsNothing);
    });

    testWidgets('added record is visible after scrolling up', (tester) async {
      await pumpHarness(tester, repo: repo, results: results);
      await openExperience(tester);

      await fillRequiredFields(tester);
      await scrollToSave(tester);
      await tapSave(tester);
      await scrollIntoView(tester, find.text('PayMob'), dy: 400);
      await tester.pumpAndSettle();

      expect(find.text('PayMob'), findsOneWidget);
    });

    testWidgets(
      'Cancel after mutation keeps the screen, Back returns true once',
      (tester) async {
        await pumpHarness(tester, repo: repo, results: results);
        await openExperience(tester);

        await fillRequiredFields(tester);
        await scrollToSave(tester);
        await tapSave(tester);

        await scrollIntoView(tester, find.text('Cancel'), dy: -400);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(find.byType(EditExperienceViewBody), findsOneWidget);
        expect(results, isEmpty);

        await tapHeaderBack(tester);

        expect(results, [true]);
        expect(find.byType(EditExperienceViewBody), findsNothing);
      },
    );

    testWidgets('system Back returns true after a successful mutation', (
      tester,
    ) async {
      await pumpHarness(tester, repo: repo, results: results);
      await openExperience(tester);

      await fillRequiredFields(tester);
      await scrollToSave(tester);
      await tapSave(tester);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(results, [true]);
      expect(find.byType(EditExperienceViewBody), findsNothing);
    });
  });
}
