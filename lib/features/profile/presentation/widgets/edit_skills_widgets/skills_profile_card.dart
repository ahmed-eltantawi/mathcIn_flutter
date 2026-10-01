import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_skills_widgets/profile_match_quality_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/generated/l10n.dart';

class SkillsProfileCard extends StatelessWidget {
  const SkillsProfileCard({super.key});

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52.r,
                height: 52.r,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.psychology_alt_outlined,
                  size: 28.r,
                  color: colors.primary,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      locale.skillsProfile,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      locale.skillsProfileDescription,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(
                            color: colors.onSurfaceVariant,
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Divider(height: 1, color: colors.outlineVariant),
          SizedBox(height: 16.h),
          const ProfileMatchQualityRow(
            quality: ProfileMatchQuality.excellent,
          ),
        ],
      ),
    );
  }
}
