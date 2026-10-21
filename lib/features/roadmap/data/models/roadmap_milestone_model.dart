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
    // --- One malformed task must not discard the whole milestone. ---
    List<RoadmapTaskModel> parsedTasks = const [];
    if (tasksJson is List) {
      final List<RoadmapTaskModel> tasks = [];
      for (final entry in tasksJson) {
        if (entry is! Map<String, dynamic>) continue;
        if (_parseId(entry['id']) == null) continue;
        try {
          tasks.add(RoadmapTaskModel.fromJson(entry));
        } catch (_) {
          continue;
        }
      }
      parsedTasks = tasks;
    }
    return RoadmapMilestoneModel(
      id: _parseId(json['id']) ?? 0,
      roadmapId: _parseId(json['roadmap_id']),
      title: json['title']?.toString() ?? '',
      order: _parseOrder(json['order']),
      tasks: parsedTasks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (roadmapId != null) 'roadmap_id': roadmapId,
      'title': title,
      'order': order,
      'tasks': tasks.map((task) {
        if (task is RoadmapTaskModel) return task.toJson();
        return RoadmapTaskModel(
          id: task.id,
          title: task.title,
          description: task.description,
          estimatedHours: task.estimatedHours,
          isCompleted: task.isCompleted,
          completedAt: task.completedAt,
        ).toJson();
      }).toList(),
    };
  }

  static int? _parseId(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static int _parseOrder(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) {
      final asInt = int.tryParse(value.trim());
      if (asInt != null) return asInt;
      final asDouble = double.tryParse(value.trim());
      if (asDouble != null) return asDouble.toInt();
    }
    return 0;
  }
}
