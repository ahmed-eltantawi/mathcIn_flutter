import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CurrentStatusCard extends StatelessWidget {
  const CurrentStatusCard({super.key});

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
              children: [
                Expanded(
                  child: Text(
                    s.currentStatus,
                    style: theme.textTheme.labelLarge
                        ?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(
                      20.r,
                    ),
                  ),
                  child: Text(
                    s.applied,
                    style: theme.textTheme.labelMedium
                        ?.copyWith(
                          color:
                              theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Icon(
                  Icons.schedule_outlined,
                  size: 19.sp,
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    s.submittedTodayTime,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
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
