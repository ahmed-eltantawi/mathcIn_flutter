import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Skeleton placeholders shared by profile fetch states.
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Column(
        children: [
          _SkeletonCard(height: 154.h, rows: 3),
          SizedBox(height: 16.h),
          _SkeletonCard(height: 124.h, rows: 3),
          SizedBox(height: 16.h),
          _SkeletonCard(height: 124.h, rows: 3),
          SizedBox(height: 16.h),
          _SkeletonCard(height: 100.h, rows: 2),
        ],
      ),
    );
  }
}

/// Form-shaped placeholder shown while profile data is loaded for editing.
class ProfileFormSkeleton extends StatelessWidget {
  const ProfileFormSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Edit profile'),
            SizedBox(height: 24.h),
            const _SkeletonCard(height: 96, rows: 2),
            SizedBox(height: 16.h),
            const _SkeletonCard(height: 180, rows: 4),
            SizedBox(height: 16.h),
            const _SkeletonCard(height: 148, rows: 3),
          ],
        ),
      ),
    );
  }
}

/// Reusable content bones; real text gives Skeletonizer meaningful geometry.
class ProfileLoadingSkeleton extends StatelessWidget {
  const ProfileLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Skeletonizer(
    enabled: true,
    child: Padding(
      padding: EdgeInsets.all(16.r),
      child: const _SkeletonCard(height: 132, rows: 3),
    ),
  );
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.height, required this.rows});

  final double height;
  final int rows;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    width: double.infinity,
    child: Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            rows,
            (index) => Text(
              index == 0 ? 'Profile information' : 'Loading profile details',
              maxLines: 1,
            ),
          ),
        ),
      ),
    ),
  );
}
