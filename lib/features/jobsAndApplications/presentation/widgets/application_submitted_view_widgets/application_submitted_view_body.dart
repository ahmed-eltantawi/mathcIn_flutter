import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/application_submitted_view_widgets/submitted_status_card.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ApplicationSubmittedViewBody extends StatelessWidget {
  const ApplicationSubmittedViewBody({
    super.key,
    required this.job,
  });

  final JobEntity job;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);

    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        children: [
          Align(
            alignment: AlignmentDirectional.center,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 7.h,
              ),
              decoration: BoxDecoration(
                color: theme
                    .colorScheme
                    .surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: theme.dividerColor,
                ),
              ),
              child: Text(
                s.stepFourConfirmation,
                style: theme.textTheme.labelLarge?.copyWith(
                  letterSpacing: 1.5,
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
            ),
          ),

          const Spacer(),

          Container(
            width: 96.r,
            height: 96.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.semanticColors.success
                  .withValues(alpha: 0.25),
              shape: BoxShape.circle,
              border: Border.all(
                color: context.semanticColors.success
                    .withValues(alpha: 0.25),
              ),
            ),
            child: Icon(
              Icons.check_rounded,
              size: 52.sp,
              color: context.semanticColors.success,
            ),
          ),

          SizedBox(height: 28.h),

          Text(
            s.applicationSubmitted,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 12.h),

          Text.rich(
            TextSpan(
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
                color: theme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
              ),
              children: [
                TextSpan(text: '${s.yourApplicationFor} '),
                TextSpan(
                  text: job.title,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                  ),
                ),
                TextSpan(text: ' ${s.at} '),
                TextSpan(
                  text: job.companyName,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                  ),
                ),
                TextSpan(
                  text: ' ${s.submittedSuccessfully}',
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 30.h),

          const SubmittedStatusCard(),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.push(
                  AppRoutes.ktrackingApplication,
                  extra: job,
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(s.trackApplication),
                  SizedBox(width: 8.w),
                  const Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ),

          SizedBox(height: 10.h),

          TextButton(
            onPressed: () {
              context.go(AppRoutes.kHomeView);
            },
            child: Text(
              s.backToJobs,
              style: TextStyle(
                color: theme.colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
