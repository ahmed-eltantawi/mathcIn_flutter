import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/extensions/date_time_extensions.dart';
import 'package:MatchIn/core/extensions/snack_bar_extensions.dart';
import 'package:MatchIn/core/functions/require_auth.dart';
import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/core/widgets/matching_status/matching_status.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/job_card_widgets/job_card_header.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/job_card_widgets/job_hero_tags.dart';
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
    this.heroPrefix = 'feed',
  });

  final JobEntity job;
  final bool showShareButton;

  final VoidCallback? onShare;
  final VoidCallback? onTap;
  final VoidCallback? onApply;
  final VoidCallback? onSave;

  /// List-source prefix scoping Hero tags ('home', 'feed', 'search', 'saved').
  final String heroPrefix;

  bool get _isApplied =>
      job.applicationStatus != JobApplicationStatus.notApplied;

  ///* Scoped Hero tags: prefix + job id + element. The details screen reuses
  ///* the originating [heroPrefix] passed via navigation extra, so the same
  ///* job in Home / Feed / Search / Saved never produces duplicate tags.
  String get _heroTag =>
      JobHeroTags.avatar(prefix: heroPrefix, jobId: job.id);

  // Guards against rapid repeated taps pushing duplicate details screens.
  static String? _navigatingJobId;
  static DateTime? _lastNavigationTime;

  static void navigateToJobDetails(
    BuildContext context, {
    required JobEntity job,
    required String heroPrefix,
  }) {
    final now = DateTime.now();
    if (_navigatingJobId == job.id &&
        _lastNavigationTime != null &&
        now.difference(_lastNavigationTime!) <
            const Duration(milliseconds: 750)) {
      return;
    }
    _navigatingJobId = job.id;
    _lastNavigationTime = now;
    context.push(
      AppRoutes.kJobDetailsView,
      extra: <String, dynamic>{'job': job, 'heroPrefix': heroPrefix},
    ).then((_) {
      if (_navigatingJobId == job.id) {
        _navigatingJobId = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap:
            onTap ??
            () => navigateToJobDetails(
              context,
              job: job,
              heroPrefix: heroPrefix,
            ),
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
                heroTag: _heroTag,
                heroPrefix: heroPrefix,
                jobId: job.id,
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
                  JobsInfoJobCard(label: job.employmentType),
                  JobsInfoJobCard(label: job.workMode),
                  JobsInfoJobCard(
                    label: job.experienceLevel,
                    icon: Icons.work_outline_rounded,
                  ),
                ],
              ),
              SizedBox(height: 10.h),
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
                  MatchingStatus(percentage: job.matchPercentage),
                  const Spacer(),
                    ElevatedButton(
                      onPressed: _isApplied
                          ? null
                          : (onApply ??
                              () {
                                if (!requireAuth(context)) return;
                                // External listings open the employer's
                                // website and are never marked as applied
                                // merely for opening the link.
                                if (job.isExternalApply) {
                                  final website =
                                      job.websiteUrl?.trim() ?? '';
                                  final uri = Uri.tryParse(website);
                                  final isValid = uri != null &&
                                      uri.isAbsolute &&
                                      (uri.scheme == 'http' ||
                                          uri.scheme == 'https');
                                  if (!isValid) {
                                    context.showErrorSnackBar(
                                      context.l10n.shareJobLinkUnavailable,
                                    );
                                    return;
                                  }
                                  context.push(
                                    AppRoutes.kWebView,
                                    extra: <String, dynamic>{
                                      'url': website,
                                      'title': job.title,
                                    },
                                  );
                                  return;
                                }
                                context.push(
                                  AppRoutes.kapplyForRole,
                                  extra: job,
                                );
                              }),
                      style: ElevatedButton.styleFrom(
                      minimumSize: Size(110.w, 42.h),
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
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
