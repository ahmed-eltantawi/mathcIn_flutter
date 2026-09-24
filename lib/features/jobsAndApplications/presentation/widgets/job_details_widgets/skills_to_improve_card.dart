import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SkillsToImproveCard extends StatelessWidget {
  const SkillsToImproveCard({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.trending_up_rounded,
                  color: AppColors.goldenMustard,
                ),
                SizedBox(width: 7.w),
                Text(
                  s.skillsToImprove,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            _ImprovementSkill(
              title: 'Testing',
              subtitle: s.requiredForThisRole,
              priority: s.highPriority,
              isHighPriority: true,
            ),
            SizedBox(height: 10.h),
            _ImprovementSkill(
              title: 'CI/CD',
              subtitle: s.mentionedInJobRequirements,
              priority: s.highPriority,
              isHighPriority: true,
            ),
            SizedBox(height: 10.h),
            _ImprovementSkill(
              title: 'Firebase',
              subtitle: s.helpfulAdvantage,
              priority: s.niceToHave,
              isHighPriority: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _ImprovementSkill extends StatelessWidget {
  const _ImprovementSkill({
    required this.title,
    required this.subtitle,
    required this.priority,
    required this.isHighPriority,
  });

  final String title;
  final String subtitle;
  final String priority;
  final bool isHighPriority;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 9.r,
            height: 9.r,
            decoration: BoxDecoration(
              color: isHighPriority
                  ? AppColors.goldenMustard
                  : AppColors.goldenMustard.withValues(
                      alpha: 0.6,
                    ),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 9.w,
              vertical: 5.h,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: isHighPriority
                    ? AppColors.amber.withValues(alpha: 0.5)
                    : theme.dividerColor,
              ),
              borderRadius: BorderRadius.circular(5.r),
            ),
            child: Text(
              priority,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isHighPriority
                    ? AppColors.amber
                    : theme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
