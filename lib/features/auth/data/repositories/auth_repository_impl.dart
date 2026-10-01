import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/networking/network_info.dart';
import 'package:MatchIn/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:MatchIn/features/auth/data/models/login_model.dart';
import 'package:MatchIn/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, Unit>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      await remoteDataSource.verifyOtp(email: email, otp: otp);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.errorModel.errorMessage));
    } on OfflineException {
      return const Left(OfflineFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> resendOtp({required String email}) async {
    try {
      await remoteDataSource.resendOtp(email: email);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.errorModel.errorMessage));
    } on OfflineException {
      return const Left(OfflineFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.resetPassword(
        email: email,
        newPassword: newPassword,
      );
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.errorModel.errorMessage));
    } on OfflineException {
      return const Left(OfflineFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.errorModel.errorMessage));
    } on OfflineException {
      return const Left(OfflineFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LoginModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final loginModel = await remoteDataSource.login(
        email: email,
        password: password,
      );
      return Right(loginModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.errorModel.errorMessage));
    } on OfflineException {
      return const Left(OfflineFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}