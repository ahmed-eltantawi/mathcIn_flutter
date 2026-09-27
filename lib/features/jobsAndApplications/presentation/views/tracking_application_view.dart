import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/tracking_application_view_widgets/tracking_application_view_body.dart';
import 'package:flutter/material.dart';

class TrackingApplicationView extends StatelessWidget {
  const TrackingApplicationView({
    super.key,
    required this.job,
  });
  final JobEntity job;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: TrackingApplicationViewBody(job: job),
      ),
    );
  }
}
