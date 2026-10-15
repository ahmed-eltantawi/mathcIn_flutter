import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/military_status_options.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Future<S> _loadLocale(WidgetTester tester, Locale locale) async {
  late S captured;
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: Builder(
        builder: (context) {
          captured = S.of(context);
          return const SizedBox();
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return captured;
}

void main() {
  group('MilitaryStatusOptions machine values', () {
    test('uses confirmed values that stay untranslated', () {
      expect(MilitaryStatusOptions.submittableValues, {
        'completed',
        'exempted',
        'postponed',
      });
    });

    test('never submits the unconfirmed fourth value', () {
      expect(
        MilitaryStatusOptions.submittableValues,
        isNot(contains(MilitaryStatusOptions.finalExemptionPlaceholder)),
      );
      expect(
        MilitaryStatusOptions.disabledValues,
        contains(MilitaryStatusOptions.finalExemptionPlaceholder),
      );
    });
  });

  group('MilitaryStatusOptions labels', () {
    testWidgets('shows English labels with English machine keys', (
      tester,
    ) async {
      final locale = await _loadLocale(tester, const Locale('en'));
      final items = MilitaryStatusOptions.items(locale);

      expect(items.keys, [
        'completed',
        'exempted',
        'postponed',
        MilitaryStatusOptions.finalExemptionPlaceholder,
      ]);
      expect(items['completed'], 'Completed');
      expect(items['exempted'], 'Exempted');
      expect(items['postponed'], 'Postponed');
      expect(
        items[MilitaryStatusOptions.finalExemptionPlaceholder],
        'Final Exemption',
      );
    });

    testWidgets('shows Arabic labels with English machine keys', (
      tester,
    ) async {
      final locale = await _loadLocale(tester, const Locale('ar'));
      final items = MilitaryStatusOptions.items(locale);

      expect(items.keys, [
        'completed',
        'exempted',
        'postponed',
        MilitaryStatusOptions.finalExemptionPlaceholder,
      ]);
      expect(items['completed'], 'أدى الخدمة');
      expect(items['exempted'], 'معفى');
      expect(items['postponed'], 'مؤجل');
      expect(
        items[MilitaryStatusOptions.finalExemptionPlaceholder],
        'إعفاء نهائي',
      );
    });

    testWidgets('preserves unknown existing backend values', (tester) async {
      final locale = await _loadLocale(tester, const Locale('en'));

      expect(MilitaryStatusOptions.labelOf(locale, 'deferred'), 'deferred');
      expect(MilitaryStatusOptions.labelOf(locale, 'completed'), 'Completed');
    });
  });
}
