import 'package:MatchIn/core/utils/app_assets.dart';
import 'package:MatchIn/features/auth/presentation/widgets/otp_resend_row.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:otp_animated_fields/otp_animated_fields.dart';

class OtpInputCard extends StatelessWidget {
  const OtpInputCard({
    super.key,
    required this.controller,
    required this.otpLength,
    required this.onCompleted,
    required this.onStatusChanged,
    required this.secondsRemaining,
    required this.canResend,
    required this.onResend,
    this.isSuccess = false,
  });

  final OtpAnimatedController controller;
  final int otpLength;
  final ValueChanged<String> onCompleted;
  final ValueChanged<OtpStatus> onStatusChanged;
  final int secondsRemaining;
  final bool canResend;
  final VoidCallback onResend;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.outline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).verificationCodeLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface,
              letterSpacing: 0.55,
            ),
          ),
          SizedBox(height: 12.h),
          Center(
            child: isSuccess
                ? SizedBox(
                    height: 80.h,
                    child: Lottie.asset(
                      Assets.lottieCorrect,
                      repeat: false,
                    ),
                  )
                : OtpAnimatedField(
                    controller: controller,
                    length: otpLength,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    onCompleted: onCompleted,
                    onStatusChanged: onStatusChanged,
                    semanticLabels: OtpSemanticLabels(
                      field: S.of(context).verificationCodeLabel,
                    ),
                  ),
          ),
          SizedBox(height: 12.h),
          OtpResendRow(
            secondsRemaining: secondsRemaining,
            enabled: canResend,
            onResend: onResend,
          ),
        ],
      ),
    );
  }
}
