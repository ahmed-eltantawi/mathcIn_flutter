import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/profile/data/data_sources/location/location_catalog.dart';
import 'package:MatchIn/features/profile/domain/entities/add_experience_params.dart';
import 'package:MatchIn/features/profile/domain/entities/update_experience_params.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_experience_widgets/experience_form.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
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

Future<void> _pumpForm(
  WidgetTester tester, {
  required void Function(AddExperienceParams) onAdd,
  required void Function(UpdateExperienceParams) onUpdate,
}) async {
  getIt.registerLazySingleton<LocationCatalog>(() => const LocationCatalog());
  addTearDown(getIt.reset);

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
            child: ExperienceForm(
              onAdd: onAdd,
              onUpdate: onUpdate,
              onCancel: () {},
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _dropdowns() => find.byType(DropdownButtonFormField<String>);

/// The open dropdown menu list.
Finder _menuList() => find.byType(ListView);

/// Scrolls [scrollableList] until [item] is mounted, then ensures it is
/// visible. Dropdown menus virtualize rows and open scrolled at the
/// current selection, so the search runs toward the list start first
/// and then toward the end.
Future<void> _scrollMenuTo(
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

Future<void> _selectFromDropdown(
  WidgetTester tester,
  Finder dropdown,
  String option,
) async {
  await tester.ensureVisible(dropdown);
  await tester.pumpAndSettle();
  // The dropdown enables once dataset options arrive; retry the tap
  // instead of assuming a single pumpAndSettle is enough.
  for (var i = 0; i < 20 && find.byType(ListView).evaluate().isEmpty; i++) {
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    if (find.byType(ListView).evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }
  final item = find.descendant(of: _menuList(), matching: find.text(option));
  await _scrollMenuTo(tester, _menuList(), item);
  await tester.tap(item);
  await tester.pumpAndSettle();
}

Future<void> _fillRequiredFields(WidgetTester tester) async {
  final jobTitle = find.widgetWithText(
    TextFormField,
    'e.g. Lead Product Designer',
  );
  await tester.ensureVisible(jobTitle);
  await tester.pumpAndSettle();
  await tester.enterText(jobTitle, 'Backend Developer');
  final company = find.widgetWithText(TextFormField, 'e.g. Studio Craft Ltd.');
  await tester.ensureVisible(company);
  await tester.pumpAndSettle();
  await tester.enterText(company, 'NileTech');
  await tester.pumpAndSettle();
}

void main() {
  group('ExperienceForm location', () {
    testWidgets('add flow saves country and city mapping', (tester) async {
      AddExperienceParams? saved;
      await _pumpForm(
        tester,
        onAdd: (params) => saved = params,
        onUpdate: (_) {},
      );

      await _fillRequiredFields(tester);

      final fields = _dropdowns();
      expect(fields, findsNWidgets(5));

      // Country is the third dropdown (after employment type + work mode).
      await _selectFromDropdown(tester, fields.at(2), _country);
      // State filter, then a city of that state.
      await _selectFromDropdown(tester, fields.at(3), _state);
      await _selectFromDropdown(tester, fields.at(4), _city);

      final saveButton = find.widgetWithText(FilledButton, 'Save experience');
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(saved, isNotNull);
      expect(saved!.country, _country);
      expect(saved!.city, _city);
    });

    testWidgets('changing country clears state and city', (tester) async {
      await _pumpForm(tester, onAdd: (_) {}, onUpdate: (_) {});

      final fields = _dropdowns();
      await _selectFromDropdown(tester, fields.at(2), _country);
      await _selectFromDropdown(tester, fields.at(3), _state);
      await _selectFromDropdown(tester, fields.at(4), _city);

      // Switching country drops the stale state/city selection.
      await _selectFromDropdown(tester, fields.at(2), 'Egypt');

      expect(find.text(_city), findsNothing);
    });
  });
}
