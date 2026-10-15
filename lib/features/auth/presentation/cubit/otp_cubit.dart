import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/auth/domain/use_cases/forgot_password_use_case.dart';
import 'package:MatchIn/features/auth/domain/use_cases/resend_otp_use_case.dart';
import 'package:MatchIn/features/auth/domain/use_cases/verify_otp_use_case.dart';
import 'package:MatchIn/features/auth/domain/use_cases/verify_password_reset_otp_use_case.dart';
import 'package:MatchIn/features/auth/presentation/cubit/otp_constants.dart';
import 'package:MatchIn/features/auth/presentation/cubit/otp_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OtpCubit extends Cubit<OtpState> {
  OtpCubit({
    required this.verifyOtpUseCase,
    required this.resendOtpUseCase,
    required this.forgotPasswordUseCase,
    required this.verifyPasswordResetOtpUseCase,
  }) : super(const OtpInitial());

  final VerifyOtpUseCase verifyOtpUseCase;
  final ResendOtpUseCase resendOtpUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final VerifyPasswordResetOtpUseCase verifyPasswordResetOtpUseCase;

  Future<void> verifyOtp({required String email, required String otp}) async {
    // --- Prevent duplicate API requests from rapid repeated submissions. ---
    if (state is OtpLoading) return;
    emit(const OtpLoading());

    try {
      // --- Run the API request and the minimum animation timer together so
      // --- fast responses still keep the verifying orbit visible. ---
      final List<dynamic> results = await Future.wait([
        verifyOtpUseCase(email: email, otp: otp),
        Future.delayed(OtpConstants.minVerifyingDuration),
      ]);
      if (isClosed) return;

      final Either<Failure, Unit> result =
          results.first as Either<Failure, Unit>;
      result.fold(
        (failure) => emit(OtpVerificationError(message: failure.message)),
        (_) => emit(const OtpVerificationSuccess()),
      );
    } catch (e) {
      if (isClosed) return;
      emit(OtpVerificationError(message: e.toString()));
    }
  }

  Future<void> resendOtp({required String email}) async {
    final result = await resendOtpUseCase(email: email);

    result.fold(
      (failure) => emit(OtpResendError(message: failure.message)),
      (_) => emit(const OtpResendSuccess()),
    );
  }

  Future<void> requestPasswordReset({required String email}) async {
    final result = await forgotPasswordUseCase(email: email);

    result.fold(
      (failure) => emit(OtpResendError(message: failure.message)),
      (_) => emit(const OtpResendSuccess()),
    );
  }

  Future<void> verifyPasswordResetOtp({
    required String email,
    required String otp,
  }) async {
    // --- Prevent duplicate API requests from rapid repeated submissions. ---
    if (state is OtpLoading) return;
    emit(const OtpLoading());

    try {
      // --- Run the API request and the minimum animation timer together so
      // --- fast responses still keep the verifying orbit visible. ---
      final List<dynamic> results = await Future.wait([
        verifyPasswordResetOtpUseCase(email: email, otp: otp),
        Future.delayed(OtpConstants.minVerifyingDuration),
      ]);
      if (isClosed) return;

      final Either<Failure, Unit> result =
          results.first as Either<Failure, Unit>;
      result.fold(
        (failure) => emit(OtpVerificationError(message: failure.message)),
        (_) => emit(const OtpVerificationSuccess()),
      );
    } catch (e) {
      if (isClosed) return;
      emit(OtpVerificationError(message: e.toString()));
    }
  }
}
