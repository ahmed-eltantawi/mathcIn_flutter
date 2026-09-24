import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/review_application_view_body.dart';
import 'package:flutter/material.dart';

class ReviewApplicationView extends StatelessWidget {
  const ReviewApplicationView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: ReviewApplicationViewBody()),
    );
  }
}
