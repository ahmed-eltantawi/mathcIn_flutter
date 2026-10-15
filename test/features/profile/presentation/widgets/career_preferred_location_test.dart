import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/profile/data/data_sources/location/location_catalog.dart';
import 'package:MatchIn/features/profile/domain/entities/career_preference_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/save_career_preferences_params.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_career_preferences_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/save_career_preferences_use_case.dart';
import 'package:MatchIn/features/profile/presentation/cubits/career_cubit/career_preferences_cubit.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/career_preferences_form.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/preference_dropdown_field.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/preference_options_sheet.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// Small-dataset geography used by these tests.
///
/// Widget tests load bundled dataset files through the test asset
/// bundle, where large single files can stall. Malta's state file is
/// small and Attard has a single city, so flows stay fast and
/// deterministic while exercising the real dataset.
const _country = 'Malta';
const _state = 'Attard';
const _city = 'Attard';

class FakeLocationCareerRepository extends Fake implements ProfileRepository {
  SaveCareerPreferencesParams? lastParams;

  @override
  Future<Either<Failure, CareerPreferenceEntity>> saveCareerPreferences(
    SaveCareerPreferencesParams params,
  ) async {
    lastParams = params;
    return const Right(
      CareerPreferenceEntity(id: 1, preferredCountry: _country),
    );
  }
}

const _prefs = CareerPreferenceEntity(
  id: 1,
  preferredCountry: 'Egypt',
  preferredCity: 'Cairo',
);

Future<void> _pumpForm(
  WidgetTester tester,
  FakeLocationCareerRepository repo,
) async {
  getIt.registerLazySingleton<LocationCatalog>(() => const LocationCatalog());
  addTearDown(getIt.reset);

  final cubit = CareerPreferencesCubit(
    getCareerPreferencesUseCase: GetCareerPreferencesUseCase(repository: repo),
    saveCareerPreferencesUseCase: SaveCareerPreferencesUseCase(
      repository: repo,
    ),
  );
  addTearDown(cubit.close);

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
          body: SingleChildScrollView(
            child: BlocProvider.value(
              value: cubit,
              child: const CareerPreferencesForm(preferences: _prefs),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _fieldTapTarget(String label) => find.descendant(
  of: find.ancestor(
    of: find.text(label),
    matching: find.byType(PreferenceDropdownField),
  ),
  matching: find.byType(InkWell),
);

/// The open options sheet's list.
Finder _sheetList() => find.descendant(
  of: find.byType(PreferenceOptionsSheet),
  matching: find.byType(ListView),
);

/// Scrolls [scrollableList] until [item] is mounted, then ensures it is
/// visible. Sheet rows virtualize, so the item may not exist yet.
/// Searches toward the list start first and then toward the end.
Future<void> _scrollSheetTo(
  WidgetTester tester,
  Finder scrollableList,
  Finder item,
) async {
  for (var i = 0; i < 50 && item.evaluate().isEmpty; i++) {
    await tester.drag(scrollableList, const Offset(0, 400));
    await tester.pumpAndSettle();
  }
  for (var i = 0; i < 50 && item.evaluate().isEmpty; i++) {
    await tester.drag(scrollableList, const Offset(0, -400));
    await tester.pumpAndSettle();
  }
  await tester.ensureVisible(item);
  await tester.pumpAndSettle();
}

Future<void> _pickOption(
  WidgetTester tester,
  String fieldLabel,
  String option,
) async {
  final field = _fieldTapTarget(fieldLabel);
  await tester.ensureVisible(field);
  await tester.pumpAndSettle();
  await tester.tap(field);
  await tester.pumpAndSettle();
  // The sheet opens after pending dataset loads finish; wait for it
  // instead of assuming a single pumpAndSettle is enough.
  for (
    var i = 0;
    i < 20 && find.byType(PreferenceOptionsSheet).evaluate().isEmpty;
    i++
  ) {
    await tester.pump(const Duration(milliseconds: 200));
  }
  final item = find.descendant(
    of: find.byType(PreferenceOptionsSheet),
    matching: find.text(option),
  );
  await _scrollSheetTo(tester, _sheetList(), item);
  await tester.tap(item);
  await tester.pumpAndSettle();
}

void main() {
  group('CareerPreferencesForm preferred location', () {
    testWidgets('sends changed country and city without state', (tester) async {
      final repo = FakeLocationCareerRepository();
      await _pumpForm(tester, repo);

      await _pickOption(tester, 'Country', _country);
      await _pickOption(tester, 'State / Governorate', _state);
      await _pickOption(tester, 'City', _city);

      final saveButton = find.widgetWithText(FilledButton, 'Save Preferences');
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      final params = repo.lastParams;
      if (params == null) fail('expected saved params');
      expect(params.preferredCountry as String?, _country);
      expect(params.preferredCity as String?, _city);
      expect(
        SaveCareerPreferencesParams.isSet(params.preferredCountry),
        isTrue,
      );
      expect(SaveCareerPreferencesParams.isSet(params.preferredCity), isTrue);
    });

    testWidgets('initializes from saved preferences', (tester) async {
      final repo = FakeLocationCareerRepository();
      await _pumpForm(tester, repo);

      expect(find.text('Egypt'), findsOneWidget);
      // City plus the state filter resolved from it (Cairo/Cairo).
      expect(find.text('Cairo'), findsNWidgets(2));
    });
  });
}
