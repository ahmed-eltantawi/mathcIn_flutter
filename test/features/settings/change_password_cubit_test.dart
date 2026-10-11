import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/settings/domain/repositories/settings_repository.dart';
import 'package:MatchIn/features/settings/domain/use_cases/change_password_use_case.dart';
import 'package:MatchIn/features/settings/presentation/cubit/change_password_cubit.dart';
import 'package:MatchIn/features/settings/presentation/cubit/change_password_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSettingsRepository implements SettingsRepository {
  bool shouldSucceed = true;
  String errorMessage = 'Failed';

  @override
  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (shouldSucceed) {
      return const Right(unit);
    } else {
      return Left(ServerFailure(message: errorMessage));
    }
  }

  @override
  Future<Either<Failure, String>> getLanguageCode() async => const Right('en');

  @override
  Future<Either<Failure, bool>> getNotificationPreference() async =>
      const Right(true);

  @override
  Future<Either<Failure, String>> getThemeMode() async =>
      const Right('system');

  @override
  Future<Either<Failure, Unit>> logout() async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> setLanguageCode(String languageCode) async =>
      const Right(unit);

  @override
  Future<Either<Failure, Unit>> setNotificationPreference(bool enabled) async =>
      const Right(unit);

  @override
  Future<Either<Failure, Unit>> setThemeMode(String themeMode) async =>
      const Right(unit);
}

void main() {
  late _FakeSettingsRepository fakeRepository;
  late ChangePasswordUseCase changePasswordUseCase;
  late ChangePasswordCubit cubit;

  setUp(() {
    fakeRepository = _FakeSettingsRepository();
    changePasswordUseCase = ChangePasswordUseCase(repository: fakeRepository);
    cubit = ChangePasswordCubit(changePasswordUseCase: changePasswordUseCase);
  });

  group('ChangePasswordCubit Unit Tests', () {
    test('initial state is ChangePasswordInitial', () {
      expect(cubit.state, isA<ChangePasswordInitial>());
    });

    test('emits [Loading, Success] when changePassword succeeds', () async {
      fakeRepository.shouldSucceed = true;

      final expectedStates = [
        isA<ChangePasswordLoading>(),
        isA<ChangePasswordSuccess>(),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.changePassword(
        currentPassword: 'OldPassword123!',
        newPassword: 'NewPassword123!',
        confirmPassword: 'NewPassword123!',
      );
    });

    test('emits [Loading, Failure] when changePassword fails', () async {
      fakeRepository.shouldSucceed = false;
      fakeRepository.errorMessage = 'Incorrect current password';

      final expectedStates = [
        isA<ChangePasswordLoading>(),
        isA<ChangePasswordFailure>().having(
          (s) => s.message,
          'message',
          'Incorrect current password',
        ),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.changePassword(
        currentPassword: 'WrongPassword123!',
        newPassword: 'NewPassword123!',
        confirmPassword: 'NewPassword123!',
      );
    });
  });
}
