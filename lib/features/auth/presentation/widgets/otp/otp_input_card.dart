import 'package:MatchIn/core/utils/app_assets.dart';
import 'package:MatchIn/features/auth/presentation/cubit/otp_cubit.dart';
import 'package:MatchIn/features/auth/presentation/widgets/otp/otp_resend_row.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:otp_animated_fields/otp_animated_fields.dart';

/// OtpInputCard owns the [OtpAnimatedController] (a rendering-layer object)
/// and reacts to [OtpCubit] state to drive the field's animations.
/// This keeps the rendering concern out of the Cubit while allowing the
/// view to remain a pure [StatelessWidget].
class OtpInputCard extends StatefulWidget {
  const OtpInputCard({
    required this.isPasswordReset,
    super.key,
    required this.email,
    required this.onSuccessAnimationDone,
  });
  final bool isPasswordReset;

  /// Email forwarded to the cubit for API calls.
  final String email;

  /// Called after the success Lottie animation completes so the parent
  /// view can navigate away.
  final VoidCallback onSuccessAnimationDone;

  @override
  State<OtpInputCard> createState() => _OtpInputCardState();
}

class _OtpInputCardState extends State<OtpInputCard> {
  // OtpAnimatedController is a rendering object — lives here, not in the Cubit.
  final OtpAnimatedController _otpController = OtpAnimatedController();
  bool _showSuccessLottie = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _onCompleted(String code) {
    context.read<OtpCubit>().verifyOtp(
      email: widget.email,
      otp: code,
      isPasswordReset: widget.isPasswordReset,
    );
  }

  Future<void> _onStatusChanged(OtpStatus status) async {
    if (status == OtpStatus.success) {
      setState(() => _showSuccessLottie = true);
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) widget.onSuccessAnimationDone();
    }
    if (status == OtpStatus.idle && mounted) {
      // Capture cubit before the suspension point is safe here because
      // this branch has no await — mounted guard keeps it correct.
      context.read<OtpCubit>().onOtpFieldIdle();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<OtpCubit, OtpState>(
      listener: (context, state) {
        if (state is OtpVerificationSuccess) {
          _otpController.succeed();
        } else if (state is OtpVerificationError) {
          _otpController.fail();
        } else if (state is OtpResendSuccess) {
          _otpController.reset();
        }
      },
      child: BlocBuilder<OtpCubit, OtpState>(
        buildWhen: (prev, curr) =>
            curr is OtpTimerTick || curr is OtpResendAvailable,
        builder: (context, state) {
          final cubit = context.read<OtpCubit>();
          final secondsRemaining = state is OtpTimerTick
              ? state.secondsRemaining
              : cubit.secondsRemaining;

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
                  child: _showSuccessLottie
                      ? SizedBox(
                          height: 80.h,
                          child: Lottie.asset(
                            Assets.lottieCorrect,
                            repeat: false,
                          ),
                        )
                      : OtpAnimatedField(
                          controller: _otpController,
                          length: kOtpLength,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          onCompleted: _onCompleted,
                          onStatusChanged: _onStatusChanged,
                          semanticLabels: OtpSemanticLabels(
                            field: S.of(context).verificationCodeLabel,
                          ),
                        ),
                ),
                SizedBox(height: 12.h),
                OtpResendRow(
                  secondsRemaining: secondsRemaining,
                  enabled: cubit.canResend,
                  onResend: () =>
                      context.read<OtpCubit>().resendOtp(email: widget.email),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
