import 'package:MatchIn/core/services/secure_storage_service.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:MatchIn/features/auth/domain/entities/login_entity.dart';
import 'package:MatchIn/features/auth/domain/use_cases/login_use_case.dart';
import 'package:MatchIn/features/auth/domain/use_cases/register_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.secureStorageService,
    required this.sharedPreferencesService,
  }) : super(const AuthInitial());

  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final SecureStorageService secureStorageService;
  final SharedPreferencesService sharedPreferencesService;

  Future<void> login({required String email, required String password}) async {
    emit(const LoginLoading());
    final result = await loginUseCase(email: email, password: password);

    await result.fold(
      (failure) async => emit(LoginFailure(message: failure.message)),
      (loginEntity) async {
        // --- Persist JWT tokens in encrypted storage ---
        await secureStorageService.saveTokens(
          accessToken: loginEntity.accessToken,
          refreshToken: loginEntity.refreshToken,
        );

        // --- Persist the full user object + mark as logged in ---
        if (loginEntity.user != null) {
          await sharedPreferencesService.saveUserData(loginEntity.user!);
        }
        await sharedPreferencesService.setLoggedIn();

        emit(LoginSuccess(loginEntity: loginEntity));
      },
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    emit(const RegisterLoading());
    final result = await registerUseCase(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    result.fold(
      (failure) => emit(RegisterFailure(message: failure.message)),
      (_) => emit(const RegisterSuccess()),
    );
  }
}
