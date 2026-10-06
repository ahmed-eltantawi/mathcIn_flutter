import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/career_preferences_widgets/preferences_row.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CareerPreferencesProfileCard extends StatelessWidget {
  const CareerPreferencesProfileCard({
    super.key,
    this.targetRole,
    this.jobType,
    this.workMode,
    this.preferredLocation,
    this.experienceLevel,
    this.onEdit,
  });

  final String? targetRole;
  final String? jobType;
  final String? workMode;
  final String? preferredLocation;
  final String? experienceLevel;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  s.careerPreferences,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                ),
              ),
              if (onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  tooltip: s.edit,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 20.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          Divider(
            height: 1,
            color: colorScheme.outlineVariant,
          ),
          SizedBox(height: 16.h),
          PreferenceRow(
            label: s.targetRole,
            value: targetRole,
          ),
          SizedBox(height: 12.h),
          PreferenceRow(label: s.jobType, value: jobType),
          SizedBox(height: 12.h),
          PreferenceRow(label: s.workMode, value: workMode),
          SizedBox(height: 12.h),
          PreferenceRow(
            label: s.preferredLocation,
            value: preferredLocation,
          ),
          SizedBox(height: 12.h),
          PreferenceRow(
            label: s.experienceLevel,
            value: experienceLevel,
          ),
        ],
      ),
    );
  }
}
