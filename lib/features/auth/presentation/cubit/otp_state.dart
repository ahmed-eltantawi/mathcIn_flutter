import 'package:equatable/equatable.dart';

abstract class OtpState extends Equatable {
  const OtpState();

  @override
  List<Object?> get props => [];
}

class OtpInitial extends OtpState {
  const OtpInitial();
}

class OtpLoading extends OtpState {
  const OtpLoading();
}

class OtpVerificationSuccess extends OtpState {
  const OtpVerificationSuccess();
}

class OtpVerificationError extends OtpState {
  const OtpVerificationError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class OtpResendSuccess extends OtpState {
  const OtpResendSuccess();
}

class OtpResendError extends OtpState {
  const OtpResendError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Emitted every second while the resend countdown is active.
class OtpTimerTick extends OtpState {
  const OtpTimerTick({required this.secondsRemaining});

  final int secondsRemaining;

  @override
  List<Object?> get props => [secondsRemaining];
}

/// Emitted when the countdown reaches zero — resend is now available.
class OtpResendAvailable extends OtpState {
  const OtpResendAvailable();
}
