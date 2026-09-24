import 'dart:async';

import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:MatchIn/core/widgets/custom_app_bar.dart';
import 'package:MatchIn/core/widgets/custom_snack_bar.dart';
import 'package:MatchIn/features/auth/presentation/cubit/otp_cubit.dart';
import 'package:MatchIn/features/auth/presentation/cubit/otp_state.dart';
import 'package:MatchIn/features/auth/presentation/widgets/otp_back_button.dart';
import 'package:MatchIn/features/auth/presentation/widgets/otp_header.dart';
import 'package:MatchIn/features/auth/presentation/widgets/otp_input_card.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:otp_animated_fields/otp_animated_fields.dart';

/// OTP length expected by the authentication backend.
const int _kOtpLength = 6;

class OtpVerificationView extends StatefulWidget {
  const OtpVerificationView({super.key, this.email = 'user@example.com'});

  final String email;

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  // -- OTP animated field controller --------------------------------------
  final OtpAnimatedController _otpController = OtpAnimatedController();

  // -- Resend countdown timer ---------------------------------------------
  int _secondsRemaining = 60;
  Timer? _countdownTimer;

  // -- Tracks whether a verification is already in flight ----------------
  bool _isVerifying = false;

  // -- Controls the in-card Lottie success animation ----------------------
  bool _showSuccessLottie = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  // -- Timer helpers -------------------------------------------------------

  void _startTimer() {
    _countdownTimer?.cancel();
    setState(() => _secondsRemaining = 60);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  // -- Resend handler ------------------------------------------------------

  void _onResend() {
    if (_secondsRemaining == 0 && !_isVerifying) {
      context.read<OtpCubit>().resendOtp(email: widget.email);
      _startTimer();
    }
  }

  // -- OTP submission ------------------------------------------------------

  void _onCompleted(String code) {
    if (_isVerifying) return; // prevent duplicate requests
    _isVerifying = true;
    context.read<OtpCubit>().verifyOtp(email: widget.email, otp: code);
  }

  // -- Navigation after success Lottie plays ------------------------------

  Future<void> _onOtpStatusChanged(OtpStatus status) async {
    if (status == OtpStatus.success) {
      // Replace OTP fields with success Lottie inside the card, then navigate.
      setState(() => _showSuccessLottie = true);
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        await getIt<SharedPreferencesService>().setLoggedIn(true);
        if (mounted) {
          context.go(AppRoutes.kHomeView);
        }
      }
    }
    if (status == OtpStatus.idle) {
      // Returned to idle after error � allow re-verification
      setState(() => _isVerifying = false);
    }
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.kLoginView);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<OtpCubit, OtpState>(
      listener: (context, state) {
        if (state is OtpVerificationSuccess) {
          _otpController.succeed();
        } else if (state is OtpVerificationError) {
          _otpController.fail();
          CustomSnackBar.showError(context, message: state.message);
        } else if (state is OtpResendSuccess) {
          _otpController.reset();
          CustomSnackBar.showSuccess(
            context,
            message: S.of(context).resendCode,
          );
        } else if (state is OtpResendError) {
          CustomSnackBar.showError(context, message: state.message);
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: S.of(context).enterVerificationCode,
          onBack: _handleBack,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const OtpHeader(),
                SizedBox(height: 24.h),
                OtpInputCard(
                  controller: _otpController,
                  otpLength: _kOtpLength,
                  onCompleted: _onCompleted,
                  onStatusChanged: _onOtpStatusChanged,
                  secondsRemaining: _secondsRemaining,
                  canResend: !_isVerifying,
                  onResend: _onResend,
                  isSuccess: _showSuccessLottie,
                ),
                SizedBox(height: 24.h),
                OtpBackButton(onPressed: _handleBack),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
