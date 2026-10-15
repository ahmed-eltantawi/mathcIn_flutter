import 'package:MatchIn/features/roadmap/data/models/roadmap_milestone_model.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_entity.dart';

class RoadmapModel extends RoadmapEntity {
  const RoadmapModel({
    required super.id,
    super.candidateId,
    super.targetRole,
    required super.title,
    super.description,
    super.status,
    super.completionPercentage,
    super.milestones,
    super.createdAt,
  });

  factory RoadmapModel.fromJson(Map<String, dynamic> json) {
    final milestonesJson = json['milestones'];
    return RoadmapModel(
      id: _parseId(json['id']) ?? 0,
      candidateId: _parseId(json['candidate_id']),
      targetRole: json['target_role']?.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      status: json['status']?.toString(),
      completionPercentage:
          (json['completion_percentage'] as num?)?.toDouble() ?? 0,
      milestones: milestonesJson is List
          ? milestonesJson
                .whereType<Map<String, dynamic>>()
                .map(RoadmapMilestoneModel.fromJson)
                .toList()
          : const [],
      createdAt: json['created_at']?.toString(),
    );
  }

  static int? _parseId(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }
}
