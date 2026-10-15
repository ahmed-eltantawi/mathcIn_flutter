import 'dart:typed_data';

import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/avatar_preview_dialog.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/avatar_source_sheet.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

Future<void> _pumpApp(
  WidgetTester tester,
  Widget Function(BuildContext context) open,
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
        home: Scaffold(body: Builder(builder: (context) => open(context))),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('AvatarSourceSheet', () {
    testWidgets('camera selection returns ImageSource.camera', (tester) async {
      ImageSource? result;
      await _pumpApp(
        tester,
        (context) => ElevatedButton(
          onPressed: () async {
            result = await AvatarSourceSheet.show(context);
          },
          child: const Text('open'),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Take Photo'));
      await tester.pumpAndSettle();

      expect(result, ImageSource.camera);
    });

    testWidgets('gallery selection returns ImageSource.gallery', (
      tester,
    ) async {
      ImageSource? result;
      await _pumpApp(
        tester,
        (context) => ElevatedButton(
          onPressed: () async {
            result = await AvatarSourceSheet.show(context);
          },
          child: const Text('open'),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose from Gallery'));
      await tester.pumpAndSettle();

      expect(result, ImageSource.gallery);
    });

    testWidgets('cancel returns null', (tester) async {
      ImageSource? result = ImageSource.camera;
      await _pumpApp(
        tester,
        (context) => ElevatedButton(
          onPressed: () async {
            result = await AvatarSourceSheet.show(context);
          },
          child: const Text('open'),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });
  });

  group('AvatarPreviewDialog', () {
    final bytes = Uint8List.fromList(List.filled(100, 7));

    Future<AvatarPreviewAction?> showPreview(BuildContext context) {
      return AvatarPreviewDialog.show(
        context,
        bytes: bytes,
        fileName: 'photo.jpg',
      );
    }

    testWidgets('renders the staged image without claiming save', (
      tester,
    ) async {
      await _pumpApp(
        tester,
        (context) => ElevatedButton(
          onPressed: () => showPreview(context),
          child: const Text('open'),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Preview Photo'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('Avatar upload is not available yet.'), findsOneWidget);
    });

    testWidgets('confirm, retake, and cancel return distinct actions', (
      tester,
    ) async {
      AvatarPreviewAction? result;
      await _pumpApp(
        tester,
        (context) => ElevatedButton(
          onPressed: () async {
            result = await showPreview(context);
          },
          child: const Text('open'),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();
      expect(result, AvatarPreviewAction.confirm);

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose Another'));
      await tester.pumpAndSettle();
      expect(result, AvatarPreviewAction.retake);

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(result, AvatarPreviewAction.cancel);
    });
  });
}
