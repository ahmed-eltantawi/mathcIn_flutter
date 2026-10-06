import 'package:MatchIn/features/auth/domain/use_cases/forgot_password_use_case.dart';
import 'package:MatchIn/features/auth/presentation/cubit/forgot_password_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit({required this.forgotPasswordUseCase})
      : super(const ForgotPasswordInitial());

  final ForgotPasswordUseCase forgotPasswordUseCase;

  Future<void> sendForgotPasswordEmail({required String email}) async {
    emit(const ForgotPasswordLoading());
    final result = await forgotPasswordUseCase(email: email);
    result.fold(
      (failure) => emit(ForgotPasswordFailure(message: failure.message)),
      (_) => emit(const ForgotPasswordSuccess()),
    );
  }
}
