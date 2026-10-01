import 'package:MatchIn/features/profile/presentation/widgets/edit_projects_widgets/project_skill_chip.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TechnologiesField extends StatelessWidget {
  const TechnologiesField({
    required this.skills,
    required this.onAdd,
    required this.onRemove,
    this.controller,
    super.key,
  });

  final List<String> skills;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final locale = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locale.technologiesSkills,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: locale.technologiesHint,
                  filled: true,
                  fillColor: colors.surface,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      10.r,
                    ),
                    borderSide: BorderSide(
                      color: theme.dividerColor,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      8.r,
                    ),
                    borderSide: BorderSide(
                      color: colors.primary,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            SizedBox(
              height: 48.h,
              child: OutlinedButton.icon(
                onPressed: onAdd,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      8.r,
                    ),
                  ),
                ),
                icon: Icon(Icons.add_rounded, size: 18.r),
                label: Text(locale.add),
              ),
            ),
          ],
        ),
        if (skills.isNotEmpty) ...[
          SizedBox(height: 10.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 7.h,
            children: skills
                .map(
                  (skill) => ProjectSkillChip(
                    label: skill,
                    onRemove: () => onRemove(skill),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}
