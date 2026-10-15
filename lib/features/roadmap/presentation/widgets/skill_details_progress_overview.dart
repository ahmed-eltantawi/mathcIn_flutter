import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_node.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SkillDetailsProgressOverview extends StatelessWidget {
  const SkillDetailsProgressOverview({super.key, required this.node});

  final RoadmapNode node;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;
    final l10n = context.l10n;

    final completedCount = node.completedTasksCount;
    final totalCount = node.totalTasksCount;
    final progressRatio = node.progressRatio;
    final percentageInt = (progressRatio * 100).toInt();

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.outline, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  totalCount > 0
                      ? '$completedCount / $totalCount ${l10n.tasksCompleted}'
                      : (node.status == RoadmapTaskStatus.completed
                            ? l10n.skillCompleted
                            : l10n.skillInProgress),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ),
              Text(
                '$percentageInt%',
                style: textTheme.titleSmall?.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: progressRatio,
              minHeight: 10.h,
              backgroundColor: colors.outline.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
