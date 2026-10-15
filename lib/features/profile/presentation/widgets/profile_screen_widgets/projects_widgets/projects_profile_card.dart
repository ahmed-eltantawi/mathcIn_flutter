import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_project_entity.dart';
import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/projects_widgets/profile_project_item.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProjectsProfileCard extends StatelessWidget {
  const ProjectsProfileCard({
    required this.projects,
    required this.onEdit,
    this.onProjectPressed,
    super.key,
  });

  final List<CandidateProjectEntity> projects;
  final VoidCallback onEdit;
  final ValueChanged<CandidateProjectEntity>? onProjectPressed;

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
              Icon(Icons.folder_outlined, size: 24.r, color: colors.primary),

              SizedBox(width: 10.w),

              Expanded(
                child: Text(
                  locale.projects,
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

          if (projects.isNotEmpty) ...[
            SizedBox(height: 14.h),

            for (int index = 0; index < projects.length; index++) ...[
              ProfileProjectItem(
                project: projects[index],
                onProjectPressed: onProjectPressed == null
                    ? null
                    : () => onProjectPressed!(projects[index]),
              ),

              if (index != projects.length - 1) ...[
                SizedBox(height: 14.h),

                Divider(height: 1, color: context.theme.dividerColor),

                SizedBox(height: 14.h),
              ],
            ],
          ],
        ],
      ),
    );
  }
}
