import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_projects_widgets/ongoing_project_checkbox.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_projects_widgets/project_date_fields.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_projects_widgets/project_text_field.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_projects_widgets/technologies_field.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddProjectDetailsCard extends StatelessWidget {
  const AddProjectDetailsCard({super.key});

  static const List<String> _mockTechnologies = [
    'Flutter',
    'Node.js',
    'PostgreSQL',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final locale = S.of(context);

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
            children: [
              Expanded(
                child: Text(
                  locale.addProjectDetails,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: Text(
                  locale.draft,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),
          Divider(
            height: 1,
            color: context.theme.dividerColor,
          ),
          SizedBox(height: 16.h),

          ProjectTextField(
            label: locale.projectName,
            hint: locale.projectNameHint,
          ),

          SizedBox(height: 16.h),

          ProjectTextField(
            label: locale.description,
            hint: locale.projectDescriptionHint,
            maxLines: 4,
          ),

          SizedBox(height: 6.h),

          Text(
            locale.projectDescriptionHelper,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),

          SizedBox(height: 16.h),

          TechnologiesField(
            skills: _mockTechnologies,
            onAdd: () {},
            onRemove: (_) {},
          ),

          SizedBox(height: 16.h),

          ProjectTextField(
            label: locale.projectUrl,
            trailingLabel: locale.optional,
            hint: 'https://myproject.live',
            prefixIcon: Icons.link_rounded,
            keyboardType: TextInputType.url,
          ),

          SizedBox(height: 16.h),

          ProjectTextField(
            label: locale.githubRepositoryUrl,
            trailingLabel: locale.optional,
            hint: 'https://github.com/username/project',
            prefixIcon: Icons.code_rounded,
            keyboardType: TextInputType.url,
          ),

          SizedBox(height: 16.h),

          const ProjectDateFields(),

          SizedBox(height: 16.h),

          OngoingProjectCheckbox(
            value: false,
            onChanged: (_) {
              // UI only.
            },
          ),

          SizedBox(height: 16.h),

          ProjectTextField(
            label: locale.keyAchievements,
            hint: locale.keyAchievementsHint,
            maxLines: 3,
          ),

          SizedBox(height: 8.h),

          Text(
            locale.keyAchievementsHelper,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.35,
            ),
          ),

          SizedBox(height: 22.h),

          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: FilledButton(
              onPressed: () {
                // UI only.
              },
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                locale.saveProject,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(height: 10.h),

          Center(
            child: TextButton(
              onPressed: () {},
              child: Text(locale.cancel),
            ),
          ),
        ],
      ),
    );
  }
}
