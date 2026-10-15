import 'package:MatchIn/features/profile/domain/entities/candidate_project_entity.dart';
import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/skills_widgets/profile_skill_chip.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileProjectItem extends StatelessWidget {
  const ProfileProjectItem({
    required this.project,
    this.onProjectPressed,
    super.key,
  });

  final CandidateProjectEntity project;
  final VoidCallback? onProjectPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final locale = S.of(context);

    final description = project.description?.trim() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          project.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),

        if (description.isNotEmpty) ...[
          SizedBox(height: 6.h),

          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],

        if (project.technologies.isNotEmpty) ...[
          SizedBox(height: 12.h),

          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: project.technologies
                .map((technology) => ProfileSkillChip(label: technology))
                .toList(),
          ),
        ],

        if (project.projectUrl != null &&
            project.projectUrl!.trim().isNotEmpty) ...[
          SizedBox(height: 14.h),

          TextButton.icon(
            onPressed: onProjectPressed,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
            label: Text(
              locale.viewLiveProject,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            iconAlignment: IconAlignment.end,
            icon: Icon(Icons.arrow_forward_rounded, size: 17.r),
          ),
        ],
      ],
    );
  }
}
