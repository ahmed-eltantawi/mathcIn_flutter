import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/application_submitted_view_widgets/application_submitted_view_body.dart';
import 'package:flutter/material.dart';

class ApplicationSubmittedView extends StatelessWidget {
  const ApplicationSubmittedView({
    super.key,
    required this.job,
  });
  final JobEntity job;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ApplicationSubmittedViewBody(job: job),
      ),
    );
  }
}
