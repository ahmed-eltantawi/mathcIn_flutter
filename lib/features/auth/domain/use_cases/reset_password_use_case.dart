import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class ResetPasswordUseCase {
  const ResetPasswordUseCase({required this.repository});

  final AuthRepository repository;

  Future<Either<Failure, Unit>> call({
    required String email,
    required String resetToken,
    required String password,
    required String passwordConfirmation,
  }) async {
    return await repository.resetPassword(
      email: email,
      resetToken: resetToken,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
}
