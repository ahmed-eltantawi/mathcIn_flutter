part of 'auth_cubit.dart';

@immutable
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class LoginLoading extends AuthState {
  const LoginLoading();
}

final class LoginSuccess extends AuthState {
  const LoginSuccess({required this.loginEntity});
  final LoginEntity loginEntity;

  @override
  List<Object?> get props => [loginEntity];
}

final class LoginFailure extends AuthState {
  const LoginFailure({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}

final class RegisterLoading extends AuthState {
  const RegisterLoading();
}

final class RegisterSuccess extends AuthState {
  const RegisterSuccess();
}

final class RegisterFailure extends AuthState {
  const RegisterFailure({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}

