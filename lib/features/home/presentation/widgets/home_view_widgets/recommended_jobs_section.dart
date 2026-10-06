import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/core/widgets/app_empty.dart';
import 'package:MatchIn/core/widgets/error/app_error.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/jobs_feed_cubit.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/jobs_feed_state.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/job_card_widgets/animated_job_card_list.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/job_card_widgets/job_card_shimmer.dart';
import 'package:go_router/go_router.dart';

class RecommendedJobsSection extends StatelessWidget {
  const RecommendedJobsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16).w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.recommendedForYou,
                  style: context.textTheme.titleMedium,
                ),
              ),
              TextButton(
                onPressed: () =>
                    context.push(AppRoutes.kJobsSearchView),
                child: Text(context.l10n.seeAll),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          BlocBuilder<JobsFeedCubit, JobsFeedState>(
            builder: (context, state) {
              return switch (state) {
                JobsFeedInitial() || JobsFeedLoading() =>
                  const JobFeedShimmerList(count: 3),
                JobsFeedError(:final message) =>
                  AppErrorWidget(
                    message: message,
                    onRetry: () => context.read<JobsFeedCubit>().getJobs(),
                  ),
                JobsFeedEmpty() => AppEmptyWidget(
                  message: context.l10n.noJobsFound,
                ),
                JobsFeedLoaded(:final jobs) => AnimatedJobCardList(
                  jobs: jobs.take(3).toList(),
                  showShareButton: true,
                  onSave: (id) =>
                      context.read<JobsFeedCubit>().toggleSaveJob(id),
                ),
                JobsFeedOfflineWithCache(:final jobs) => AnimatedJobCardList(
                  jobs: jobs.take(3).toList(),
                  showShareButton: true,
                  onSave: (id) =>
                      context.read<JobsFeedCubit>().toggleSaveJob(id),
                ),
              };
            },
          ),
        ],
      ),
    );
  }
}
