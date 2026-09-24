import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/extensions/date_time_extensions.dart';
import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/core/widgets/matching_status/matching_status.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/job_card_widgets/job_card_header.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/job_card_widgets/job_card_posted_date.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/job_card_widgets/job_card_skills_section.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/jobs_info_job_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class JobCard extends StatelessWidget {
  const JobCard({
    super.key,
    required this.job,
    this.showShareButton = false,
    this.onShare,
    this.onTap,
    this.onApply,
    this.onSave,
  });

  final JobEntity job;
  final bool showShareButton;

  final VoidCallback? onShare;
  final VoidCallback? onTap;
  final VoidCallback? onApply;
  final VoidCallback? onSave;

  bool get _isApplied =>
      job.applicationStatus !=
      JobApplicationStatus.notApplied;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap:
            onTap ??
            () => context.push(AppRoutes.kJobDetailsView),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              JobCardHeader(
                title: job.title,
                companyName: job.companyName,
                companyLogoUrl: job.companyLogoUrl,
                isSaved: job.isSaved,
                showShareButton: showShareButton,
                onShare: onShare,
                onSave: onSave,
              ),
              SizedBox(height: 14.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  JobsInfoJobCard(
                    label: job.location,
                    icon: Icons.location_on_outlined,
                  ),
                  JobsInfoJobCard(
                    label: job.employmentType,
                  ),
                  JobsInfoJobCard(label: job.workMode),
                  JobsInfoJobCard(
                    label: job.experienceLevel,
                    icon: Icons.work_outline_rounded,
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              // TODO: نستبدل job.postedDate.toString() بدالة تنسيق تاريخ نسبي
              JobCardPostedDate(
                postedDate: job.postedDate.timeAgo(context),
              ),
              if (job.skills.isNotEmpty) ...[
                SizedBox(height: 14.h),
                JobCardSkillsSection(skills: job.skills),
              ],
              SizedBox(height: 16.h),
              Divider(height: 1.h),
              SizedBox(height: 14.h),
              Row(
                children: [
                  MatchingStatus(
                    percentage: job.matchPercentage,
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _isApplied
                        ? null
                        : (onApply ??
                              () => context.push(
                                AppRoutes.kapplyForRole,
                              )),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(110.w, 42.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                      ),
                    ),
                    child: Text(
                      _isApplied
                          ? context.l10n.applied
                          : context.l10n.applyNow,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
