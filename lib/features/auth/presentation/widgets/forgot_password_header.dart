import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/utils/app_text_styles.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ForgotPasswordHeader extends StatelessWidget {
  const ForgotPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final isArabic = Directionality.of(context) == TextDirection.rtl;

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
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.lock_reset_rounded,
              color: colorScheme.onPrimary,
              size: 28.sp,
            ),
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          S.of(context).forgotPassword,
          style: AppTextStyles.heading24Bold(
            isArabic: isArabic,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          isArabic
              ? 'أدخل بريدك الإلكتروني المسجل وسنرسل لك رمز تحقق لإعادة تعيين كلمة المرور.'
              : 'Enter your registered email address and we will send you a verification code to reset your password.',
          style: AppTextStyles.body14Regular(
            isArabic: isArabic,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
