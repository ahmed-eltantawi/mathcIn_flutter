import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:MatchIn/features/chatbot/presentation/widgets/ai_chat_composer.dart';
import 'package:MatchIn/generated/l10n.dart';

Widget _wrapWithScreenUtilAndLocalization(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (context, _) => MaterialApp(
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('AiChatComposer Widget Tests', () {
    testWidgets('renders input field with localized hint', (tester) async {
      await tester.pumpWidget(
        _wrapWithScreenUtilAndLocalization(
          AiChatComposer(
            isGenerating: false,
            onSendMessage: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
    });

    testWidgets('typing text and tapping send triggers onSendMessage', (
      tester,
    ) async {
      String sentMessage = '';
      await tester.pumpWidget(
        _wrapWithScreenUtilAndLocalization(
          AiChatComposer(
            isGenerating: false,
            onSendMessage: (msg) => sentMessage = msg,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially empty -> send button tap does nothing
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      await tester.pump();
      expect(sentMessage, isEmpty);

      // Enter text
      await tester.enterText(
        find.byType(TextField),
        'How do I prepare for an interview?',
      );
      await tester.pump();

      // Tap send button
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      await tester.pump();

      expect(sentMessage, 'How do I prepare for an interview?');
      // Field should be cleared after send
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('shows loading indicator when isGenerating is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithScreenUtilAndLocalization(
          AiChatComposer(
            isGenerating: true,
            onSendMessage: (_) {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward_rounded), findsNothing);
    });
    testWidgets('TextField is borderless and transparent inside composer', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithScreenUtilAndLocalization(
          AiChatComposer(
            isGenerating: false,
            onSendMessage: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      final decoration = textField.decoration;
      expect(decoration?.border, InputBorder.none);
      expect(decoration?.enabledBorder, InputBorder.none);
      expect(decoration?.focusedBorder, InputBorder.none);
      expect(decoration?.disabledBorder, InputBorder.none);
      expect(decoration?.errorBorder, InputBorder.none);
      expect(decoration?.focusedErrorBorder, InputBorder.none);
      expect(decoration?.filled, isFalse);
    });
  });
}
