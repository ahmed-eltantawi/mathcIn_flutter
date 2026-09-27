import 'package:MatchIn/core/utils/app_assets.dart';
import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/generated/l10n.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = S.of(context);

    return Column(
      children: [
        Image.asset(Assets.appIcon, height: 60.h),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            locale.skillmatchPortal,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          locale.welcomeBack,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: AppColors.midnightBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          locale.accessYourPathways,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
