import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ImproveMatchCard extends StatelessWidget {
  const ImproveMatchCard({super.key, this.onBuildRoadmap});

  final VoidCallback? onBuildRoadmap;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

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
                  width: 44.w,
                  height: 44.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary
                        .withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(
                      9.r,
                    ),
                  ),
                  child: Icon(
                    Icons.alt_route_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.wantToImproveYourMatch,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        color: theme.colorScheme.primary
                            .withValues(alpha: 0.08),
                        child: Text(
                          s.focusOnTwoHighPrioritySkills,
                          style: theme.textTheme.labelSmall
                              ?.copyWith(
                                color: theme
                                    .colorScheme
                                    .primary,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Text(
              s.roadmapMatchDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: theme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: 14.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onBuildRoadmap ?? () {},
                child: Text(s.buildMyRoadmap),
              ),
            ),
            SizedBox(height: 8.h),
            Center(
              child: Text(
                s.roadmapBasedOnJob,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
