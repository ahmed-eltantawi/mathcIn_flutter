import 'package:MatchIn/core/widgets/loading/app_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

///* Profile skeleton matching the overview + section cards layout.
///* Shown only when no cached profile exists; cached data renders instantly.
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppShimmer(width: double.infinity, height: 148.h, borderRadius: 16.r),
        SizedBox(height: 16.h),
        AppShimmer(width: double.infinity, height: 120.h, borderRadius: 16.r),
        SizedBox(height: 16.h),
        AppShimmer(width: double.infinity, height: 120.h, borderRadius: 16.r),
        SizedBox(height: 16.h),
        AppShimmer(width: double.infinity, height: 96.h, borderRadius: 16.r),
      ],
    );
  }
}
