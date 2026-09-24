import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/application_submitted_view_body.dart';
import 'package:flutter/material.dart';

class ApplicationSubmittedView extends StatelessWidget {
  const ApplicationSubmittedView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: ApplicationSubmittedViewBody()),
    );
  }
}
