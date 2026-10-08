import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/settings/data/data_sources/settings_local_data_source.dart';
import 'package:MatchIn/features/settings/data/data_sources/settings_remote_data_source.dart';
import 'package:MatchIn/features/settings/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  final SettingsLocalDataSource localDataSource;
  final SettingsRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, bool>> getNotificationPreference() async {
    try {
      final isEnabled = await localDataSource.getNotificationPreference();
      return Right(isEnabled);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> setNotificationPreference(bool enabled) async {
    try {
      await localDataSource.setNotificationPreference(enabled);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getLanguageCode() async {
    try {
      final code = await localDataSource.getLanguageCode();
      return Right(code);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> setLanguageCode(String languageCode) async {
    try {
      await localDataSource.setLanguageCode(languageCode);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getThemeMode() async {
    try {
      final mode = await localDataSource.getThemeMode();
      return Right(mode);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> setThemeMode(String themeMode) async {
    try {
      await localDataSource.setThemeMode(themeMode);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
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
  Future<Either<Failure, Unit>> logout() async {
    try {
      await localDataSource.logout();
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
