import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_skills_widgets/profile_match_quality_row.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProjectsProfileCard extends StatelessWidget {
  const ProjectsProfileCard({super.key});

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
              Container(
                width: 42.r,
                height: 42.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.folder_special_outlined,
                  size: 22.r,
                  color: colors.primary,
                ),
              ),
              SizedBox(width: 12.w),

              Expanded(
                child: Text(
                  locale.projects,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),

              SizedBox(width: 8.w),

              const ProfileMatchQualityRow(
                quality:
                    ProfileMatchQuality.needsImprovement,
                compact: true,
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Text(
            locale.projectsImprovementHint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
