import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/auth/domain/repositories/auth_repository.dart';
import 'package:MatchIn/features/auth/data/models/login_model.dart';
import 'package:dartz/dartz.dart';

class LoginWithGoogleUseCase {
  const LoginWithGoogleUseCase({required this.repository});

  final AuthRepository repository;

  Future<Either<Failure, LoginModel>> call({required String idToken}) {
    return repository.loginWithGoogle(idToken: idToken);
  }
}
