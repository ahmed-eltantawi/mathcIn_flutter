import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/widgets/app_empty.dart';
import 'package:MatchIn/core/widgets/error/app_error.dart';
import 'package:MatchIn/core/widgets/loading/app_loading.dart';
import 'package:MatchIn/features/home/presentation/widgets/jobs_search_view_widgets/job_filter_chip.dart';
import 'package:MatchIn/features/home/presentation/widgets/jobs_search_view_widgets/jobs_search_field.dart';
import 'package:MatchIn/features/home/presentation/widgets/jobs_search_view_widgets/jobs_search_header.dart';
import 'package:MatchIn/features/home/presentation/widgets/jobs_search_view_widgets/search_results_header.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_filter_params.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/jobs_feed_cubit.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/jobs_feed_state.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/job_card_widgets/job_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
              const _FiltersList(),
              SizedBox(height: 16.h),
              BlocBuilder<JobsFeedCubit, JobsFeedState>(
                builder: (context, state) {
                  final count = switch (state) {
                    JobsFeedLoaded(:final jobs) => jobs.length,
                    JobsFeedOfflineWithCache(:final jobs) => jobs.length,
                    _ => 0,
                  };
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
                      JobsFeedLoading() =>
                        const AppLoadingWidget(),
                      JobsFeedError(:final message) =>
                        AppErrorWidget(message: message),
                      JobsFeedEmpty() => AppEmptyWidget(
                          message: context.l10n.noJobsFound,
                        ),
                      JobsFeedOfflineWithCache(:final jobs, :final message) =>
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _OfflineBanner(message: message),
                            SizedBox(height: 12.h),
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
                      JobsFeedLoaded(
                        :final jobs,
                        :final isFromCache,
                        :final isPaginationLoading,
                      ) =>
                        Column(
                          children: [
                            if (isFromCache) ...[
                              _OfflineBanner(
                                message: state.errorMessage ??
                                    'Showing cached jobs (Offline)',
                              ),
                              SizedBox(height: 12.h),
                            ],
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
                            if (isPaginationLoading) ...[
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                child: const AppLoadingWidget(),
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

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 18.sp,
            color: context.colors.primary,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.primary,
              ),
            ),
          ),
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

    return BlocBuilder<JobsFeedCubit, JobsFeedState>(
      builder: (context, state) {
        final cubit = context.read<JobsFeedCubit>();
        final params = cubit.currentFilterParams;

        final isRemote = params.workMode?.toLowerCase() == 'remote';
        final isInternship =
            params.employmentType?.toLowerCase() == 'internship';
        final isFullTime =
            params.employmentType?.toLowerCase() == 'full-time';
        final isEntryLevel =
            params.experienceLevel?.toLowerCase() == 'entry level' ||
                params.experienceLevel?.toLowerCase() == 'entry-level';

        final isAll =
            !isRemote && !isInternship && !isFullTime && !isEntryLevel;

        return SizedBox(
          height: 40.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: 16.w,
            ),
            children: [
              JobFilterChip(
                label: l10n.all,
                isSelected: isAll,
                onTap: () => cubit.applyFilterParams(const JobFilterParams()),
              ),
              SizedBox(width: 8.w),
              JobFilterChip(
                label: l10n.remote,
                isSelected: isRemote,
                onTap: () => cubit.setWorkMode(isRemote ? null : 'Remote'),
              ),
              SizedBox(width: 8.w),
              JobFilterChip(
                label: l10n.internship,
                isSelected: isInternship,
                onTap: () =>
                    cubit.setEmploymentType(isInternship ? null : 'Internship'),
              ),
              SizedBox(width: 8.w),
              JobFilterChip(
                label: l10n.fullTime,
                isSelected: isFullTime,
                onTap: () =>
                    cubit.setEmploymentType(isFullTime ? null : 'Full-time'),
              ),
              SizedBox(width: 8.w),
              JobFilterChip(
                label: l10n.entryLevel,
                isSelected: isEntryLevel,
                onTap: () => cubit
                    .setExperienceLevel(isEntryLevel ? null : 'Entry Level'),
              ),
            ],
          ),
        );
      },
    );
  }
}
