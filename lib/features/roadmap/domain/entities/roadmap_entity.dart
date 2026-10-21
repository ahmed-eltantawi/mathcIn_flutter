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

  RoadmapEntity copyWith({
    int? id,
    int? candidateId,
    String? targetRole,
    String? title,
    String? description,
    String? status,
    double? completionPercentage,
    List<RoadmapMilestone>? milestones,
    String? createdAt,
  }) {
    return RoadmapEntity(
      id: id ?? this.id,
      candidateId: candidateId ?? this.candidateId,
      targetRole: targetRole ?? this.targetRole,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      milestones: milestones ?? this.milestones,
      createdAt: createdAt ?? this.createdAt,
    );
  }

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
