import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/job_details_view_body.dart';
import 'package:flutter/material.dart';

class JobDetailsView extends StatelessWidget {
  const JobDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: JobDetailsViewBody()),
    );
  }
}
