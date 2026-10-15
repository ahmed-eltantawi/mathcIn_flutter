import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/profile_phone_field.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpPhoneField(WidgetTester tester) async {
  final controller = TextEditingController();
  addTearDown(controller.dispose);

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
          body: ProfilePhoneField(
            controller: controller,
            countryCode: '+20',
            countryCodes: const {
              '+20': 'Egypt (+20)',
              '+1': 'United States (+1)',
            },
            onCountryCodeChanged: (_) {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('ProfilePhoneField calling-code display', () {
    testWidgets('closed field shows only the calling code', (tester) async {
      await _pumpPhoneField(tester);

      expect(find.text('+20'), findsOneWidget);
      expect(find.text('Egypt (+20)'), findsNothing);
    });

    testWidgets('selection menu shows country name and code', (tester) async {
      await _pumpPhoneField(tester);

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      expect(find.text('Egypt (+20)'), findsWidgets);
      expect(find.text('United States (+1)'), findsOneWidget);
    });
  });
}
