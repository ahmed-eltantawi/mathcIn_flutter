import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:equatable/equatable.dart';

enum ApplicationStatus {
  applied,
  inReview,
  interview,
  offer,
  rejected,
  withdrawn,
  unknown;

  static ApplicationStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'applied':
        return ApplicationStatus.applied;
      case 'in_review':
        return ApplicationStatus.inReview;
      case 'interview':
        return ApplicationStatus.interview;
      case 'offer':
        return ApplicationStatus.offer;
      case 'rejected':
        return ApplicationStatus.rejected;
      case 'withdrawn':
        return ApplicationStatus.withdrawn;
      default:
        return ApplicationStatus.unknown;
    }
  }

  String toApiString() {
    switch (this) {
      case ApplicationStatus.applied:
        return 'applied';
      case ApplicationStatus.inReview:
        return 'in_review';
      case ApplicationStatus.interview:
        return 'interview';
      case ApplicationStatus.offer:
        return 'offer';
      case ApplicationStatus.rejected:
        return 'rejected';
      case ApplicationStatus.withdrawn:
        return 'withdrawn';
      case ApplicationStatus.unknown:
        return 'applied';
    }
  }

  bool canTransitionTo(ApplicationStatus target) {
    if (this == target) return true;
    switch (this) {
      case ApplicationStatus.applied:
        return target == ApplicationStatus.inReview ||
            target == ApplicationStatus.withdrawn ||
            target == ApplicationStatus.rejected;
      case ApplicationStatus.inReview:
        return target == ApplicationStatus.interview ||
            target == ApplicationStatus.rejected ||
            target == ApplicationStatus.offer ||
            target == ApplicationStatus.withdrawn;
      case ApplicationStatus.interview:
        return target == ApplicationStatus.offer ||
            target == ApplicationStatus.rejected ||
            target == ApplicationStatus.withdrawn;
      case ApplicationStatus.offer:
        return target == ApplicationStatus.withdrawn;
      case ApplicationStatus.rejected:
      case ApplicationStatus.withdrawn:
      case ApplicationStatus.unknown:
        return false;
    }
  }

  bool get isWithdrawable => canTransitionTo(ApplicationStatus.withdrawn);
}

class ApplicationEntity extends Equatable {
  const ApplicationEntity({
    required this.id,
    required this.type,
    required this.status,
    this.coverLetter,
    this.appliedAt,
    this.createdAt,
    this.updatedAt,
    this.job,
  });

  final String id;
  final String type;
  final ApplicationStatus status;
  final String? coverLetter;
  final DateTime? appliedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final JobEntity? job;

  ApplicationEntity copyWith({
    String? id,
    String? type,
    ApplicationStatus? status,
    String? coverLetter,
    DateTime? appliedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    JobEntity? job,
  }) {
    return ApplicationEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      coverLetter: coverLetter ?? this.coverLetter,
      appliedAt: appliedAt ?? this.appliedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      job: job ?? this.job,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        status,
        coverLetter,
        appliedAt,
        createdAt,
        updatedAt,
        job,
      ];
}
