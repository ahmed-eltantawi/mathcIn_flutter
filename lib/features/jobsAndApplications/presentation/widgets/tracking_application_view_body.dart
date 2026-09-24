import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/application_details_card.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/application_notes_card.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/application_timeline_card.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/career_help_card.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/current_status_card.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/tracking_header.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/tracking_job_card.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class TrackingApplicationViewBody extends StatelessWidget {
  const TrackingApplicationViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);

    return Column(
      children: [
        const TrackingHeader(),
        const Divider(height: 1),

        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            child: Column(
              children: [
                TrackingJobCard(
                  onViewJob: () {
                    context.push(AppRoutes.kJobDetailsView);
                  },
                ),

                SizedBox(height: 16.h),

                const CurrentStatusCard(),

                SizedBox(height: 16.h),

                const ApplicationTimelineCard(),

                SizedBox(height: 16.h),

                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.keepTrackerUpdated,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(
                                color: theme
                                    .colorScheme
                                    .onSurface
                                    .withValues(
                                      alpha: 0.75,
                                    ),
                              ),
                        ),
                        SizedBox(height: 14.h),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // UI Only:
                              // Status update flow later.
                            },
                            icon: const Icon(
                              Icons.edit_calendar_outlined,
                            ),
                            label: Text(s.updateStatus),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                const ApplicationDetailsCard(),

                SizedBox(height: 16.h),

                const ApplicationNotesCard(),

                SizedBox(height: 16.h),

                const CareerHelpCard(),

                SizedBox(height: 24.h),

                TextButton.icon(
                  onPressed: () {
                    // Integration:
                    // Withdraw application later.
                  },
                  icon: Icon(
                    Icons.cancel_outlined,
                    color: theme.colorScheme.error,
                  ),
                  label: Text(
                    s.withdrawApplication,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),

                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
