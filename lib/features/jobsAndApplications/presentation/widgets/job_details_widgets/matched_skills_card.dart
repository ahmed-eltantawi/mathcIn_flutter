import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class MatchedSkillsCard extends StatelessWidget {
  const MatchedSkillsCard({
    super.key,
    required this.skills,
  });

  final List<String> skills;

  @override
  Widget build(BuildContext context) {
    final s = context.l10n;
    final theme = context.theme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: context.semanticColors.success,
                ),
                Gap(7.w),
                Expanded(
                  child: Text(
                    s.whatYouAlreadyMatch,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                _SourceChip(label: s.fromYourCv),
              ],
            ),
            Gap(8.h),
            ...List.generate(skills.length, (index) {
              return _MatchedSkill(
                title: skills[index],
                showDivider: index != skills.length - 1,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _MatchedSkill extends StatelessWidget {
  const _MatchedSkill({
    required this.title,
    required this.showDivider,
  });

  final String title;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_rounded,
                color: context.semanticColors.success,
                size: 19.sp,
              ),
              Gap(10.w),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: 28.w,
            ),
            child: const Divider(height: 1),
          ),
      ],
    );
  }
}

class _SourceChip extends StatelessWidget {
  const _SourceChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 5.h,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Text(label, style: theme.textTheme.bodySmall),
    );
  }
}
