import 'package:MatchIn/features/roadmap/data/models/roadmap_task_model.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_milestone.dart';

class RoadmapMilestoneModel extends RoadmapMilestone {
  const RoadmapMilestoneModel({
    required super.id,
    super.roadmapId,
    required super.title,
    required super.order,
    super.tasks,
  });

  factory RoadmapMilestoneModel.fromJson(Map<String, dynamic> json) {
    final tasksJson = json['tasks'];
    return RoadmapMilestoneModel(
      id: _parseId(json['id']) ?? 0,
      roadmapId: _parseId(json['roadmap_id']),
      title: json['title']?.toString() ?? '',
      order: (json['order'] as num?)?.toInt() ?? 0,
      tasks: tasksJson is List
          ? tasksJson
                .whereType<Map<String, dynamic>>()
                .where((item) => _parseId(item['id']) != null)
                .map(RoadmapTaskModel.fromJson)
                .toList()
          : const [],
    );
  }

  static int? _parseId(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }
}
