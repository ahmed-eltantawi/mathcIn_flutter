import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/application_submitted_view_widgets/status_row.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SubmittedStatusCard extends StatelessWidget {
  const SubmittedStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            StatusRow(
              label: s.applicationStatus,
              value: s.applied,
              showDot: true,
            ),
            const Divider(height: 24),
            StatusRow(
              icon: Icons.schedule_outlined,
              label: s.timeline,
              value: s.submittedJustNow,
            ),
            const Divider(height: 24),
            StatusRow(
              icon: Icons.apartment_rounded,
              label: s.recruiterReview,
              value: s.withinThreeBusinessDays,
            ),
          ],
        ),
      ),
    );
  }
}
