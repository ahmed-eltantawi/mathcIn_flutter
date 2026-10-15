import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/profile/domain/entities/add_education_params.dart';
import 'package:MatchIn/features/profile/domain/entities/education_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/update_education_params.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:MatchIn/features/profile/domain/use_cases/add_education_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/delete_education_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_educations_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/update_education_use_case.dart';
import 'package:MatchIn/features/profile/presentation/cubits/education_cubit/edit_education_cubit.dart';
import 'package:MatchIn/features/profile/presentation/views/edit_education_view.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_education_widgets/edit_education_view_body.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeExitPathRepository extends Fake implements ProfileRepository {
  Either<Failure, List<EducationEntity>> listResult = const Right([]);

  @override
  Future<Either<Failure, List<EducationEntity>>> getEducations() async {
    return listResult;
  }

  @override
  Future<Either<Failure, EducationEntity?>> addEducation(
    AddEducationParams params,
  ) async {
    return const Right(
      EducationEntity(
        id: 2,
        degree: 'Master of Science',
        institution: 'Cairo University',
        startDate: '2023-09-01',
      ),
    );
  }

  @override
  Future<Either<Failure, EducationEntity?>> updateEducation(
    UpdateEducationParams params,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> deleteEducation(int educationId) async {
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

  getIt.registerFactory<EditEducationCubit>(
    () => EditEducationCubit(
      getEducationsUseCase: GetEducationsUseCase(repository: repo),
      addEducationUseCase: AddEducationUseCase(repository: repo),
      updateEducationUseCase: UpdateEducationUseCase(repository: repo),
      deleteEducationUseCase: DeleteEducationUseCase(repository: repo),
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
                    MaterialPageRoute(
                      builder: (_) => const EditEducationView(),
                    ),
                  );
                  results.add(value);
                },
                child: const Text('open education'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> openEducation(WidgetTester tester) async {
  await tester.tap(find.text('open education'));
  await tester.pumpAndSettle();
  expect(find.byType(EditEducationViewBody), findsOneWidget);
}

Finder educationListScrollable() => find.byWidgetPredicate(
  (widget) => widget is Scrollable && widget.axis == Axis.vertical,
);

Future<void> scrollToSave(WidgetTester tester) async {
  final saveFinder = find.widgetWithText(FilledButton, 'Save education');
  await tester.scrollUntilVisible(
    saveFinder,
    300,
    scrollable: educationListScrollable(),
  );
  await tester.pumpAndSettle();
}

Future<void> tapSave(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(FilledButton, 'Save education'));
  await tester.pumpAndSettle();
}

Future<void> tapHeaderBack(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.byIcon(Icons.arrow_back),
    -300,
    scrollable: educationListScrollable(),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.arrow_back));
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

  group('EditEducationView exit paths', () {
    testWidgets('header Back returns false for a no-change session', (
      tester,
    ) async {
      await pumpHarness(tester, repo: repo, results: results);
      await openEducation(tester);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(results, [false]);
      expect(find.byType(EditEducationViewBody), findsNothing);
    });

    testWidgets('system Back returns false for a no-change session', (
      tester,
    ) async {
      await pumpHarness(tester, repo: repo, results: results);
      await openEducation(tester);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(results, [false]);
      expect(find.byType(EditEducationViewBody), findsNothing);
    });

    testWidgets('header Back returns true after a successful mutation', (
      tester,
    ) async {
      await pumpHarness(tester, repo: repo, results: results);
      await openEducation(tester);

      await tester.enterText(
        find.byType(TextFormField).at(2),
        'Cairo University',
      );
      await scrollToSave(tester);
      await tapSave(tester);
      await tapHeaderBack(tester);

      expect(results, [true]);
      expect(find.byType(EditEducationViewBody), findsNothing);
    });

    testWidgets('added record is visible after scrolling up', (tester) async {
      await pumpHarness(tester, repo: repo, results: results);
      await openEducation(tester);

      await tester.enterText(
        find.byType(TextFormField).at(2),
        'Cairo University',
      );
      await scrollToSave(tester);
      await tapSave(tester);
      await tester.scrollUntilVisible(
        find.text('Cairo University'),
        -300,
        scrollable: educationListScrollable(),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cairo University'), findsOneWidget);
    });

    testWidgets(
      'Cancel after mutation keeps the screen, Back returns true once',
      (tester) async {
        await pumpHarness(tester, repo: repo, results: results);
        await openEducation(tester);

        await tester.enterText(
          find.byType(TextFormField).at(2),
          'Cairo University',
        );
        await scrollToSave(tester);
        await tapSave(tester);

        await tester.scrollUntilVisible(
          find.text('Cancel'),
          300,
          scrollable: educationListScrollable(),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(find.byType(EditEducationViewBody), findsOneWidget);
        expect(results, isEmpty);

        await tapHeaderBack(tester);
        await tester.pumpAndSettle();

        expect(results, [true]);
        expect(find.byType(EditEducationViewBody), findsNothing);
      },
    );

    testWidgets('system Back returns true after a successful mutation', (
      tester,
    ) async {
      await pumpHarness(tester, repo: repo, results: results);
      await openEducation(tester);

      await tester.enterText(
        find.byType(TextFormField).at(2),
        'Cairo University',
      );
      await scrollToSave(tester);
      await tapSave(tester);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(results, [true]);
      expect(find.byType(EditEducationViewBody), findsNothing);
    });
  });
}
