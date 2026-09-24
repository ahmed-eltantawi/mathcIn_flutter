import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:MatchIn/core/widgets/matching_status/matching_status.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JobMatchCard extends StatelessWidget {
  const JobMatchCard({super.key});

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
                Icon(
                  Icons.auto_awesome,
                  color: AppColors.goldenMustard,
                  size: 20.sp,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    s.yourMatch,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const MatchingStatus(percentage: 78),
              ],
            ),
            SizedBox(height: 14.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: LinearProgressIndicator(
                value: 0.78,
                minHeight: 10.h,
                backgroundColor: theme.dividerColor,
                color: AppColors.amber,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              s.matchSevenOfNine,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              s.matchExplanation,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: theme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
