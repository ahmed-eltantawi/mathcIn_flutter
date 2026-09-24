import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/job_card_widgets/job_card.dart';
import 'package:MatchIn/features/home/presentation/widgets/jobs_search_view_widgets/job_filter_chip.dart';
import 'package:MatchIn/features/home/presentation/widgets/jobs_search_view_widgets/jobs_search_field.dart';
import 'package:MatchIn/features/home/presentation/widgets/jobs_search_view_widgets/jobs_search_header.dart';
import 'package:MatchIn/features/home/presentation/widgets/jobs_search_view_widgets/search_results_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JobsSearchViewBody extends StatelessWidget {
  const JobsSearchViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: دي dummy data مؤقتة لحد ما نربط الـ Cubit بالباك إند
    final dummyJobs = [
      JobEntity(
        id: '1',
        title: 'Junior Flutter Developer',
        companyName: 'TechNova',
        location: 'Cairo',
        workMode: 'Hybrid',
        experienceLevel: '0–2 years',
        employmentType: 'Full-time',
        postedDate: DateTime.now().subtract(
          const Duration(hours: 2),
        ),
        skills: const ['Flutter', 'REST API', 'Bloc'],
        matchPercentage: 92,
      ),
      JobEntity(
        id: '2',
        title: 'Mobile Developer Intern',
        companyName: 'CodeHub',
        location: 'Remote',
        workMode: 'Remote',
        experienceLevel: '0–1 years',
        employmentType: 'Internship',
        postedDate: DateTime.now().subtract(
          const Duration(hours: 2),
        ),
        skills: const ['Flutter', 'Firebase', 'Git'],
        matchPercentage: 82,
      ),
      JobEntity(
        id: '3',
        title: 'Flutter UI Engineer',
        companyName: 'AppStudio',
        location: 'Giza',
        workMode: 'On-site',
        experienceLevel: 'Mid Level',
        employmentType: 'Full-time',
        postedDate: DateTime.now().subtract(
          const Duration(days: 1),
        ),
        skills: const ['Dart', 'Flutter'],
        matchPercentage: 75,
      ),
    ];

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
          const SearchResultsHeader(
            opportunitiesCount: 124,
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: 16.w,
            ),
            child: Column(
              children: [
                for (final job in dummyJobs) ...[
                  JobCard(job: job, showShareButton: true),
                  SizedBox(height: 12.h),
                ],
              ],
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
