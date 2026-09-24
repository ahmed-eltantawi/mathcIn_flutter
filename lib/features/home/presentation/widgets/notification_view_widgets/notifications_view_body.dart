import 'package:MatchIn/features/home/presentation/widgets/notification_view_widgets/notification_card.dart';
import 'package:MatchIn/features/home/presentation/widgets/notification_view_widgets/notification_filter_chip.dart';
import 'package:MatchIn/features/home/presentation/widgets/notification_view_widgets/notifications_header.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationsViewBody extends StatelessWidget {
  const NotificationsViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return Column(
      children: [
        const NotificationsHeader(),

        const Divider(height: 1),

        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        NotificationFilterChip(
                          label: s.all,
                          isSelected: true,
                        ),
                        SizedBox(width: 8.w),
                        NotificationFilterChip(
                          label: s.jobs,
                          isSelected: false,
                        ),
                        SizedBox(width: 8.w),
                        NotificationFilterChip(
                          label: s.applications,
                          isSelected: false,
                        ),
                        SizedBox(width: 8.w),
                        NotificationFilterChip(
                          label: s.roadmap,
                          isSelected: false,
                        ),
                        SizedBox(width: 8.w),
                        NotificationFilterChip(
                          label: s.cv,
                          isSelected: false,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  Text(
                    s.today,
                    style: theme.textTheme.labelLarge
                        ?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),

                  SizedBox(height: 12.h),

                  NotificationCard(
                    icon: Icons.work_outline,
                    title: s.newJobsMatchProfile,
                    description: s.flutterOpportunities,
                    time: s.tenMinutesAgo,
                    actionLabel: s.viewJobs,
                    isUnread: true,
                  ),

                  SizedBox(height: 12.h),

                  NotificationCard(
                    icon: Icons.route_outlined,
                    title: s.roadmapUpdated,
                    description: s.testingPrioritySkill,
                    time: s.twoHoursAgo,
                    actionLabel: s.viewRoadmap,
                    isUnread: true,
                  ),

                  SizedBox(height: 12.h),

                  NotificationCard(
                    icon: Icons.description_outlined,
                    title: s.cvAnalysisCompleted,
                    description: s.cvAnalysisDescription,
                    time: s.fourHoursAgo,
                    actionLabel: s.reviewCv,
                  ),

                  SizedBox(height: 24.h),

                  Text(
                    s.yesterday,
                    style: theme.textTheme.labelLarge
                        ?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),

                  SizedBox(height: 12.h),

                  NotificationCard(
                    icon:
                        Icons.assignment_turned_in_outlined,
                    title: s.applicationStatusUpdated,
                    description:
                        s.applicationStatusDescription,
                    time: s.yesterdayTime,
                    actionLabel: s.viewApplication,
                  ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
