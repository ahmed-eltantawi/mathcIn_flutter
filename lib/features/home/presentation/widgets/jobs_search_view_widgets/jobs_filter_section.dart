import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/features/home/presentation/widgets/jobs_search_view_widgets/job_filter_chip.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_filter_params.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/jobs_feed_cubit.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/jobs_feed_state.dart';

///* JobsFilterSection — horizontal scrollable row of quick-filter chips.
///*
///* Root-cause fix: reads [JobsFeedState.filterParams] from the state object
///* (not from the cubit's private field via a getter). Since [JobsFeedLoading]
///* now carries [filterParams], the chips update *immediately* on tap — before
///* the API call returns — because [BlocBuilder] rebuilds on the loading state.
class JobsFilterSection extends StatelessWidget {
  const JobsFilterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<JobsFeedCubit, JobsFeedState>(
      buildWhen: (prev, curr) => prev.filterParams != curr.filterParams,
      builder: (context, state) {
        final cubit = context.read<JobsFeedCubit>();

        // Read filter params from the state (which now includes loading state).
        // Falls back to cubit's current params for states that don't carry them
        // (e.g. JobsFeedEmpty, JobsFeedError).
        final params = state.filterParams ?? cubit.currentFilterParams;

        final isRemote = params.workMode?.toLowerCase() == 'remote';
        final isInternship =
            params.employmentType?.toLowerCase() == 'internship';
        final isFullTime = params.employmentType?.toLowerCase() == 'full-time';
        final isEntryLevel =
            params.experienceLevel?.toLowerCase() == 'entry level' ||
            params.experienceLevel?.toLowerCase() == 'entry-level';

        final isAll =
            !isRemote && !isInternship && !isFullTime && !isEntryLevel;

        return SizedBox(
          height: 40.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
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
                onTap: () => cubit.setExperienceLevel(
                  isEntryLevel ? null : 'Entry Level',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
