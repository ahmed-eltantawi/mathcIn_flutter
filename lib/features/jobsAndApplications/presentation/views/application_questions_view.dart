import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/application_questions_view_widgets/application_questions_view_body.dart';
import 'package:flutter/material.dart';

class ApplicationQuestionsView extends StatelessWidget {
  const ApplicationQuestionsView({
    super.key,
    required this.job,
  });

  final JobEntity job;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ApplicationQuestionsViewBody(job: job),
      ),
    );
  }
}
