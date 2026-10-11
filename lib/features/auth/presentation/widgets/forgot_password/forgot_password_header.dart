import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:MatchIn/core/extensions/context_extensions.dart';

class ForgotPasswordHeader extends StatelessWidget {
  const ForgotPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final locale = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locale.forgotPasswordTitle,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: colors.primary,
            letterSpacing: -0.6,
            height: 32 / 24,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          locale.forgotPasswordSubtitle,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: colors.onSurface.withValues(alpha: 0.6),
            height: 20 / 14,
          ),
        ),
      ],
    );
  }
}
