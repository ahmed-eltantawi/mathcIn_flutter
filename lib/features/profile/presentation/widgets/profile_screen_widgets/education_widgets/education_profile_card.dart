import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/education_widgets/education_profile_item.dart';
import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/education_widgets/education_profile_item_data.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EducationProfileCard extends StatelessWidget {
  const EducationProfileCard({
    required this.educations,
    required this.onEdit,
    super.key,
  });

  final List<EducationProfileItemData> educations;
  final VoidCallback onEdit;

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
              Icon(Icons.school_outlined, size: 24.r, color: colors.primary),

              SizedBox(width: 10.w),

              Expanded(
                child: Text(
                  locale.education,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ),

              // Completion/quality data is not confirmed
              // by the backend yet.
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

          if (educations.isNotEmpty) ...[
            SizedBox(height: 14.h),

            for (int index = 0; index < educations.length; index++) ...[
              EducationProfileItem(
                degree: educations[index].degree,
                institution: educations[index].institution,
                startDate: educations[index].startDate,
                endDate: educations[index].endDate,
                grade: educations[index].grade,
              ),

              if (index != educations.length - 1) ...[
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
