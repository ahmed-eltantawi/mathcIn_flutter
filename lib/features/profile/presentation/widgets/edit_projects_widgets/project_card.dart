import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_projects_widgets/project_skill_chip.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    required this.title,
    required this.date,
    required this.description,
    required this.skills,
    this.projectUrl,
    this.githubUrl,
    this.onEdit,
    this.onDelete,
    this.onProjectPressed,
    this.onGithubPressed,
    super.key,
  });

  final String title;
  final String date;
  final String description;
  final List<String> skills;

  final String? projectUrl;
  final String? githubUrl;

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onProjectPressed;
  final VoidCallback? onGithubPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final locale = S.of(context);

    final hasLinks =
        projectUrl != null || githubUrl != null;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: context.theme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      date,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              _ProjectIconButton(
                icon: Icons.edit_outlined,
                onPressed: onEdit,
              ),
              SizedBox(width: 4.w),
              _ProjectIconButton(
                icon: Icons.delete_outline_rounded,
                onPressed: onDelete,
              ),
            ],
          ),

          SizedBox(height: 14.h),

          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.45,
            ),
          ),

          SizedBox(height: 12.h),

          Wrap(
            spacing: 6.w,
            runSpacing: 7.h,
            children: skills
                .map(
                  (skill) => ProjectSkillChip(label: skill),
                )
                .toList(),
          ),

          if (hasLinks) ...[
            SizedBox(height: 14.h),

            Divider(
              height: 1,
              color: context.theme.dividerColor,
            ),

            SizedBox(height: 10.h),

            Wrap(
              spacing: 20.w,
              runSpacing: 8.h,
              children: [
                if (projectUrl != null)
                  _ProjectLink(
                    icon: Icons.open_in_new_rounded,
                    label: locale.viewLiveProject,
                    onPressed: onProjectPressed,
                  ),
                if (githubUrl != null)
                  _ProjectLink(
                    icon: Icons.code_rounded,
                    label: locale.viewGithubRepository,
                    onPressed: onGithubPressed,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ProjectIconButton extends StatelessWidget {
  const _ProjectIconButton({
    required this.icon,
    this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.all(6.r),
      constraints: const BoxConstraints(),
      icon: Icon(icon, size: 20.r),
    );
  }
}

class _ProjectLink extends StatelessWidget {
  const _ProjectLink({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.r, color: colors.secondary),
            SizedBox(width: 5.w),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
