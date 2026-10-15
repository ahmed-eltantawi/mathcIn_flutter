import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/application_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/repositories/applications_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateApplicationNotesUseCase {
  const UpdateApplicationNotesUseCase({required this.repository});

  final ApplicationsRepository repository;

  Future<Either<Failure, ApplicationEntity>> call({
    required String applicationId,
    required String notes,
  }) {
    return repository.updateApplicationNotes(
      applicationId: applicationId,
      notes: notes,
    );
  }
}
