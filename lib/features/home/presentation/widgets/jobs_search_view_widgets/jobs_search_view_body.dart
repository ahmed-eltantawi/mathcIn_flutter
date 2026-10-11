import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/widgets/app_empty.dart';
import 'package:MatchIn/core/widgets/error/app_error.dart';
import 'package:MatchIn/features/home/presentation/widgets/jobs_search_view_widgets/jobs_filter_section.dart';
import 'package:MatchIn/features/home/presentation/widgets/jobs_search_view_widgets/jobs_offline_banner.dart';
import 'package:MatchIn/features/home/presentation/widgets/jobs_search_view_widgets/jobs_search_field.dart';
import 'package:MatchIn/features/home/presentation/widgets/jobs_search_view_widgets/jobs_search_header.dart';
import 'package:MatchIn/features/home/presentation/widgets/jobs_search_view_widgets/search_results_header.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/jobs_feed_cubit.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/jobs_feed_state.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/job_card_widgets/animated_job_card_list.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/job_card_widgets/job_card_shimmer.dart';

class JobsSearchViewBody extends StatefulWidget {
  const JobsSearchViewBody({super.key});

  @override
  State<JobsSearchViewBody> createState() => _JobsSearchViewBodyState();
}

class _JobsSearchViewBodyState extends State<JobsSearchViewBody> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<JobsFeedCubit>();
      if (cubit.state is JobsFeedInitial) {
        cubit.getJobs();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels >=
            scrollInfo.metrics.maxScrollExtent - 200) {
          context.read<JobsFeedCubit>().loadMoreJobs();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () => context.read<JobsFeedCubit>().refreshJobs(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const JobsSearchHeader(),
              SizedBox(height: 12.h),
              JobsSearchField(
                controller: _searchController,
                onChanged: (query) =>
                    context.read<JobsFeedCubit>().searchJobs(query),
                onClear: () {
                  _searchController.clear();
                  context.read<JobsFeedCubit>().searchJobs('');
                },
              ),
              SizedBox(height: 16.h),
              const JobsFilterSection(),
              SizedBox(height: 16.h),
              BlocBuilder<JobsFeedCubit, JobsFeedState>(
                builder: (context, state) {
                  final count = switch (state) {
                    JobsFeedLoaded(:final jobs) => jobs.length,
                    JobsFeedOfflineWithCache(:final jobs) => jobs.length,
                    _ => 0,
                  };
                  return SearchResultsHeader(opportunitiesCount: count);
                },
              ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
                child: BlocConsumer<JobsFeedCubit, JobsFeedState>(
                  listener: (context, state) {
                    if (state is JobsFeedLoaded &&
                        state.errorMessage != null &&
                        state.errorMessage!.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.errorMessage!),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return switch (state) {
                      JobsFeedInitial() ||
                      JobsFeedLoading() => const JobFeedShimmerList(),
                      JobsFeedError(:final message) => AppErrorWidget(
                        message: message,
                        onRetry: () => context.read<JobsFeedCubit>().getJobs(),
                      ),
                      JobsFeedEmpty() => AppEmptyWidget(
                        message: context.l10n.noJobsFound,
                      ),
                      JobsFeedOfflineWithCache(:final jobs, :final message) =>
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            JobsOfflineBanner(
                              message: message ?? context.l10n.noInternetConnection,
                            ),
                            SizedBox(height: 12.h),
                            AnimatedJobCardList(
                              jobs: jobs,
                              showShareButton: true,
                              onSave: (id) => context
                                  .read<JobsFeedCubit>()
                                  .toggleSaveJob(id),
                              onApply: (id) =>
                                  context.read<JobsFeedCubit>().applyForJob(id),
                            ),
                          ],
                        ),
                      JobsFeedLoaded(
                        :final jobs,
                        :final isFromCache,
                        :final isPaginationLoading,
                      ) =>
                        Column(
                          children: [
                            if (isFromCache) ...[
                              JobsOfflineBanner(
                                message:
                                    state.errorMessage ??
                                    context.l10n.noInternetConnection,
                              ),
                              SizedBox(height: 12.h),
                            ],
                            AnimatedJobCardList(
                              jobs: jobs,
                              showShareButton: true,
                              onSave: (id) => context
                                  .read<JobsFeedCubit>()
                                  .toggleSaveJob(id),
                              onApply: (id) =>
                                  context.read<JobsFeedCubit>().applyForJob(id),
                            ),
                            if (isPaginationLoading) ...[
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                child: const JobCardShimmer(),
                              ),
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
        ),
      ),
    );
  }
}
