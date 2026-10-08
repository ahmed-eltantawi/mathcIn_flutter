import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'suggested_questions_grid.dart';

class AiChatEmptyState extends StatefulWidget {
  const AiChatEmptyState({
    super.key,
    required this.onSelectQuestion,
  });

  final ValueChanged<String> onSelectQuestion;

  @override
  State<AiChatEmptyState> createState() => _AiChatEmptyStateState();
}

class _AiChatEmptyStateState extends State<AiChatEmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _floatAnimation = CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - value)),
            child: child,
          ),
        );
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Column(
          children: [
            SizedBox(height: 12.h),
            AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -4 * _floatAnimation.value),
                  child: Container(
                    padding: EdgeInsets.all(18.r),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(
                        alpha: isDark ? 0.16 : 0.1,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.primary.withValues(
                          alpha: 0.15 + (0.1 * _floatAnimation.value),
                        ),
                        width: 1.5.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(
                            alpha: 0.12 * _floatAnimation.value,
                          ),
                          blurRadius: 18.r,
                          spreadRadius: 2.r,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      size: 48.r,
                      color: colors.primary,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 18.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                l10n.howCanIHelpYouToday,
                textAlign: TextAlign.center,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 36.w),
              child: Text(
                l10n.aiAssistantSubtitle,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.45,
                  fontSize: 13.5.sp,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            SuggestedQuestionsGrid(
              onSelectQuestion: widget.onSelectQuestion,
            ),
          ],
        ),
      ),
    );
  }
}
