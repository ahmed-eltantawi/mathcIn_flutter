import 'package:flutter/foundation.dart';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:MatchIn/features/auth/domain/use_cases/forgot_password_use_case.dart';

part 'forgot_password_state.dart';

///* ForgotPasswordCubit: triggers the forgot-password API (step 1)
///* to send a reset code to the user's email.
class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit({required this.forgotPasswordUseCase})
    : super(const ForgotPasswordInitial());

  final ForgotPasswordUseCase forgotPasswordUseCase;

  Future<void> sendResetCode({required String email}) async {
    emit(const ForgotPasswordLoading());

    final result = await forgotPasswordUseCase(email: email);

    result.fold(
      (failure) => emit(ForgotPasswordFailure(message: failure.message)),
      (_) => emit(ForgotPasswordSuccess(email: email)),
    );
  }
}
