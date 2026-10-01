import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_skills_widgets/skill_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/generated/l10n.dart';

class CvSkillsCard extends StatelessWidget {
  const CvSkillsCard({
    required this.skills,
    required this.onRemoveSkill,
    super.key,
  });

  final List<String> skills;
  final ValueChanged<String> onRemoveSkill;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final S locale = S.of(context);

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: context.theme.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 24.r,
                color: colors.primary,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  locale.fromYourCv,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 5.h,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: colors.outlineVariant,
                  ),
                ),
                child: Text(
                  'CV',
                  style: theme.textTheme.labelMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Divider(
            height: 1,
            color: context.theme.dividerColor,
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: skills
                .map(
                  (skill) => SkillChip(
                    label: skill,
                    onRemove: () => onRemoveSkill(skill),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 18.h),
          Text(
            locale.cvSkillsDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
