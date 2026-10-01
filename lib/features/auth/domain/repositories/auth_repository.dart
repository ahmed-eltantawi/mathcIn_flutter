import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/auth/data/models/login_model.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Failure, Unit>> verifyOtp({
    required String email,
    required String otp,
  });

  Future<Either<Failure, Unit>> resendOtp({required String email});

  Future<Either<Failure, Unit>> resetPassword({
    required String email,
    required String newPassword,
  });
  Future<Either<Failure, Unit>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  Future<Either<Failure, LoginModel>> login({
    required String email,
    required String password,
  });
}
