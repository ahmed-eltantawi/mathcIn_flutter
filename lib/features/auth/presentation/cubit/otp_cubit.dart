import 'package:MatchIn/features/auth/domain/use_cases/resend_otp_use_case.dart';
import 'package:MatchIn/features/auth/domain/use_cases/verify_otp_use_case.dart';
import 'package:MatchIn/features/auth/domain/use_cases/verify_otp_for_forgot_password_use_case.dart';
import 'package:MatchIn/features/auth/presentation/cubit/otp_state.dart';
import 'package:MatchIn/features/auth/presentation/pages/otp_verification_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OtpCubit extends Cubit<OtpState> {
  OtpCubit({
    required this.verifyOtpUseCase,
    required this.verifyOtpForForgotPasswordUseCase,
    required this.resendOtpUseCase,
  }) : super(const OtpInitial());

  final VerifyOtpUseCase verifyOtpUseCase;
  final VerifyOtpForForgotPasswordUseCase verifyOtpForForgotPasswordUseCase;
  final ResendOtpUseCase resendOtpUseCase;

  Future<void> verifyOtp({
    required String email,
    required String otp,
    required OtpPurpose purpose,
  }) async {
    emit(const OtpLoading());

    final result = switch (purpose) {
      OtpPurpose.register => await verifyOtpUseCase(
        email: email,
        otp: otp,
      ),
      OtpPurpose.forgotPassword => await verifyOtpForForgotPasswordUseCase(
        email: email,
        otp: otp,
      ),
    };

    result.fold(
      (failure) => emit(OtpVerificationError(message: failure.message)),
      (_) => emit(const OtpVerificationSuccess()),
    );
  }

  Future<void> resendOtp({required String email}) async {
    final result = await resendOtpUseCase(email: email.trim());

    result.fold(
      (failure) => emit(OtpResendError(message: failure.message)),
      (_) => emit(const OtpResendSuccess()),
    );
  }
}
