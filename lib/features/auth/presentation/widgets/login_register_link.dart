import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginRegisterLink extends StatelessWidget {
  const LoginRegisterLink({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: onPressed,
        child: RichText(
          text: TextSpan(
            text: "Don't have an account? ",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
            children: [
              TextSpan(
                text: 'Create Account',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
