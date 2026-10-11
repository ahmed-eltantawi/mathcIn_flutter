import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ForgotPasswordHeader extends StatelessWidget {
  const ForgotPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).forgotPasswordTitle,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
            letterSpacing: -0.6,
            height: 32 / 24,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          S.of(context).forgotPasswordSubtitle,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            height: 20 / 14,
          ),
        ),
      ],
    );
  }
}
