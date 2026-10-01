import 'package:MatchIn/core/utils/app_colors.dart';
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
          'Create Account',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.6,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Join MatchIn to explore personalized career opportunities',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
