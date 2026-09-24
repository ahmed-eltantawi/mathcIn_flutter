import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/jobs_feed_cubit.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/jobs_feed_state.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/application_summary_card.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/improve_match_card.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/job_card_widgets/job_card.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/job_details_header.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/job_match_card.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/job_requirements_card.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/matched_skills_card.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/skills_to_improve_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class JobDetailsViewBody extends StatelessWidget {
  const JobDetailsViewBody({super.key, required this.job});
  final JobEntity job;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobsFeedCubit, JobsFeedState>(
      builder: (context, state) {
        final currentJob =
            context.read<JobsFeedCubit>().getJobById(
              job.id,
            ) ??
            job;
        final isApplied =
            currentJob.applicationStatus !=
            JobApplicationStatus.notApplied;

        return Column(
          children: [
            const JobDetailsHeader(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: ListView(
                  children: [
                    JobCard(job: currentJob),
                    Gap(14.h),
                    const JobMatchCard(),
                    Gap(14.h),
                    if (currentJob
                        .matchedSkills
                        .isNotEmpty) ...[
                      MatchedSkillsCard(
                        skills: currentJob.matchedSkills,
                      ),
                      Gap(14.h),
                    ],
                    Gap(14.h),
                    if (currentJob
                        .missingSkills
                        .isNotEmpty) ...[
                      SkillsToImproveCard(
                        skills: currentJob.missingSkills,
                      ),
                      Gap(14.h),
                    ],
                    const JobRequirementsCard(),
                    if (currentJob
                        .missingSkills
                        .isNotEmpty) ...[
                      Gap(14.h),
                      ImproveMatchCard(
                        onBuildRoadmap: () {
                          // Next step: Chatbot handoff.
                        },
                      ),
                    ],
                    if (isApplied) ...[
                      Gap(14.h),
                      const ApplicationSummaryCard(),
                    ],
                    Gap(14.h),
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
