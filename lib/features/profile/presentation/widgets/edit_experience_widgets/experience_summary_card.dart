import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExperienceSummaryCard extends StatelessWidget {
  const ExperienceSummaryCard({
    super.key,
    this.qualityLabel,
    this.completionPercentage,
  });

  final String? qualityLabel;
  final int? completionPercentage;

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final completion = completionPercentage?.clamp(0, 100);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: theme.dividerColor,
                  ),
                ),
                child: Icon(
                  Icons.work_outline_rounded,
                  size: 22.r,
                  color: colors.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      locale.experience,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      locale.sectionCompleteness,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              if (qualityLabel != null &&
                  qualityLabel!.trim().isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(
                      20.r,
                    ),
                    border: Border.all(
                      color: theme.dividerColor,
                    ),
                  ),
                  child: Text(
                    qualityLabel!,
                    style: theme.textTheme.labelMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            locale.experienceCompletenessHint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          if (completion != null) ...[
            SizedBox(height: 18.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: LinearProgressIndicator(
                value: completion / 100,
                minHeight: 5.h,
                backgroundColor:
                    colors.surfaceContainerHighest,
              ),
            ),
            SizedBox(height: 9.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    locale.editorialScore,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Text(
                  locale.completedPercentage(completion),
                  style: theme.textTheme.labelMedium
                      ?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
