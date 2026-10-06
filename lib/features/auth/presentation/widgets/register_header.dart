import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:MatchIn/core/utils/app_text_styles.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              Icons.person_add_outlined,
              color: Colors.white,
              size: 28.sp,
            ),
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          S.of(context).createAccount,
          style: AppTextStyles.heading24Bold(
            isArabic: false,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          S.of(context).readyToFindYourNextOpportunity,
          style: AppTextStyles.body14Regular(
            isArabic: false,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
