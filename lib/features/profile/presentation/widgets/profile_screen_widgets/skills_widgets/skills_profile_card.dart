import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/skills_widgets/profile_skill_chip.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SkillsProfileCard extends StatelessWidget {
  const SkillsProfileCard({
    required this.skills,
    required this.onEdit,
    this.onAddSkill,
    super.key,
  });

  final List<String> skills;
  final VoidCallback onEdit;
  final VoidCallback? onAddSkill;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final locale = S.of(context);

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.theme.dividerColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.handyman_outlined, size: 24.r, color: colors.primary),

              SizedBox(width: 10.w),

              Expanded(
                child: Text(
                  locale.skills,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ),

              IconButton(
                onPressed: onEdit,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.all(6.r),
                constraints: const BoxConstraints(),
                icon: Icon(
                  Icons.edit_outlined,
                  size: 20.r,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          Divider(height: 1, color: context.theme.dividerColor),

          SizedBox(height: 12.h),

          Row(
            children: [
              Expanded(
                child: Text(
                  locale.fromYourCv,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),

              if (onAddSkill != null)
                TextButton.icon(
                  onPressed: onAddSkill,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                  icon: Icon(Icons.add_rounded, size: 17.r),
                  label: Text(
                    locale.addNewSkill,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          if (skills.isNotEmpty) ...[
            SizedBox(height: 8.h),

            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: skills
                  .map((skill) => ProfileSkillChip(label: skill))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
