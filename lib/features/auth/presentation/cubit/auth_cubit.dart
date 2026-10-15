import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/services/google_sign_in_service.dart';
import 'package:MatchIn/features/auth/data/models/login_model.dart';
import 'package:MatchIn/features/auth/domain/use_cases/login_use_case.dart';
import 'package:MatchIn/features/auth/domain/use_cases/login_with_google_use_case.dart';
import 'package:MatchIn/features/auth/domain/use_cases/register_use_case.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.googleSignInService,
    required this.loginWithGoogleUseCase,
  }) : super(AuthInitial());

  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final GoogleSignInService googleSignInService;
  final LoginWithGoogleUseCase loginWithGoogleUseCase;

  bool _isGoogleSignInInProgress = false;

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

  Future<void> signInWithGoogle() async {
    // --- Prevent duplicate requests from rapid repeated taps ---
    if (_isGoogleSignInInProgress || state is GoogleSignInLoading) return;
    _isGoogleSignInInProgress = true;
    emit(GoogleSignInLoading());
    try {
      final googleResult = await googleSignInService.signInWithGoogle();
      // --- User cancellation navigates nowhere and shows no success ---
      if (googleResult == null) {
        emit(GoogleSignInCancelled());
        return;
      }
      final exchangeResult = await loginWithGoogleUseCase(
        idToken: googleResult.idToken,
      );
      await exchangeResult.fold(
        (failure) async {
          // --- Backend rejected the exchange: clear the Google session so
          // --- no misleading signed-in state is left behind ---
          try {
            await googleSignInService.signOut();
          } catch (_) {
            // Intentionally ignored; the failure below is authoritative.
          }
          emit(GoogleSignInFailure(message: failure.message));
        },
        (loginModel) async {
          emit(GoogleSignInSuccess(loginModel: loginModel));
        },
      );
    } on OfflineException {
      emit(GoogleSignInFailure(message: const OfflineFailure().message));
    } on ServerException catch (e) {
      emit(GoogleSignInFailure(message: e.errorModel.errorMessage));
    } catch (e) {
      emit(GoogleSignInFailure(message: e.toString()));
    } finally {
      _isGoogleSignInInProgress = false;
    }
  }
}