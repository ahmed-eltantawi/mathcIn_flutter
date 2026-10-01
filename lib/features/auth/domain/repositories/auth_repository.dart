import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/auth/domain/entities/login_entity.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Failure, Unit>> verifyOtp({
    required String email,
    required String otp,
  });

  Future<Either<Failure, Unit>> resendOtp({required String email});

  Future<Either<Failure, Unit>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  Future<Either<Failure, LoginEntity>> login({
    required String email,
    required String password,
  });

  // دوال الباسورد الجديدة
  Future<Either<Failure, Unit>> forgotPassword({required String email});

  Future<Either<Failure, String>> verifyPasswordResetOtp({
    required String email,
    required String otp,
  });

  Future<Either<Failure, Unit>> resetPassword({
    required String email,
    required String resetToken,
    required String password,
    required String passwordConfirmation,
  });
}
