import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/tracking_application_view_body.dart';
import 'package:flutter/material.dart';

class TrackingApplicationView extends StatelessWidget {
  const TrackingApplicationView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: TrackingApplicationViewBody()),
    );
  }
}
