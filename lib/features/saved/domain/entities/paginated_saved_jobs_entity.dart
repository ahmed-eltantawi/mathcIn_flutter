import 'package:equatable/equatable.dart';
import 'package:MatchIn/features/saved/domain/entities/saved_job_entity.dart';

class PaginatedSavedJobsEntity extends Equatable {
  const PaginatedSavedJobsEntity({
    required this.jobs,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.hasMorePages,
  });

  final List<SavedJobEntity> jobs;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool hasMorePages;

  @override
  List<Object?> get props => [
        jobs,
        currentPage,
        lastPage,
        total,
        hasMorePages,
      ];
}
