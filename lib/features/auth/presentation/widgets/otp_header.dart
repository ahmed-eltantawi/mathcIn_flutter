import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OtpHeader extends StatelessWidget {
  const OtpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(
              Icons.verified_user_outlined,
              color: colorScheme.onPrimary,
              size: 28.sp,
            ),
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          S.of(context).enterVerificationCode,
          style: theme.textTheme.headlineLarge,
        ),
        SizedBox(height: 4.h),
        Text(
          S.of(context).sentCodeToEmail,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
