import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/application_summary_card.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/improve_match_card.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/job_details_header.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/job_details_overview_card.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/job_match_card.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/job_requirements_card.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/matched_skills_card.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/skills_to_improve_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JobDetailsViewBody extends StatelessWidget {
  const JobDetailsViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const JobDetailsHeader(),
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
                const JobDetailsOverviewCard(),
                SizedBox(height: 14.h),
                const JobMatchCard(),
                SizedBox(height: 14.h),
                const MatchedSkillsCard(),
                SizedBox(height: 14.h),
                const SkillsToImproveCard(),
                SizedBox(height: 14.h),
                const JobRequirementsCard(),
                SizedBox(height: 14.h),
                const ImproveMatchCard(),
                SizedBox(height: 14.h),
                const ApplicationSummaryCard(),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
