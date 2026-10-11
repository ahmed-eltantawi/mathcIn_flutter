import 'package:MatchIn/features/jobsAndApplications/domain/entities/application_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ApplyToJobState extends Equatable {
  const ApplyToJobState();

  @override
  List<Object?> get props => [];
}

class ApplyToJobInitial extends ApplyToJobState {
  const ApplyToJobInitial();
}

class ApplyToJobSubmitting extends ApplyToJobState {
  const ApplyToJobSubmitting();
}

class ApplyToJobSuccess extends ApplyToJobState {
  const ApplyToJobSuccess(this.application);

  final ApplicationEntity application;

  @override
  List<Object?> get props => [application];
}

class ApplyToJobFailure extends ApplyToJobState {
  const ApplyToJobFailure({
    required this.message,
    this.isCandidateProfileRequired = false,
    this.isAlreadyApplied = false,
  });

  final String message;
  final bool isCandidateProfileRequired;
  final bool isAlreadyApplied;

  @override
  List<Object?> get props => [message, isCandidateProfileRequired, isAlreadyApplied];
}
