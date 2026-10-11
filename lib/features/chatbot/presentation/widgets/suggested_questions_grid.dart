import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/generated/l10n.dart';

class _SuggestedQuestionItem {
  const _SuggestedQuestionItem({
    required this.icon,
    required this.titleBuilder,
    required this.promptBuilder,
  });

  final IconData icon;
  final String Function(S l10n) titleBuilder;
  final String Function(S l10n) promptBuilder;
}

class SuggestedQuestionsGrid extends StatelessWidget {
  const SuggestedQuestionsGrid({
    super.key,
    required this.onSelectQuestion,
  });

  final ValueChanged<String> onSelectQuestion;

  static const List<_SuggestedQuestionItem> _items = [
    _SuggestedQuestionItem(
      icon: Icons.description_outlined,
      titleBuilder: _getResumeOptimizationTitle,
      promptBuilder: _getResumeOptimizationPrompt,
    ),
    _SuggestedQuestionItem(
      icon: Icons.psychology_outlined,
      titleBuilder: _getInterviewPrepTitle,
      promptBuilder: _getInterviewPrepPrompt,
    ),
    _SuggestedQuestionItem(
      icon: Icons.trending_up_rounded,
      titleBuilder: _getCareerGrowthTitle,
      promptBuilder: _getCareerGrowthPrompt,
    ),
    _SuggestedQuestionItem(
      icon: Icons.insights_rounded,
      titleBuilder: _getJobFitAnalysisTitle,
      promptBuilder: _getJobFitAnalysisPrompt,
    ),
  ];

  static String _getResumeOptimizationTitle(S s) => s.resumeOptimization;
  static String _getResumeOptimizationPrompt(S s) => s.resumeOptimizationPrompt;
  static String _getInterviewPrepTitle(S s) => s.interviewPrep;
  static String _getInterviewPrepPrompt(S s) => s.interviewPrepPrompt;
  static String _getCareerGrowthTitle(S s) => s.careerGrowth;
  static String _getCareerGrowthPrompt(S s) => s.careerGrowthPrompt;
  static String _getJobFitAnalysisTitle(S s) => s.jobFitAnalysis;
  static String _getJobFitAnalysisPrompt(S s) => s.jobFitAnalysisPrompt;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Text(
            l10n.suggestedQuestions,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onSurfaceVariant,
              letterSpacing: 0.2,
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
            childAspectRatio: 1.35,
          ),
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final item = _items[index];
            return _SuggestedQuestionCard(
              item: item,
              onTap: () => onSelectQuestion(item.promptBuilder(l10n)),
            );
          },
        ),
      ],
    );
  }
}

class _SuggestedQuestionCard extends StatefulWidget {
  const _SuggestedQuestionCard({
    required this.item,
    required this.onTap,
  });

  final _SuggestedQuestionItem item;
  final VoidCallback onTap;

  @override
  State<_SuggestedQuestionCard> createState() => _SuggestedQuestionCardState();
}

class _SuggestedQuestionCardState extends State<_SuggestedQuestionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () {
        if (_isPressed) {
          setState(() => _isPressed = false);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: isDark
                ? colors.surfaceContainerHighest.withValues(alpha: 0.4)
                : colors.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: colors.outlineVariant.withValues(
                alpha: isDark ? 0.35 : 0.5,
              ),
              width: 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(
                  alpha: isDark ? 0.15 : 0.04,
                ),
                blurRadius: 8.r,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  widget.item.icon,
                  size: 19.r,
                  color: colors.primary,
                ),
              ),
              Text(
                widget.item.titleBuilder(l10n),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                  fontSize: 13.sp,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
