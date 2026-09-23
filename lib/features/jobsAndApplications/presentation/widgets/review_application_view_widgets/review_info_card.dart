import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ReviewInfoCard extends StatelessWidget {
  const ReviewInfoCard({
    super.key,
    required this.title,
    required this.child,
    required this.job,
    this.actionLabel,
  });

  final String title;
  final Widget child;
  final JobEntity job;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                if (actionLabel != null)
                  TextButton(
                    onPressed: () {
                      context.replace(
                        AppRoutes.kapplyForRole,
                        extra: job,
                      );
                    },
                    child: Text(actionLabel!),
                  ),
              ],
            ),
            const Divider(height: 1),
            SizedBox(height: 14.h),
            child,
          ],
        ),
      ),
    );
  }
}
