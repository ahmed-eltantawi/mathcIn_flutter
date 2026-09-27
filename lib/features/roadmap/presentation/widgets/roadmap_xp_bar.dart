import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_node.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RoadmapXpBar extends StatelessWidget {
  const RoadmapXpBar({
    super.key,
    required this.nodes,
    this.collectedTreasures = const {},
    this.rewardedAdXp = 0,
  });

  final List<RoadmapNode> nodes;
  final Set<int> collectedTreasures;
  final int rewardedAdXp;

  @override
  Widget build(BuildContext context) {
    int currentXp = 0;
    int totalXp = 0;

    for (final node in nodes) {
      final nodeXp = node.xp ?? 100;
      totalXp += nodeXp;
      if (node.status == RoadmapTaskStatus.completed) {
        currentXp += nodeXp;
      }
    }

    // Data-driven 5-node milestone XP reward addition
    final totalMilestones = nodes.length ~/ 5;
    totalXp += totalMilestones * 50;

    final earnedMilestonesXp = collectedTreasures.length * 50;
    currentXp += earnedMilestonesXp;

    // Add bonus XP earned from rewarded ads
    currentXp += rewardedAdXp;

    final double progress = (totalXp > 0)
        ? (currentXp / totalXp).clamp(0.0, 1.0)
        : 0.0;
    final int percentage = (progress * 100).round();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: context.theme.dividerColor.withValues(alpha: 0.6),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // XP Badge / Title
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.bolt_rounded,
                      color: context.colors.primary,
                      size: 20.r,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Roadmap Progress',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: context.colors.onSurface,
                    ),
                  ),
                ],
              ),

              // XP Numbers & Percentage
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$currentXp',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: context.colors.primary,
                      ),
                    ),
                    TextSpan(
                      text: ' / $totalXp XP ',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    TextSpan(
                      text: '($percentage%)',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // Progress Bar Track
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: SizedBox(
              height: 10.h,
              child: Stack(
                children: [
                  // Track background
                  Container(
                    width: double.infinity,
                    color: context.theme.dividerColor.withValues(alpha: 0.3),
                  ),

                  // Progress fill
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.colors.primary,
                            context.colors.primary.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
