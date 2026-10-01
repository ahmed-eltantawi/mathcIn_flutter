import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class ResetPasswordUseCase {
  const ResetPasswordUseCase({required this.repository});

  final AuthRepository repository;

  Future<Either<Failure, Unit>> call({
    required String email,
    required String newPassword,
  }) async {
    return await repository.resetPassword(
      email: email,
      newPassword: newPassword,
    );
  }
}
