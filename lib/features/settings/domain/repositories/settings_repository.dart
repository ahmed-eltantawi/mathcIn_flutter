import 'package:MatchIn/core/errors/failures.dart';
import 'package:dartz/dartz.dart';

abstract class SettingsRepository {
  Future<Either<Failure, bool>> getNotificationPreference();

  Future<Either<Failure, Unit>> setNotificationPreference(bool enabled);

  Future<Either<Failure, String>> getLanguageCode();

  Future<Either<Failure, Unit>> setLanguageCode(String languageCode);

  Future<Either<Failure, String>> getThemeMode();

  Future<Either<Failure, Unit>> setThemeMode(String themeMode);

  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });

  Future<Either<Failure, Unit>> logout();
}
