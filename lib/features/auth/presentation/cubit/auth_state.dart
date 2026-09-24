

part of 'auth_cubit.dart';


abstract class AuthState {}

class AuthInitial extends AuthState {}

class LoginLoading extends AuthState {}

class LoginSuccess extends AuthState {
  LoginSuccess({required this.loginModel});
  final LoginModel loginModel;
}

class LoginFailure extends AuthState {
  LoginFailure({required this.message});
  final String message;
}

class RegisterLoading extends AuthState {}

class RegisterSuccess extends AuthState {}

class RegisterFailure extends AuthState {
  RegisterFailure({required this.message});
  final String message;
}