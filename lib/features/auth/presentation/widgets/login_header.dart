import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

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
              Icons.lock_outline_rounded,
              color: Colors.white,
              size: 28.sp,
            ),
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'Welcome Back',
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
          'Sign in to continue your career journey',
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
