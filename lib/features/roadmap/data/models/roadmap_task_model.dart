import 'package:MatchIn/features/roadmap/domain/entities/roadmap_task.dart';

class RoadmapTaskModel extends RoadmapTask {
  const RoadmapTaskModel({
    required super.id,
    required super.title,
    super.description,
    super.estimatedHours,
    super.isCompleted,
    super.completedAt,
  });

  factory RoadmapTaskModel.fromJson(Map<String, dynamic> json) {
    return RoadmapTaskModel(
      id: _parseId(json['id']) ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      estimatedHours: (json['estimated_hours'] as num?)?.toInt(),
      isCompleted: _parseBool(json['is_completed']) ?? false,
      completedAt: json['completed_at']?.toString(),
    );
  }

  static int? _parseId(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return null;
  }
}
