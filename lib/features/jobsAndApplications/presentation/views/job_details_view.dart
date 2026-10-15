import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/job_details_view_body.dart';
import 'package:flutter/material.dart';

class JobDetailsView extends StatelessWidget {
  const JobDetailsView({super.key, required this.job, this.heroPrefix = 'feed'});
  final JobEntity job;

  /// Originating list prefix for scoped Hero tags.
  final String heroPrefix;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: JobDetailsViewBody(job: job, heroPrefix: heroPrefix),
      ),
    );
  }
}
