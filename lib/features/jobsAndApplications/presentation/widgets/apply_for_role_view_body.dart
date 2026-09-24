import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/core/widgets/cv_file_card.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/cv_cubit.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/cv_state.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/apply_bottom_button.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/apply_header.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/cover_note.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_summary_card.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/user_info.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ApplyForRoleViewBody extends StatelessWidget {
  const ApplyForRoleViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Column(
      children: [
        ApplyHeader(
          title: s.applyForRole,
          currentStep: 1,
          totalSteps: 3,
        ),
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
                const JobSummaryCard(),
                SizedBox(height: 24.h),
                const UserInfo(),
                SizedBox(height: 24.h),
                BlocBuilder<CvCubit, CvState>(
                  buildWhen: (previous, current) {
                    return previous.status !=
                            current.status ||
                        previous.file?.name !=
                            current.file?.name;
                  },
                  builder: (context, state) {
                    switch (state.status) {
                      case CvStatus.empty:
                        return CvFileCard(
                          status: CvFileStatus.empty,
                          onUpload: () {
                            context
                                .read<CvCubit>()
                                .pickCv();
                          },
                        );

                      case CvStatus.picking:
                        return const CvFileCard(
                          status: CvFileStatus.empty,
                        );

                      case CvStatus.selected:
                        return CvFileCard(
                          status: CvFileStatus.uploaded,
                          fileName: state.file?.name,
                          updatedText: s.updatedJustNow,
                          onReplace: () {
                            context
                                .read<CvCubit>()
                                .pickCv();
                          },
                          onEdit: () {
                            context
                                .read<CvCubit>()
                                .pickCv();
                          },
                          onView: () {
                            // CV preview will be connected next.
                          },
                        );

                      case CvStatus.failure:
                        return CvFileCard(
                          status: state.file == null
                              ? CvFileStatus.empty
                              : CvFileStatus.uploaded,
                          fileName: state.file?.name,
                          updatedText: state.file == null
                              ? null
                              : s.updatedJustNow,
                          onUpload: () {
                            context
                                .read<CvCubit>()
                                .pickCv();
                          },
                          onReplace: () {
                            context
                                .read<CvCubit>()
                                .pickCv();
                          },
                        );
                    }
                  },
                ),
                SizedBox(height: 24.h),
                const CoverNote(),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
        ApplyBottomButton(
          label: s.continueText,
          helperText: s.nextApplicationQuestions,
          onPressed: () {
            context.push(AppRoutes.kapplicationQuestions);
          },
        ),
      ],
    );
  }
}
