import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:MatchIn/core/extensions/snack_bar_extensions.dart';
import 'package:MatchIn/core/functions/require_auth.dart';
import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/apply_to_job_cubit.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/apply_to_job_state.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/jobs_feed_cubit.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/apply_header.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/review_application_view_widgets/review_info_card.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/review_application_view_widgets/review_job_card.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/review_application_view_widgets/user_info.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/review_cover_note_card.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/review_cv_card.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/review_questions_card.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_cached_candidate_profile_use_case.dart';
import 'package:MatchIn/generated/l10n.dart';

class ReviewApplicationViewBody extends StatefulWidget {
  const ReviewApplicationViewBody({
    super.key,
    required this.job,
    this.coverLetter,
    this.cvFileName,
    this.cvFileSize,
  });

  final JobEntity job;
  final String? coverLetter;
  final String? cvFileName;
  final String? cvFileSize;

  @override
  State<ReviewApplicationViewBody> createState() =>
      _ReviewApplicationViewBodyState();
}

class _ReviewApplicationViewBodyState extends State<ReviewApplicationViewBody> {
  int? _cvDocumentId;

  @override
  void initState() {
    super.initState();
    _loadCandidateProfileCvId();
  }

  Future<void> _loadCandidateProfileCvId() async {
    try {
      final result = await getIt<GetCachedCandidateProfileUseCase>()();
      if (!mounted) return;
      result.fold(
        (_) {},
        (profile) {
          if (profile?.cvDocument?.id != null) {
            setState(() {
              _cvDocumentId = profile!.cvDocument!.id;
            });
          }
        },
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return BlocConsumer<ApplyToJobCubit, ApplyToJobState>(
      listener: (context, state) {
        if (state is ApplyToJobFailure) {
          context.showErrorSnackBar(state.message);
        } else if (state is ApplyToJobSuccess) {
          context.showSuccessSnackBar(s.applicationSubmittedSuccessfully);
          context.read<JobsFeedCubit>().applyForJob(widget.job.id);
          context.push(
            AppRoutes.kapplicationSubmitted,
            extra: widget.job,
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state is ApplyToJobSubmitting;

        return Column(
          children: [
            ApplyHeader(
              title: s.reviewApplication,
              currentStep: 3,
              totalSteps: 3,
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 18.h,
                ),
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 5.h,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              s.stepThreeOfThree,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '• ${s.finalConfirmation}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        s.reviewBeforeSubmitting,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        s.reviewBeforeSubmittingDescription,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                      SizedBox(height: 22.h),

                      ReviewJobCard(job: widget.job),
                      SizedBox(height: 16.h),

                      ReviewInfoCard(
                        title: s.yourInformation,
                        actionLabel: s.edit,
                        job: widget.job,
                        child: const UserInformation(),
                      ),

                      SizedBox(height: 16.h),

                      ReviewInfoCard(
                        title: s.cv,
                        actionLabel: s.change,
                        job: widget.job,
                        child: ReviewCvCard(
                          fileName: widget.cvFileName,
                          fileSize: widget.cvFileSize,
                        ),
                      ),

                      SizedBox(height: 16.h),

                      ReviewInfoCard(
                        title: s.coverNote,
                        actionLabel: s.edit,
                        job: widget.job,
                        child: ReviewCoverNoteCard(
                          coverNote: widget.coverLetter,
                        ),
                      ),

                      SizedBox(height: 16.h),

                      ReviewInfoCard(
                        title: s.applicationQuestions,
                        actionLabel: s.edit,
                        job: widget.job,
                        child: const ReviewQuestionsCard(),
                      ),

                      SizedBox(height: 24.h),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 20.sp,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              s.submissionConfirmationNotice,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 18.h),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      border: Border(
                        top: BorderSide(
                          color: theme.dividerColor,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () {
                                    if (!requireAuth(context)) return;
                                    // External listings are applied on the
                                    // employer's website, never through the
                                    // in-app applications endpoint.
                                    if (widget.job.isExternalApply) {
                                      final website =
                                          widget.job.websiteUrl?.trim() ?? '';
                                      final uri = Uri.tryParse(website);
                                      final isValid = uri != null &&
                                          uri.isAbsolute &&
                                          (uri.scheme == 'http' ||
                                              uri.scheme == 'https');
                                      if (!isValid) {
                                        context.showErrorSnackBar(
                                          s.shareJobLinkUnavailable,
                                        );
                                        return;
                                      }
                                      context.push(
                                        AppRoutes.kWebView,
                                        extra: <String, dynamic>{
                                          'url': website,
                                          'title': widget.job.title,
                                        },
                                      );
                                      return;
                                    }
                                    final jobIdInt =
                                        int.tryParse(widget.job.id);
                                    if (jobIdInt == null || jobIdInt <= 0) {
                                      context.showErrorSnackBar(
                                        s.invalidJobId,
                                      );
                                      return;
                                    }
                                    context
                                        .read<ApplyToJobCubit>()
                                        .submitApplication(
                                          jobId: jobIdInt,
                                          cvDocumentId: _cvDocumentId,
                                          coverLetter: widget.coverLetter,
                                        );
                                  },
                            child: isSubmitting
                                ? SizedBox(
                                    height: 20.r,
                                    width: 20.r,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(s.submitApplication),
                                      SizedBox(width: 8.w),
                                      const Icon(Icons.send_outlined),
                                    ],
                                  ),
                          ),
                        ),
                        TextButton(
                          onPressed: isSubmitting
                              ? null
                              : () {
                                  context.pop();
                                },
                          child: Text(s.back),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
