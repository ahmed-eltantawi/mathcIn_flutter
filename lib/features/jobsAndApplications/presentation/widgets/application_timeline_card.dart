import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ApplicationTimelineCard extends StatelessWidget {
  const ApplicationTimelineCard({super.key});

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
            Text(
              s.applicationTimeline,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 20.h),

            _TimelineItem(
              title: s.applicationSubmitted,
              subtitle: s.todayAtTime,
              isCompleted: true,
              showLine: true,
            ),

            _TimelineItem(
              title: s.inReview,
              subtitle: s.pendingEmployerScreening,
              showLine: true,
            ),

            _TimelineItem(
              title: s.interview,
              subtitle: s.technicalCultureFitStage,
              showLine: true,
            ),

            _TimelineItem(
              title: s.offer,
              subtitle: s.finalDecisionAndOnboarding,
              showLine: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.title,
    required this.subtitle,
    required this.showLine,
    this.isCompleted = false,
  });

  final String title;
  final String subtitle;
  final bool showLine;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 34.w,
            child: Column(
              children: [
                Container(
                  width: 26.r,
                  height: 26.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.forestGreen
                        : theme.colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.forestGreen
                          : theme.dividerColor,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? Icon(
                          Icons.check_rounded,
                          size: 16.sp,
                          color: Colors.white,
                        )
                      : Container(
                          width: 6.r,
                          height: 6.r,
                          decoration: BoxDecoration(
                            color: theme.dividerColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                ),
                if (showLine)
                  Expanded(
                    child: Container(
                      width: 2.w,
                      color: theme.dividerColor,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: showLine ? 22.h : 0,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
