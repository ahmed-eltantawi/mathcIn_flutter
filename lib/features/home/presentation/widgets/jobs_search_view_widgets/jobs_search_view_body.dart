import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/widgets/loading/app_loading.dart';
import 'package:MatchIn/core/widgets/app_empty.dart';
import 'package:MatchIn/core/widgets/error/app_error.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/jobs_feed_cubit.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/jobs_feed_state.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/job_card_widgets/job_card.dart';
import 'package:MatchIn/features/home/presentation/widgets/jobs_search_view_widgets/job_filter_chip.dart';
import 'package:MatchIn/features/home/presentation/widgets/jobs_search_view_widgets/jobs_search_field.dart';
import 'package:MatchIn/features/home/presentation/widgets/jobs_search_view_widgets/jobs_search_header.dart';
import 'package:MatchIn/features/home/presentation/widgets/jobs_search_view_widgets/search_results_header.dart';

class JobsSearchViewBody extends StatelessWidget {
  const JobsSearchViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const JobsSearchHeader(),
          SizedBox(height: 12.h),
          const JobsSearchField(),
          SizedBox(height: 16.h),
          const _FiltersList(),
          SizedBox(height: 16.h),
          BlocBuilder<JobsFeedCubit, JobsFeedState>(
            builder: (context, state) {
              final count = state is JobsFeedLoaded
                  ? state.jobs.length
                  : 0;
              return SearchResultsHeader(
                opportunitiesCount: count,
              );
            },
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: 16.w,
            ),
            child:
                BlocBuilder<JobsFeedCubit, JobsFeedState>(
                  builder: (context, state) {
                    return switch (state) {
                      JobsFeedInitial() ||
                      JobsFeedLoading() =>
                        const AppLoadingWidget(),
                      JobsFeedError(:final message) =>
                        AppErrorWidget(message: message),
                      JobsFeedEmpty() =>
                        const AppEmptyWidget(
                          message: 'loading',
                        ),
                      JobsFeedLoaded(:final jobs) => Column(
                        children: [
                          for (final job in jobs) ...[
                            JobCard(
                              job: job,
                              showShareButton: true,
                              onSave: () => context
                                  .read<JobsFeedCubit>()
                                  .toggleSaveJob(job.id),
                              onApply: () => context
                                  .read<JobsFeedCubit>()
                                  .applyForJob(job.id),
                            ),
                            SizedBox(height: 12.h),
                          ],
                        ],
                      ),
                    };
                  },
                ),
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}

class _FiltersList extends StatelessWidget {
  const _FiltersList();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SizedBox(
      height: 40.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: 16.w,
        ),
        children: [
          JobFilterChip(label: l10n.all, isSelected: true),
          SizedBox(width: 8.w),
          JobFilterChip(label: l10n.remote),
          SizedBox(width: 8.w),
          JobFilterChip(label: l10n.internship),
          SizedBox(width: 8.w),
          JobFilterChip(label: l10n.fullTime),
          SizedBox(width: 8.w),
          JobFilterChip(label: l10n.entryLevel),
        ],
      ),
    );
  }
}
