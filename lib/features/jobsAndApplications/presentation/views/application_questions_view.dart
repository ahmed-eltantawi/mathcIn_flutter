import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/application_questions_view_body.dart';
import 'package:flutter/material.dart';

class ApplicationQuestionsView extends StatelessWidget {
  const ApplicationQuestionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: ApplicationQuestionsViewBody()),
    );
  }
}
