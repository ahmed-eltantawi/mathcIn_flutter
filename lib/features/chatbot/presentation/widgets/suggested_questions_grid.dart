import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:MatchIn/features/chatbot/presentation/widgets/suggested_question_card.dart';
import '../../../../generated/l10n.dart';

class SuggestedQuestionsGrid extends StatelessWidget {
  const SuggestedQuestionsGrid({super.key, required this.onSelectQuestion});

  final Function(String) onSelectQuestion;

  static const List<Map<String, String>> _questions = [
    {
      'icon': '📝',
      'title': 'Resume Optimization',
      'prompt': 'How can I optimize my CV for Flutter developer roles?',
    },
    {
      'icon': '🎯',
      'title': 'Interview Prep',
      'prompt': 'What are the top technical interview questions for Dart and Flutter?',
    },
    {
      'icon': '🚀',
      'title': 'Career Growth',
      'prompt': 'What steps should I take to become a Senior Mobile Architect?',
    },
    {
      'icon': '💡',
      'title': 'Job Fit Analysis',
      'prompt': 'How does MatchIn calculate my job match percentage?',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          child: Text(
            s.suggestedQuestions,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
              color: isDark ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10.h,
            crossAxisSpacing: 10.w,
            childAspectRatio: 1.45,
          ),
          itemCount: _questions.length,
          itemBuilder: (context, index) {
            final q = _questions[index];
            return SuggestedQuestionCard(
              icon: q['icon']!,
              title: q['title']!,
              prompt: q['prompt']!,
              onTap: () => onSelectQuestion(q['prompt']!),
            );
          },
        ),
      ],
    );
  }
}
