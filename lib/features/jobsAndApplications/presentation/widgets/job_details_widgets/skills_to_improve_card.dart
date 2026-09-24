import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class SkillsToImproveCard extends StatelessWidget {
  const SkillsToImproveCard({
    super.key,
    required this.skills,
  });

  final List<String> skills;

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
                Icon(
                  Icons.trending_up_rounded,
                  color: theme.colorScheme.tertiary,
                ),
                Gap(7.w),
                Text(
                  s.skillsToImprove,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            Gap(14.h),
            ...List.generate(skills.length, (index) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == skills.length - 1
                      ? 0
                      : 10.h,
                ),
                child: _ImprovementSkill(
                  title: skills[index],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ImprovementSkill extends StatelessWidget {
  const _ImprovementSkill({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
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
              color: theme.colorScheme.tertiary,
              shape: BoxShape.circle,
            ),
          ),
          Gap(10.w),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
