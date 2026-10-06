part of 'otp_cubit.dart';

@immutable
sealed class OtpState extends Equatable {
  const OtpState();

  @override
  List<Object?> get props => [];
}

final class OtpInitial extends OtpState {
  const OtpInitial();
}

final class OtpLoading extends OtpState {
  const OtpLoading();
}

final class OtpVerificationSuccess extends OtpState {
  const OtpVerificationSuccess({this.resetToken});

  final String? resetToken;

  @override
  List<Object?> get props => [resetToken];
}

final class OtpVerificationError extends OtpState {
  const OtpVerificationError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

final class OtpResendSuccess extends OtpState {
  const OtpResendSuccess();
}

final class OtpResendError extends OtpState {
  const OtpResendError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Emitted every second while the resend countdown is active.
final class OtpTimerTick extends OtpState {
  const OtpTimerTick({required this.secondsRemaining});

  final int secondsRemaining;

  @override
  List<Object?> get props => [secondsRemaining];
}

/// Emitted when the countdown reaches zero — resend is now available.
final class OtpResendAvailable extends OtpState {
  const OtpResendAvailable();
}

