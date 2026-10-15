import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/apply_to_job_cubit.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/review_application_view_widgets/review_application_view_body.dart';

class ReviewApplicationView extends StatelessWidget {
  const ReviewApplicationView({
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
  Widget build(BuildContext context) {
    return BlocProvider<ApplyToJobCubit>(
      create: (_) => getIt<ApplyToJobCubit>(),
      child: Scaffold(
        body: SafeArea(
          top: true,
          bottom: false,
          child: ReviewApplicationViewBody(
            job: job,
            coverLetter: coverLetter,
            cvFileName: cvFileName,
            cvFileSize: cvFileSize,
          ),
        ),
      ),
    );
  }
}
