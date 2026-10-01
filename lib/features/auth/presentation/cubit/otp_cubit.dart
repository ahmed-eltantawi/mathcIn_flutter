import 'dart:async';

import 'package:MatchIn/features/auth/domain/use_cases/resend_otp_use_case.dart';
import 'package:MatchIn/features/auth/domain/use_cases/verify_otp_use_case.dart';
import 'package:MatchIn/features/auth/domain/use_cases/verify_password_reset_otp_use_case.dart'; // ضفنا الـ UseCase ده
import 'package:MatchIn/features/auth/presentation/cubit/otp_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// OTP length expected by the authentication backend.
const int kOtpLength = 6;

/// Initial countdown duration in seconds before resend is enabled.
const int _kResendCooldownSeconds = 60;

class OtpCubit extends Cubit<OtpState> {
  OtpCubit({
    required this.verifyOtpUseCase,
    required this.resendOtpUseCase,
    required this.verifyPasswordResetOtpUseCase, // ضفناه في الـ Constructor
  }) : super(const OtpInitial());

  final VerifyOtpUseCase verifyOtpUseCase;
  final ResendOtpUseCase resendOtpUseCase;
  final VerifyPasswordResetOtpUseCase
  verifyPasswordResetOtpUseCase; // ضفناه هنا

  //! ===== Timer State =====

  Timer? _countdownTimer;
  int _secondsRemaining = _kResendCooldownSeconds;
  bool _isVerifying = false;

  // 1. المتغير اللي كان ناقص وعامل الإيرور
  String? resetToken;

  int get secondsRemaining => _secondsRemaining;
  bool get canResend => _secondsRemaining == 0 && !_isVerifying;

  /// Starts (or restarts) the resend cooldown countdown.
  void startTimer() {
    _countdownTimer?.cancel();
    _secondsRemaining = _kResendCooldownSeconds;
    emit(OtpTimerTick(secondsRemaining: _secondsRemaining));

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        emit(OtpTimerTick(secondsRemaining: _secondsRemaining));
      } else {
        timer.cancel();
        emit(const OtpResendAvailable());
      }
    });
  }

  //! ===== OTP Verification =====

  Future<void> verifyOtp({
    required String email,
    required String otp,
    bool isPasswordReset = false, // فلاج عشان نحدد إحنا في أي فلو
  }) async {
    if (_isVerifying) return;
    _isVerifying = true;

    emit(const OtpLoading());

    // 2. بننده الـ UseCase الصح بناءً على إحنا في تسجيل جديد ولا نسيان باسورد
    if (isPasswordReset) {
      final result = await verifyPasswordResetOtpUseCase(
        email: email,
        otp: otp,
      );
      result.fold(
        (failure) {
          _isVerifying = false;
          emit(OtpVerificationError(message: failure.message));
        },
        (token) {
          resetToken = token; // بنخزن التوكن اللي راجع عشان الـ View يشوفه
          emit(const OtpVerificationSuccess());
        },
      );
    } else {
      final result = await verifyOtpUseCase(email: email, otp: otp);
      result.fold((failure) {
        _isVerifying = false;
        emit(OtpVerificationError(message: failure.message));
      }, (_) => emit(const OtpVerificationSuccess()));
    }
  }

  /// Called by the UI when the OTP field's animation resets to idle.
  void onOtpFieldIdle() {
    _isVerifying = false;
  }

  //! ===== Resend OTP =====

  Future<void> resendOtp({required String email}) async {
    if (!canResend) return;
    final result = await resendOtpUseCase(email: email);

    result.fold((failure) => emit(OtpResendError(message: failure.message)), (
      _,
    ) {
      startTimer();
      emit(const OtpResendSuccess());
    });
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    return super.close();
  }
}
