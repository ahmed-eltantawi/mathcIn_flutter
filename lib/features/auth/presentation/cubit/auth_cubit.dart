import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:MatchIn/features/auth/data/models/login_model.dart';
import 'package:MatchIn/features/auth/domain/use_cases/login_use_case.dart';
import 'package:MatchIn/features/auth/domain/use_cases/register_use_case.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
  }) : super(AuthInitial());

  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;

  Future<void> login({required String email, required String password}) async {
    emit(LoginLoading());
    final result = await loginUseCase(email: email, password: password);
    result.fold(
      (failure) => emit(LoginFailure(message: failure.message)),
      (loginModel) => emit(LoginSuccess(loginModel: loginModel)),
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    emit(RegisterLoading());
    final result = await registerUseCase(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    result.fold(
      (failure) => emit(RegisterFailure(message: failure.message)),
      (success) => emit(RegisterSuccess()),
    );
  }
}