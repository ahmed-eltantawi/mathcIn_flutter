import 'package:equatable/equatable.dart';

sealed class ChangePasswordState extends Equatable {
  const ChangePasswordState();

  @override
  List<Object?> get props => [];
}

final class ChangePasswordInitial extends ChangePasswordState {
  const ChangePasswordInitial();
}

final class ChangePasswordLoading extends ChangePasswordState {
  const ChangePasswordLoading({this.otpSent = false});

  final bool otpSent;

  @override
  List<Object?> get props => [otpSent];
}

final class ChangePasswordOtpSent extends ChangePasswordState {
  const ChangePasswordOtpSent();
}

final class ChangePasswordSuccess extends ChangePasswordState {
  const ChangePasswordSuccess();
}

final class ChangePasswordFailure extends ChangePasswordState {
  const ChangePasswordFailure({required this.message, this.otpSent = false});

  final String message;
  final bool otpSent;

  @override
  List<Object?> get props => [message, otpSent];
}
