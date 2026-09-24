import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/jobs_info_job_card.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JobDetailsOverviewCard extends StatelessWidget {
  const JobDetailsOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              children: [
                Row(
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
                      child: Text(
                        'TN',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(
                              color:
                                  theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.juniorFlutterDeveloper,
                            style: theme
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'TechNova',
                            style: theme
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: theme
                                      .colorScheme
                                      .onSurface
                                      .withValues(
                                        alpha: 0.6,
                                      ),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                const Divider(height: 1),
                SizedBox(height: 14.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 6.h,
                  children: [
                    JobsInfoJobCard(
                      label: s.cairo,
                      showBorder: true,
                    ),
                    JobsInfoJobCard(
                      label: s.zeroToTwoYears,
                      showBorder: true,
                    ),
                    JobsInfoJobCard(
                      label: s.fullTime,
                      showBorder: true,
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Container(
                      width: 7.r,
                      height: 7.r,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary
                            .withValues(alpha: 0.65),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Expanded(
                      child: Text(
                        '${s.hybrid} • ${s.postedTwoDaysAgo}',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(
                              color: theme
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                      ),
                    ),
                    Text(
                      '${s.source}: LinkedIn',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(
                            color: theme
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 10.h,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(
                alpha: 0.04,
              ),
              border: Border(
                top: BorderSide(color: theme.dividerColor),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 9.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(
                      20.r,
                    ),
                  ),
                  child: Text(
                    '● ${s.applied}',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(
                          color:
                              theme.colorScheme.onPrimary,
                        ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  s.twoDaysAgo,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(8.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 8.h,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          s.viewTimeline,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(
                                color: theme
                                    .colorScheme
                                    .secondary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12.sp,
                          color:
                              theme.colorScheme.secondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
