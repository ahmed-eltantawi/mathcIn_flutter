import 'package:MatchIn/features/jobsAndApplications/domain/entities/application_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/get_application_details_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/update_application_status_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/withdraw_application_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/application_details_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ApplicationDetailsCubit extends Cubit<ApplicationDetailsState> {
  ApplicationDetailsCubit({
    required this.getApplicationDetailsUseCase,
    required this.withdrawApplicationUseCase,
    required this.updateApplicationStatusUseCase,
  }) : super(const ApplicationDetailsInitial());

  final GetApplicationDetailsUseCase getApplicationDetailsUseCase;
  final WithdrawApplicationUseCase withdrawApplicationUseCase;
  final UpdateApplicationStatusUseCase updateApplicationStatusUseCase;

  Future<void> fetchApplicationDetails(String applicationId) async {
    emit(const ApplicationDetailsLoading());

    final result = await getApplicationDetailsUseCase(applicationId);

    result.fold(
      (failure) => emit(ApplicationDetailsError(failure.message)),
      (application) => emit(ApplicationDetailsLoaded(application: application)),
    );
  }

  void setInitialApplication(ApplicationEntity initialApp) {
    emit(ApplicationDetailsLoaded(application: initialApp));
  }

  Future<void> withdrawApplication(String applicationId) async {
    final currentState = state;
    if (currentState is! ApplicationDetailsLoaded) return;

    if (!currentState.application.status.isWithdrawable) {
      emit(
        currentState.copyWith(
          errorMessage: 'Application cannot be withdrawn in its current status.',
        ),
      );
      return;
    }

    emit(currentState.copyWith(isActionLoading: true));

    final result = await withdrawApplicationUseCase(applicationId);

    result.fold(
      (failure) {
        emit(
          currentState.copyWith(
            isActionLoading: false,
            errorMessage: failure.message,
          ),
        );
      },
      (updatedApp) {
        emit(
          ApplicationDetailsLoaded(
            application: updatedApp,
            isActionLoading: false,
            actionSuccessMessage: 'Application withdrawn successfully.',
          ),
        );
      },
    );
  }

  Future<void> updateStatus({
    required String applicationId,
    required String newStatus,
    String? notes,
  }) async {
    final currentState = state;
    if (currentState is! ApplicationDetailsLoaded) return;

    final targetStatusEnum = ApplicationStatus.fromString(newStatus);
    if (!currentState.application.status.canTransitionTo(targetStatusEnum)) {
      emit(
        currentState.copyWith(
          errorMessage: 'Invalid status transition.',
        ),
      );
      return;
    }

    emit(currentState.copyWith(isActionLoading: true));

    final result = await updateApplicationStatusUseCase(
      applicationId: applicationId,
      status: newStatus,
      notes: notes,
    );

    result.fold(
      (failure) {
        emit(
          currentState.copyWith(
            isActionLoading: false,
            errorMessage: failure.message,
          ),
        );
      },
      (updatedApp) {
        emit(
          ApplicationDetailsLoaded(
            application: updatedApp,
            isActionLoading: false,
            actionSuccessMessage: 'Application status updated successfully.',
          ),
        );
      },
    );
  }
}
