import 'package:MatchIn/core/functions/require_auth.dart';
import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/apply_bottom_button.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/apply_header.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/application_questions_view_widgets/job_info_details.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

//* The backend application contract (POST /applications) supports only
//* job_post_id, cv_document_id, cover_letter and notes. This step keeps no
//* extra employer-question inputs; it forwards to the review step.
class ApplicationQuestionsViewBody extends StatelessWidget {
  const ApplicationQuestionsViewBody({
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
          title: s.applicationQuestions,
          currentStep: 2,
          totalSteps: 2,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: ListView(
              children: [
                JobInfoDetails(
                  label:
                      '${job.title} • ${job.companyName}',
                ),
                SizedBox(height: 24.h),
                Text(
                  s.reviewBeforeSubmitting,
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                SizedBox(height: 8.h),
                Text(
                  s.reviewBeforeSubmittingDescription,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.65),
                      ),
                ),
                SizedBox(height: 24.h),
                ApplyBottomButton(
                  label: s.reviewApplication,
                  helperText: s.reviewBeforeSubmission,
                  onPressed: () {
                    if (!requireAuth(context)) return;
                    context.push(
                      AppRoutes.kreviewApplication,
                      extra: job,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
