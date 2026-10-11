part of 'forgot_password_cubit.dart';

@immutable
sealed class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object?> get props => [];
}

final class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
}

final class ForgotPasswordLoading extends ForgotPasswordState {
  const ForgotPasswordLoading();
}

final class ForgotPasswordSuccess extends ForgotPasswordState {
  const ForgotPasswordSuccess({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}

final class ForgotPasswordFailure extends ForgotPasswordState {
  const ForgotPasswordFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
