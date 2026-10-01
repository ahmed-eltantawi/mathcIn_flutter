import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/auth/domain/entities/login_entity.dart';
import 'package:MatchIn/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class LoginUseCase {
  const LoginUseCase({required this.repository});

  final AuthRepository repository;

  Future<Either<Failure, LoginEntity>> call({
    required String email,
    required String password,
  }) async {
    return await repository.login(email: email, password: password);
  }
}
