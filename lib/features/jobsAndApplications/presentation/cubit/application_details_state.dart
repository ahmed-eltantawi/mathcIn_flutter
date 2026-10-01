import 'package:MatchIn/features/jobsAndApplications/domain/entities/application_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ApplicationDetailsState extends Equatable {
  const ApplicationDetailsState();

  @override
  List<Object?> get props => [];
}

class ApplicationDetailsInitial extends ApplicationDetailsState {
  const ApplicationDetailsInitial();
}

class ApplicationDetailsLoading extends ApplicationDetailsState {
  const ApplicationDetailsLoading();
}

class ApplicationDetailsLoaded extends ApplicationDetailsState {
  const ApplicationDetailsLoaded({
    required this.application,
    this.isActionLoading = false,
    this.actionSuccessMessage,
    this.errorMessage,
  });

  final ApplicationEntity application;
  final bool isActionLoading;
  final String? actionSuccessMessage;
  final String? errorMessage;

  ApplicationDetailsLoaded copyWith({
    ApplicationEntity? application,
    bool? isActionLoading,
    String? actionSuccessMessage,
    String? errorMessage,
  }) {
    return ApplicationDetailsLoaded(
      application: application ?? this.application,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      actionSuccessMessage: actionSuccessMessage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        application,
        isActionLoading,
        actionSuccessMessage,
        errorMessage,
      ];
}

class ApplicationDetailsError extends ApplicationDetailsState {
  const ApplicationDetailsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
