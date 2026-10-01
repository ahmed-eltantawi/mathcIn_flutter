import 'package:MatchIn/features/jobsAndApplications/domain/use_case/apply_to_job_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/apply_to_job_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ApplyToJobCubit extends Cubit<ApplyToJobState> {
  ApplyToJobCubit({required this.applyToJobUseCase})
      : super(const ApplyToJobInitial());

  final ApplyToJobUseCase applyToJobUseCase;

  Future<void> submitApplication({
    required int jobId,
    String? coverLetter,
  }) async {
    if (state is ApplyToJobSubmitting) return;

    emit(const ApplyToJobSubmitting());

    final result = await applyToJobUseCase(
      jobId: jobId,
      coverLetter: coverLetter,
    );

    result.fold(
      (failure) {
        final message = failure.message.toLowerCase();
        final isAlreadyApplied = message.contains('already applied');
        final isCandidateProfileRequired =
            message.contains('candidate profile') || message.contains('profile required');

        emit(
          ApplyToJobFailure(
            message: failure.message,
            isAlreadyApplied: isAlreadyApplied,
            isCandidateProfileRequired: isCandidateProfileRequired,
          ),
        );
      },
      (application) {
        emit(ApplyToJobSuccess(application));
      },
    );
  }
}
