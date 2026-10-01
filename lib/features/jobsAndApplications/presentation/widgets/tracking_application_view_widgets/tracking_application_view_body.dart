import 'package:MatchIn/core/extensions/snack_bar_extensions.dart';
import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/application_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/application_details_cubit.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/application_details_state.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/application_notes_card.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/application_timeline_card.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/career_help_card.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/current_status_card.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/tracking_application_view_widgets/application_details_card.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/tracking_application_view_widgets/tracking_job_card.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/tracking_header.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class TrackingApplicationViewBody extends StatelessWidget {
  const TrackingApplicationViewBody({
    super.key,
    required this.job,
    required this.applicationId,
  });

  final JobEntity job;
  final String applicationId;

  void _showWithdrawDialog(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(s.withdrawApplication),
        content: const Text(
          'Are you sure you want to withdraw this application? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context
                  .read<ApplicationDetailsCubit>()
                  .withdrawApplication(applicationId);
            },
            child: Text(s.withdrawApplication),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);

    return BlocConsumer<ApplicationDetailsCubit, ApplicationDetailsState>(
      listener: (context, state) {
        if (state is ApplicationDetailsLoaded) {
          if (state.errorMessage != null) {
            context.showErrorSnackBar(state.errorMessage!);
          } else if (state.actionSuccessMessage != null) {
            context.showSuccessSnackBar(state.actionSuccessMessage!);
          }
        } else if (state is ApplicationDetailsError) {
          context.showErrorSnackBar(state.message);
        }
      },
      builder: (context, state) {
        ApplicationEntity? currentApp;
        bool isActionLoading = false;

        if (state is ApplicationDetailsLoaded) {
          currentApp = state.application;
          isActionLoading = state.isActionLoading;
        }

        final status = currentApp?.status ?? ApplicationStatus.applied;
        final isWithdrawable = status.isWithdrawable;

        return Column(
          children: [
            const TrackingHeader(),
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
                        context.push(
                          AppRoutes.kJobDetailsView,
                          extra: currentApp?.job ?? job,
                        );
                      },
                      job: currentApp?.job ?? job,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.keepTrackerUpdated,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.75),
                              ),
                            ),
                            SizedBox(height: 14.h),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  // Status update option
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

                    if (isWithdrawable)
                      TextButton.icon(
                        onPressed: isActionLoading
                            ? null
                            : () => _showWithdrawDialog(context),
                        icon: isActionLoading
                            ? SizedBox(
                                height: 16.r,
                                width: 16.r,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
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
      },
    );
  }
}
