import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/utils/app_assets.dart';
import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class ViewMatchesCardHeader extends StatelessWidget {
  const ViewMatchesCardHeader({super.key, required this.matchesCount});

  final int matchesCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34.r,
          height: 34.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.colors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: SvgPicture.asset(
            Assets.iconsAlIcon,
            width: 20.r,
            height: 20.r,
          ),
        ),

        SizedBox(width: 8.w),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: AppColors.forestGreen.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            '$matchesCount ${context.l10n.matches}',
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.forestGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const Spacer(),

        Container(
          width: 8.r,
          height: 8.r,
          decoration: const BoxDecoration(
            color: AppColors.goldenMustard,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
