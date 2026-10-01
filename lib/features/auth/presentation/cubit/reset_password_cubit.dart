import 'package:MatchIn/features/auth/domain/use_cases/reset_password_use_case.dart';
import 'package:MatchIn/features/auth/presentation/cubit/reset_password_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  ResetPasswordCubit({required this.resetPasswordUseCase})
    : super(const ResetPasswordInitial());

  final ResetPasswordUseCase resetPasswordUseCase;

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    emit(const ResetPasswordLoading());

    final result = await resetPasswordUseCase(
      email: email,
      newPassword: newPassword,
    );

    result.fold(
      (failure) => emit(ResetPasswordError(message: failure.message)),
      (_) => emit(const ResetPasswordSuccess()),
    );
  }
}
