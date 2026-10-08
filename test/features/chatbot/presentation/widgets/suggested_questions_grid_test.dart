import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:MatchIn/features/chatbot/presentation/widgets/suggested_questions_grid.dart';
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
  group('SuggestedQuestionsGrid Widget Tests', () {
    testWidgets('renders all 4 question cards and selecting one triggers callback', (
      tester,
    ) async {
      String selectedPrompt = '';

      await tester.pumpWidget(
        _wrapWithScreenUtilAndLocalization(
          SuggestedQuestionsGrid(
            onSelectQuestion: (prompt) => selectedPrompt = prompt,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the 4 cards are rendered by checking the icons
      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
      expect(find.byIcon(Icons.psychology_outlined), findsOneWidget);
      expect(find.byIcon(Icons.trending_up_rounded), findsOneWidget);
      expect(find.byIcon(Icons.insights_rounded), findsOneWidget);

      // Tap the first card
      await tester.tap(find.byIcon(Icons.description_outlined));
      await tester.pumpAndSettle();

      expect(selectedPrompt, isNotEmpty);
      expect(selectedPrompt.toLowerCase(), contains('cv'));
    });
  });
}
