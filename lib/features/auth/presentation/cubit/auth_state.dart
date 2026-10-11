part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

//! ===== Login States =====

class LoginLoading extends AuthState {
  const LoginLoading();
}

class LoginSuccess extends AuthState {
  const LoginSuccess({required this.loginModel});

  final LoginModel loginModel;

  @override
  List<Object?> get props => [loginModel];
}

class LoginFailure extends AuthState {
  const LoginFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

//! ===== Register States =====

class RegisterLoading extends AuthState {
  const RegisterLoading();
}

class RegisterSuccess extends AuthState {
  const RegisterSuccess();
}

class RegisterFailure extends AuthState {
  const RegisterFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}