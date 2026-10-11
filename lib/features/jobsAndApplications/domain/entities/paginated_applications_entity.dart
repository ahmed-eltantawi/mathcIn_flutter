import 'package:MatchIn/features/jobsAndApplications/domain/entities/application_entity.dart';
import 'package:equatable/equatable.dart';

class PaginatedApplicationsEntity extends Equatable {
  const PaginatedApplicationsEntity({
    required this.applications,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.hasNextPage,
  });

  final List<ApplicationEntity> applications;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool hasNextPage;

  @override
  List<Object?> get props => [
        applications,
        currentPage,
        lastPage,
        total,
        hasNextPage,
      ];
}
