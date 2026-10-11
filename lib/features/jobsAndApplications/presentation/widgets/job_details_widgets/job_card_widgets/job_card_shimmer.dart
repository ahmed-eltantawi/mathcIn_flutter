import 'package:MatchIn/core/widgets/loading/app_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

///* JobCardShimmer — skeleton placeholder that mirrors the layout of a real
///* [JobCard]. Use it while the jobs are loading to avoid a blank screen.
class JobCardShimmer extends StatelessWidget {
  const JobCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: avatar + two lines
            Row(
              children: [
                AppShimmer(width: 44.r, height: 44.r, borderRadius: 8),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppShimmer(width: 100.w, height: 12.h),
                      SizedBox(height: 6.h),
                      AppShimmer(width: 160.w, height: 16.h),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            // Chips row
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                AppShimmer(width: 80.w, height: 26.h, borderRadius: 20),
                AppShimmer(width: 70.w, height: 26.h, borderRadius: 20),
                AppShimmer(width: 60.w, height: 26.h, borderRadius: 20),
              ],
            ),
            SizedBox(height: 10.h),
            AppShimmer(width: 90.w, height: 12.h),
            SizedBox(height: 14.h),
            // Skills row
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: [
                AppShimmer(width: 55.w, height: 24.h, borderRadius: 12),
                AppShimmer(width: 65.w, height: 24.h, borderRadius: 12),
                AppShimmer(width: 48.w, height: 24.h, borderRadius: 12),
              ],
            ),
            SizedBox(height: 16.h),
            Divider(height: 1.h),
            SizedBox(height: 14.h),
            Row(
              children: [
                AppShimmer(width: 80.w, height: 30.h, borderRadius: 15),
                const Spacer(),
                AppShimmer(width: 110.w, height: 42.h, borderRadius: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

///* JobFeedShimmerList — a staggered list of [JobCardShimmer] placeholders.
class JobFeedShimmerList extends StatelessWidget {
  const JobFeedShimmerList({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: Column(
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 300),
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 16,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            for (int i = 0; i < count; i++) ...[
              const JobCardShimmer(),
              SizedBox(height: 12.h),
            ],
          ],
        ),
      ),
    );
  }
}
