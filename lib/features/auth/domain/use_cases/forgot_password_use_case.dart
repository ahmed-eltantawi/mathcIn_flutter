import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

///* ForgotPasswordUseCase: sends a password reset code to the given email (step 1).
class ForgotPasswordUseCase {
  const ForgotPasswordUseCase({required this.repository});

  final AuthRepository repository;

  Future<Either<Failure, Unit>> call({required String email}) async {
    return await repository.forgotPassword(email: email);
  }
}
