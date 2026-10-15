import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/profile/data/data_sources/location/location_catalog.dart';
import 'package:MatchIn/features/profile/domain/entities/career_preference_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/save_career_preferences_params.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_career_preferences_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/save_career_preferences_use_case.dart';
import 'package:MatchIn/features/profile/presentation/cubits/career_cubit/career_preferences_cubit.dart';
import 'package:MatchIn/features/profile/presentation/views/edit_career_preferences_view.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/career_preferences_view_body.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeCareerScreenRepository extends Fake implements ProfileRepository {
  Either<Failure, CareerPreferenceEntity?>? getResult;
  Either<Failure, CareerPreferenceEntity>? saveResult;
  SaveCareerPreferencesParams? lastParams;

  @override
  Future<Either<Failure, CareerPreferenceEntity?>>
  getCareerPreferences() async {
    return getResult!;
  }

  @override
  Future<Either<Failure, CareerPreferenceEntity>> saveCareerPreferences(
    SaveCareerPreferencesParams params,
  ) async {
    lastParams = params;
    return saveResult!;
  }
}

const _prefs = CareerPreferenceEntity(
  id: 1,
  targetRole: 'Backend Engineer',
  jobType: 'full_time',
  workMode: 'remote',
  preferredCountry: 'Egypt',
  preferredCity: 'Cairo',
  experienceLevel: 'senior',
  careerGoal: 'Lead a team.',
  openToRelocation: false,
);

const _saved = CareerPreferenceEntity(
  id: 1,
  targetRole: 'Backend Technical Lead',
  jobType: 'full_time',
  workMode: 'remote',
  preferredCountry: 'Egypt',
  preferredCity: 'Cairo',
  experienceLevel: 'senior',
  careerGoal: 'Lead a team.',
  openToRelocation: false,
);

Future<void> pumpHarness(
  WidgetTester tester, {
  required FakeCareerScreenRepository repo,
  required List<bool?> results,
}) async {
  tester.view.physicalSize = const Size(1170, 2535);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  getIt.registerFactory<CareerPreferencesCubit>(
    () => CareerPreferencesCubit(
      getCareerPreferencesUseCase: GetCareerPreferencesUseCase(
        repository: repo,
      ),
      saveCareerPreferencesUseCase: SaveCareerPreferencesUseCase(
        repository: repo,
      ),
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
                      builder: (_) => const EditCareerPreferencesView(),
                    ),
                  );
                  results.add(value);
                },
                child: const Text('open career preferences'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> openCareerPreferences(WidgetTester tester) async {
  await tester.tap(find.text('open career preferences'));
  await tester.pumpAndSettle();
  expect(find.byType(CareerPreferencesViewBody), findsOneWidget);
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

Future<void> tapSave(WidgetTester tester) async {
  await scrollIntoView(
    tester,
    find.widgetWithText(FilledButton, 'Save Preferences'),
    dy: -400,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(FilledButton, 'Save Preferences'));
  await tester.pumpAndSettle();
}

Future<void> tapCancel(WidgetTester tester) async {
  await scrollIntoView(tester, find.text('Cancel'), dy: -400);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Cancel'));
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
  late FakeCareerScreenRepository repo;
  late List<bool?> results;

  setUp(() {
    repo = FakeCareerScreenRepository();
    results = [];
  });

  tearDown(() async {
    await getIt.reset();
  });

  group('EditCareerPreferencesView exit paths', () {
    testWidgets('header Back returns false for a no-change session', (
      tester,
    ) async {
      repo.getResult = const Right(_prefs);
      await pumpHarness(tester, repo: repo, results: results);
      await openCareerPreferences(tester);

      await tapHeaderBack(tester);

      expect(results, [false]);
      expect(find.byType(CareerPreferencesViewBody), findsNothing);
    });

    testWidgets('system Back returns false for a no-change session', (
      tester,
    ) async {
      repo.getResult = const Right(_prefs);
      await pumpHarness(tester, repo: repo, results: results);
      await openCareerPreferences(tester);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(results, [false]);
      expect(find.byType(CareerPreferencesViewBody), findsNothing);
    });

    testWidgets('Cancel returns false when nothing changed', (tester) async {
      repo.getResult = const Right(_prefs);
      await pumpHarness(tester, repo: repo, results: results);
      await openCareerPreferences(tester);

      await tapCancel(tester);

      expect(results, [false]);
      expect(find.byType(CareerPreferencesViewBody), findsNothing);
    });

    testWidgets('header Back returns true once after a successful save', (
      tester,
    ) async {
      repo.getResult = const Right(_prefs);
      repo.saveResult = const Right(_saved);
      await pumpHarness(tester, repo: repo, results: results);
      await openCareerPreferences(tester);

      await tester.enterText(
        find.byType(TextFormField).first,
        'Backend Technical Lead',
      );
      await tapSave(tester);
      await tapHeaderBack(tester);

      expect(results, [true]);
      expect(find.byType(CareerPreferencesViewBody), findsNothing);
    });

    testWidgets('Cancel after save returns true once', (tester) async {
      repo.getResult = const Right(_prefs);
      repo.saveResult = const Right(_saved);
      await pumpHarness(tester, repo: repo, results: results);
      await openCareerPreferences(tester);

      await tester.enterText(
        find.byType(TextFormField).first,
        'Backend Technical Lead',
      );
      await tapSave(tester);

      expect(find.byType(CareerPreferencesViewBody), findsOneWidget);
      expect(results, isEmpty);

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tapCancel(tester);

      expect(results, [true]);
      expect(find.byType(CareerPreferencesViewBody), findsNothing);
    });

    testWidgets('system Back returns true after a successful save', (
      tester,
    ) async {
      repo.getResult = const Right(_prefs);
      repo.saveResult = const Right(_saved);
      await pumpHarness(tester, repo: repo, results: results);
      await openCareerPreferences(tester);

      await tester.enterText(
        find.byType(TextFormField).first,
        'Backend Technical Lead',
      );
      await tapSave(tester);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(results, [true]);
      expect(find.byType(CareerPreferencesViewBody), findsNothing);
    });
  });

  group('EditCareerPreferencesView save flow', () {
    testWidgets('preserves entered values after failed Save', (tester) async {
      repo.getResult = const Right(_prefs);
      repo.saveResult = const Left(ServerFailure(message: 'Save failed'));
      await pumpHarness(tester, repo: repo, results: results);
      await openCareerPreferences(tester);

      await tester.enterText(
        find.byType(TextFormField).first,
        'Backend Technical Lead',
      );
      await tapSave(tester);

      expect(find.text('Save failed'), findsOneWidget);
      final field = tester.widget<TextFormField>(
        find.byType(TextFormField).first,
      );
      expect(field.controller!.text, 'Backend Technical Lead');
    });

    testWidgets('sends only changed fields', (tester) async {
      repo.getResult = const Right(_prefs);
      repo.saveResult = const Right(_saved);
      await pumpHarness(tester, repo: repo, results: results);
      await openCareerPreferences(tester);

      await tester.enterText(
        find.byType(TextFormField).first,
        'Backend Technical Lead',
      );
      await tapSave(tester);

      final params = repo.lastParams!;
      expect(params.hasChanges, isTrue);
      expect(SaveCareerPreferencesParams.isSet(params.targetRole), isTrue);
      expect(SaveCareerPreferencesParams.isSet(params.jobType), isFalse);
      expect(SaveCareerPreferencesParams.isSet(params.targetRoles), isFalse);
    });
  });

  group('EditCareerPreferencesView loading', () {
    testWidgets('retry after GET failure loads the form', (tester) async {
      repo.getResult = const Left(OfflineFailure());
      await pumpHarness(tester, repo: repo, results: results);
      await openCareerPreferences(tester);

      repo.getResult = const Right(_prefs);
      await tester.tap(find.byIcon(Icons.refresh_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Backend Engineer'), findsOneWidget);
    });

    testWidgets('renders an empty form when preferences are null', (
      tester,
    ) async {
      repo.getResult = const Right(null);
      await pumpHarness(tester, repo: repo, results: results);
      await openCareerPreferences(tester);

      expect(find.text('Save Preferences'), findsOneWidget);
    });

    testWidgets('renders unknown machine values without crashing', (
      tester,
    ) async {
      repo.getResult = const Right(
        CareerPreferenceEntity(id: 1, jobType: 'hyper_full'),
      );
      await pumpHarness(tester, repo: repo, results: results);
      await openCareerPreferences(tester);

      expect(find.text('Save Preferences'), findsOneWidget);
    });

    testWidgets('disabled location controls do not navigate or change', (
      tester,
    ) async {
      repo.getResult = const Right(_prefs);
      await pumpHarness(tester, repo: repo, results: results);
      await openCareerPreferences(tester);

      expect(find.text('Egypt'), findsOneWidget);
    });
  });
}
