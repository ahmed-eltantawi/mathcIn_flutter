import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/jobs_feed_cubit.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/apply_header.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/review_cv_card.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/review_application_view_widgets/review_info_card.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/review_application_view_widgets/review_job_card.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/review_questions_card.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ReviewApplicationViewBody extends StatelessWidget {
  const ReviewApplicationViewBody({
    super.key,
    required this.job,
  });

  final JobEntity job;
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

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
                crossAxisAlignment:
                    CrossAxisAlignment.start,
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
                          borderRadius:
                              BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          s.stepThreeOfThree,
                          style: theme.textTheme.labelMedium
                              ?.copyWith(
                                color: theme
                                    .colorScheme
                                    .secondary,
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
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    s.reviewBeforeSubmittingDescription,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(
                          height: 1.5,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                  ),
                  SizedBox(height: 22.h),

                  ReviewJobCard(job: job),
                  SizedBox(height: 16.h),

                  ReviewInfoCard(
                    title: s.yourInformation,
                    actionLabel: s.edit,

                    job: job,
                    child: const _UserInformation(),
                  ),

                  SizedBox(height: 16.h),

                  ReviewInfoCard(
                    title: s.cv,
                    actionLabel: s.change,
                    job: job,
                    child: const ReviewCvCard(),
                  ),

                  SizedBox(height: 16.h),

                  ReviewInfoCard(
                    title: s.coverNote,
                    actionLabel: s.edit,

                    job: job,
                    child: Text(
                      s.noCoverNoteAdded,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: theme
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.55),
                          ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  ReviewInfoCard(
                    title: s.applicationQuestions,
                    actionLabel: s.edit,
                    job: job,
                    child: const ReviewQuestionsCard(),
                  ),

                  SizedBox(height: 24.h),

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
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
                          style: theme.textTheme.bodySmall
                              ?.copyWith(
                                color: theme
                                    .colorScheme
                                    .onSurface
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
                        onPressed: () async {
                          await context
                              .read<JobsFeedCubit>()
                              .applyForJob(job.id);

                          if (!context.mounted) return;

                          context.push(
                            AppRoutes.kapplicationSubmitted,
                            extra: job,
                          );
                        },
                        child: Row(
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
                      onPressed: () {
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
  }
}

class _UserInformation extends StatelessWidget {
  const _UserInformation();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Column(
      children: [
        _InfoRow(label: s.fullName, value: 'Ahmed Mohamed'),
        SizedBox(height: 12.h),
        _InfoRow(
          label: s.emailAddress,
          value: 'ahmed@email.com',
        ),
        SizedBox(height: 12.h),
        _InfoRow(
          label: s.phoneNumber,
          value: '+20 100 000 0000',
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(
                alpha: 0.65,
              ),
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
