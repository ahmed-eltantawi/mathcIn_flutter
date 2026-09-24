import 'package:MatchIn/core/widgets/matching_status/matching_status.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JobSummaryCard extends StatelessWidget {
  const JobSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 58.w,
                  height: 58.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme
                        .colorScheme
                        .surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(
                      10.r,
                    ),
                    border: Border.all(
                      color: theme.dividerColor,
                    ),
                  ),
                  child: Icon(
                    Icons.hub_outlined,
                    color: theme.colorScheme.primary,
                    size: 28.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.juniorFlutterDeveloper,
                        style: theme.textTheme.titleLarge
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'TechNova',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(
                              color: theme
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.65),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                const MatchingStatus(percentage: 78),
              ],
            ),
            SizedBox(height: 16.h),
            const Divider(height: 1),
            SizedBox(height: 14.h),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 18.sp,
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.7),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    '${s.cairo} • ${s.hybrid} • ${s.fullTime}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme
                        .colorScheme
                        .surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(
                      6.r,
                    ),
                  ),
                  child: Text(
                    s.zeroToTwoYearsExp,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(
                          color:
                              theme.colorScheme.onSurface,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
