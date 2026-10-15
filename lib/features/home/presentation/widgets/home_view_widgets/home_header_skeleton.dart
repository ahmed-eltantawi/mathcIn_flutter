import 'package:MatchIn/core/functions/show_image.dart';
import 'package:MatchIn/core/utils/app_assets.dart';
import 'package:MatchIn/core/widgets/app_circle_icon_button.dart';
import 'package:MatchIn/core/widgets/loading/app_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeHeaderSkeleton extends StatelessWidget {
  const HomeHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              showImage(image: Assets.iconsTextLogo),
              const Spacer(),
              AppCircleIconButton(
                icon: Icons.notifications_none_rounded,
                onTap: () {},
              ),
              SizedBox(width: 8.w),
              AppCircleIconButton(
                icon: Icons.settings_outlined,
                onTap: () {},
              ),
            ],
          ),
          SizedBox(height: 24.h),
          AppShimmer(
            width: 170.w,
            height: 28.h,
            borderRadius: 6.r,
          ),
          SizedBox(height: 8.h),
          AppShimmer(
            width: 240.w,
            height: 16.h,
            borderRadius: 4.r,
          ),
        ],
      ),
    );
  }
}
