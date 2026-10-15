import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/services/google_sign_in_service.dart';
import 'package:MatchIn/features/auth/data/models/login_model.dart';
import 'package:MatchIn/features/auth/domain/repositories/auth_repository.dart';
import 'package:MatchIn/features/auth/domain/use_cases/login_use_case.dart';
import 'package:MatchIn/features/auth/domain/use_cases/login_with_google_use_case.dart';
import 'package:MatchIn/features/auth/domain/use_cases/register_use_case.dart';
import 'package:MatchIn/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeGoogleSignInService extends GoogleSignInService {
  FakeGoogleSignInService({this.result, this.error});

  final GoogleSignInResult? result;
  final Exception? error;
  int signInCalls = 0;
  int signOutCalls = 0;

  @override
  Future<GoogleSignInResult?> signInWithGoogle() async {
    signInCalls++;
    await Future.delayed(const Duration(milliseconds: 50));
    if (error != null) throw error!;
    return result;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
  }
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.googleResult});

  final Either<Failure, LoginModel>? googleResult;

  @override
  Future<Either<Failure, LoginModel>> loginWithGoogle({
    required String idToken,
  }) async {
    return googleResult!;
  }

  @override
  Future<Either<Failure, LoginModel>> login({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> verifyOtp({
    required String email,
    required String otp,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> resendOtp({required String email}) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> forgotPassword({required String email}) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> verifyPasswordResetOtp({
    required String email,
    required String otp,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> resetPassword({
    required String email,
    required String newPassword,
  }) => throw UnimplementedError();
}

AuthCubit buildCubit({
  FakeGoogleSignInService? googleService,
  Either<Failure, LoginModel>? googleResult,
}) {
  final service = googleService ?? FakeGoogleSignInService();
  final repository = FakeAuthRepository(googleResult: googleResult);
  return AuthCubit(
    loginUseCase: LoginUseCase(repository: repository),
    registerUseCase: RegisterUseCase(repository: repository),
    googleSignInService: service,
    loginWithGoogleUseCase: LoginWithGoogleUseCase(repository: repository),
  );
}

void main() {
  group('AuthCubit.signInWithGoogle', () {
    blocTest<AuthCubit, AuthState>(
      'emits [Loading, Cancelled] and keeps Google session when user cancels',
      build: () => buildCubit(
        googleService: FakeGoogleSignInService(result: null),
      ),
      act: (cubit) => cubit.signInWithGoogle(),
      expect: () => [isA<GoogleSignInLoading>(), isA<GoogleSignInCancelled>()],
      verify: (cubit) {
        final service =
            cubit.googleSignInService as FakeGoogleSignInService;
        expect(service.signOutCalls, 0);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'emits [Loading, Failure] and clears Google session on backend failure',
      build: () => buildCubit(
        googleService: FakeGoogleSignInService(
          result: const GoogleSignInResult(
            idToken: 'google-id-token',
            email: 'user@gmail.com',
          ),
        ),
        googleResult: const Left(
          ServerFailure(message: 'Google sign-in is not supported'),
        ),
      ),
      act: (cubit) => cubit.signInWithGoogle(),
      expect: () => [isA<GoogleSignInLoading>(), isA<GoogleSignInFailure>()],
      verify: (cubit) {
        final service =
            cubit.googleSignInService as FakeGoogleSignInService;
        expect(service.signOutCalls, 1);
        final state = cubit.state as GoogleSignInFailure;
        expect(state.message, contains('Google sign-in'));
      },
    );

    blocTest<AuthCubit, AuthState>(
      'emits [Loading, Failure] with offline message on network error',
      build: () => buildCubit(
        googleService: FakeGoogleSignInService(error: OfflineException()),
      ),
      act: (cubit) => cubit.signInWithGoogle(),
      expect: () => [isA<GoogleSignInLoading>(), isA<GoogleSignInFailure>()],
      verify: (cubit) {
        final state = cubit.state as GoogleSignInFailure;
        expect(state.message, const OfflineFailure().message);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'emits [Loading, Success] when backend exchange succeeds',
      build: () => buildCubit(
        googleService: FakeGoogleSignInService(
          result: const GoogleSignInResult(
            idToken: 'google-id-token',
            email: 'user@gmail.com',
          ),
        ),
        googleResult: const Right(
          LoginModel(accessToken: 'app-token', tokenType: 'bearer'),
        ),
      ),
      act: (cubit) => cubit.signInWithGoogle(),
      expect: () => [isA<GoogleSignInLoading>(), isA<GoogleSignInSuccess>()],
    );

    test('duplicate requests share a single Google sign-in attempt', () async {
      final service = FakeGoogleSignInService(
        result: const GoogleSignInResult(
          idToken: 'google-id-token',
          email: 'user@gmail.com',
        ),
      );
      final repository = FakeAuthRepository(
        googleResult: const Right(
          LoginModel(accessToken: 'app-token', tokenType: 'bearer'),
        ),
      );
      final cubit = AuthCubit(
        loginUseCase: LoginUseCase(repository: repository),
        registerUseCase: RegisterUseCase(repository: repository),
        googleSignInService: service,
        loginWithGoogleUseCase: LoginWithGoogleUseCase(
          repository: repository,
        ),
      );
      await Future.wait([cubit.signInWithGoogle(), cubit.signInWithGoogle()]);
      expect(service.signInCalls, 1);
      expect(cubit.state, isA<GoogleSignInSuccess>());
      await cubit.close();
    });
  });
}
