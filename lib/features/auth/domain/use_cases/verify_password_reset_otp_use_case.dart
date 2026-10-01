import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

///* VerifyPasswordResetOtpUseCase: verifies the OTP and returns the reset_token (step 2).
///* The returned String is the 64-char reset_token required by POST /api/auth/reset-password.
class VerifyPasswordResetOtpUseCase {
  const VerifyPasswordResetOtpUseCase({required this.repository});

  final AuthRepository repository;

  Future<Either<Failure, String>> call({
    required String email,
    required String otp,
  }) async {
    return await repository.verifyPasswordResetOtp(email: email, otp: otp);
  }
}
