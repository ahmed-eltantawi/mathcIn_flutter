import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/application_details_cubit.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/tracking_application_view_widgets/tracking_application_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TrackingApplicationView extends StatelessWidget {
  const TrackingApplicationView({
    super.key,
    required this.job,
    this.applicationId,
  });

  final JobEntity job;
  final String? applicationId;

  @override
  Widget build(BuildContext context) {
    final targetId = applicationId ?? job.id;

    return BlocProvider<ApplicationDetailsCubit>(
      create: (_) => getIt<ApplicationDetailsCubit>()
        ..fetchApplicationDetails(targetId),
      child: Scaffold(
        body: SafeArea(
          top: true,
          bottom: false,
          child: TrackingApplicationViewBody(job: job, applicationId: targetId),
        ),
      ),
    );
  }
}
