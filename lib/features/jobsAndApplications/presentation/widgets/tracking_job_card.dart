import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TrackingJobCard extends StatelessWidget {
  const TrackingJobCard({super.key, this.onViewJob});

  final VoidCallback? onViewJob;

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
                Container(
                  width: 52.w,
                  height: 52.w,
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
                    Icons.apartment_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(width: 14.w),
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
                      SizedBox(height: 2.h),
                      Text(
                        'TechNova',
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(
                              color: theme
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.65),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 14.h),

            const Divider(height: 1),

            SizedBox(height: 14.h),

            Text(
              '${s.cairo} • ${s.hybrid} • ${s.fullTime}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
            ),

            SizedBox(height: 8.h),

            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                onPressed: onViewJob ?? () {},
                iconAlignment: IconAlignment.end,
                icon: const Icon(
                  Icons.arrow_forward,
                  size: 18,
                ),
                label: Text(s.viewJob),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
