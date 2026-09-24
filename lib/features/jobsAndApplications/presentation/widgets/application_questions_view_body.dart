import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/apply_bottom_button.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/apply_header.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_info_details.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/portfolio_link.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/question_card.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/technology_option.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/upload_document.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/work_mode_option.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ApplicationQuestionsViewBody extends StatelessWidget {
  const ApplicationQuestionsViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return Column(
      children: [
        ApplyHeader(
          title: s.applicationQuestions,
          currentStep: 2,
          totalSteps: 3,
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 18.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                JobInfoDetails(
                  label:
                      '${s.juniorFlutterDeveloper} • TechNova',
                ),
                SizedBox(height: 14.h),
                Text(
                  s.aFewMoreQuestions,
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                SizedBox(height: 8.h),
                Text(
                  s.answerEmployerQuestions,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.65),
                      ),
                ),
                SizedBox(height: 24.h),

                QuestionCard(
                  title: s.whyInterestedRequired,
                  child: TextField(
                    maxLines: 4,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: s.whyInterestedHint,
                      counterText: '0 / 500',
                    ),
                  ),
                ),

                SizedBox(height: 14.h),

                QuestionCard(
                  title: s.expectedMonthlySalary,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: s.salaryHint,
                      suffixText: 'EGP',
                      helperText: s.salaryHelper,
                    ),
                  ),
                ),

                SizedBox(height: 14.h),

                QuestionCard(
                  title: s.preferredWorkMode,
                  child: Column(
                    children: [
                      WorkModeOption(
                        label: s.remote,
                        isSelected: false,
                      ),
                      SizedBox(height: 8.h),
                      WorkModeOption(
                        label: s.hybrid,
                        isSelected: true,
                        badge: s.popular,
                      ),
                      SizedBox(height: 8.h),
                      WorkModeOption(
                        label: s.onSite,
                        isSelected: false,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 14.h),

                QuestionCard(
                  title: s.technologiesWorkedWith,
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                    childAspectRatio: 2.8,
                    children: const [
                      TechnologyOption(
                        label: 'Flutter',
                        isSelected: true,
                      ),
                      TechnologyOption(
                        label: 'REST APIs',
                        isSelected: true,
                      ),
                      TechnologyOption(
                        label: 'Firebase',
                        isSelected: false,
                      ),
                      TechnologyOption(
                        label: 'Testing',
                        isSelected: false,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 14.h),

                const UploadDocument(),

                SizedBox(height: 14.h),

                const PortfolioLink(),

                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),

        ApplyBottomButton(
          label: s.reviewApplication,
          helperText: s.reviewBeforeSubmission,
          onPressed: () {
            context.push(AppRoutes.kreviewApplication);
          },
        ),
      ],
    );
  }
}
