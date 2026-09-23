import 'package:MatchIn/core/widgets/matching_status/matching_status.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class JobSummaryCard extends StatelessWidget {
  const JobSummaryCard({super.key, required this.job});

  final JobEntity job;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 58.w,
                  height: 58.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme
                        .colorScheme
                        .surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(
                      10.r,
                    ),
                    border: Border.all(
                      color: theme.dividerColor,
                    ),
                  ),
                  child: Icon(
                    Icons.hub_outlined,
                    color: theme.colorScheme.primary,
                    size: 28.sp,
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: theme.textTheme.titleLarge
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Gap(4.h),
                      Text(
                        job.companyName,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(
                              color: theme
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.65),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                Gap(8.w),
                MatchingStatus(
                  percentage: job.matchPercentage,
                ),
              ],
            ),
            Gap(16.h),
            const Divider(height: 1),
            Gap(14.h),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 18.sp,
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.7),
                ),
                Gap(4.w),
                Expanded(
                  child: Text(
                    '${job.location} • '
                    '${job.workMode} • '
                    '${job.employmentType}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme
                        .colorScheme
                        .surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(
                      6.r,
                    ),
                  ),
                  child: Text(
                    job.experienceLevel,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(
                          color:
                              theme.colorScheme.onSurface,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
