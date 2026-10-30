import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/settings/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';

class ChangePasswordUseCase {
  const ChangePasswordUseCase({required this.repository});

  final SettingsRepository repository;

  Future<Either<Failure, Unit>> requestOtp() {
    return repository.requestPasswordChangeOtp();
  }

  Future<Either<Failure, Unit>> confirmWithOtp({
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) {
    return repository.confirmPasswordChange(
      otp: otp,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }

  Future<Either<Failure, Unit>> call({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    return repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}
