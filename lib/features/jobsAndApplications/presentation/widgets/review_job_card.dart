import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReviewJobCard extends StatelessWidget {
  const ReviewJobCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    s.applyingFor,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(
                          color:
                              theme.colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    s.juniorFlutterDeveloper,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'TechNova',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 18.sp,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          '${s.cairo} • ${s.hybrid} • ${s.fullTime}',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(
                                color: theme
                                    .colorScheme
                                    .onSurface
                                    .withValues(
                                      alpha: 0.65,
                                    ),
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Container(
              width: 48.w,
              height: 48.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme
                    .colorScheme
                    .surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: theme.dividerColor,
                ),
              ),
              child: Text(
                'TN',
                style: theme.textTheme.titleMedium
                    ?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
