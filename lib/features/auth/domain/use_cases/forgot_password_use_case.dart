import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class ForgotPasswordUseCase {
  const ForgotPasswordUseCase({required this.repository});

  final AuthRepository repository;

  Future<Either<Failure, Unit>> call({required String email}) {
    return repository.forgotPassword(email: email);
  }
}
