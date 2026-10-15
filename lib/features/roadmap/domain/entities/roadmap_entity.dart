import 'package:MatchIn/features/roadmap/domain/entities/roadmap_milestone.dart';
import 'package:equatable/equatable.dart';

class RoadmapEntity extends Equatable {
  const RoadmapEntity({
    required this.id,
    this.candidateId,
    this.targetRole,
    required this.title,
    this.description,
    this.status,
    this.completionPercentage = 0,
    this.milestones = const [],
    this.createdAt,
  });

  final int id;
  final int? candidateId;
  final String? targetRole;
  final String title;
  final String? description;
  final String? status;
  final double completionPercentage;
  final List<RoadmapMilestone> milestones;
  final String? createdAt;

  @override
  List<Object?> get props => [
    id,
    candidateId,
    targetRole,
    title,
    description,
    status,
    completionPercentage,
    milestones,
    createdAt,
  ];
}
