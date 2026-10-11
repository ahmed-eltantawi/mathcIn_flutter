import 'package:MatchIn/features/settings/domain/use_cases/change_password_use_case.dart';
import 'package:MatchIn/features/settings/presentation/cubit/change_password_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit({required this.changePasswordUseCase})
      : super(const ChangePasswordInitial());

  final ChangePasswordUseCase changePasswordUseCase;

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    emit(const ChangePasswordLoading());

    final result = await changePasswordUseCase(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    result.fold(
      (failure) => emit(ChangePasswordFailure(message: failure.message)),
      (_) => emit(const ChangePasswordSuccess()),
    );
  }
}
