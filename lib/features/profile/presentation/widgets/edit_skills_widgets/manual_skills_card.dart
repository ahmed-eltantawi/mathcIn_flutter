import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_skills_widgets/skill_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/generated/l10n.dart';

class ManualSkillsCard extends StatelessWidget {
  const ManualSkillsCard({
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
                Icons.edit_note_rounded,
                size: 26.r,
                color: colors.primary,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  locale.addedManually,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              Text(
                locale.skillsCount(skills.length),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
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
        ],
      ),
    );
  }
}
