import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/edit_profile_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpDropdown(
  WidgetTester tester, {
  required ValueChanged<String?> onChanged,
}) async {
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 845),
      builder: (_, _) => MaterialApp(
        home: Scaffold(
          body: EditProfileDropdown(
            label: 'Military Status',
            value: null,
            items: const {
              'completed': 'Completed',
              'final_exemption_unconfirmed': 'Final Exemption',
            },
            disabledValues: const {'final_exemption_unconfirmed'},
            onChanged: onChanged,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('EditProfileDropdown disabledValues', () {
    testWidgets('disabled option cannot be submitted', (tester) async {
      String? selected;
      await _pumpDropdown(tester, onChanged: (value) => selected = value);

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Final Exemption').last);
      await tester.pumpAndSettle();
      expect(selected, isNull);

      await tester.tap(find.text('Completed').last);
      await tester.pumpAndSettle();
      expect(selected, 'completed');
    });
  });
}
