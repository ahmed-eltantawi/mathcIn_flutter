import 'package:MatchIn/features/profile/presentation/widgets/edit_education_widgets/education_form.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_education_widgets/education_form_field.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Finder _dateField(String label) => find.descendant(
  of: find.ancestor(
    of: find.text(label),
    matching: find.byType(EducationFormField),
  ),
  matching: find.byType(TextFormField),
);

void main() {
  group('EducationForm date alignment', () {
    testWidgets('start and end inputs share a vertical position', (
      tester,
    ) async {
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
                child: EducationForm(
                  onAdd: (_) {},
                  onUpdate: (_) {},
                  onCancel: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final startTop = tester.getTopLeft(_dateField('Start year')).dy;
      final endTop = tester.getTopLeft(_dateField('End year (or expected)')).dy;

      expect(startTop, moreOrLessEquals(endTop, epsilon: 0.5));
    });
  });
}
