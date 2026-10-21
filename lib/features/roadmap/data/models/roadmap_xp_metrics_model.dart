import 'package:MatchIn/features/roadmap/domain/entities/roadmap_xp_metrics_entity.dart';

/// Parses `GET /roadmaps/{roadmap}/xp` (`{status, data: {...}}`).
///
/// `history` and `user_level` schemas are undocumented, so they are
/// parsed defensively and dropped when absent.
class RoadmapXpMetricsModel extends RoadmapXpMetricsEntity {
  const RoadmapXpMetricsModel({
    required super.roadmapId,
    super.roadmapTitle,
    super.status,
    super.progress,
    super.earnedXp,
    super.targetXp,
    super.tasksCompleted,
    super.totalTasks,
  });

  factory RoadmapXpMetricsModel.fromJson(Map<String, dynamic> json) {
    return RoadmapXpMetricsModel(
      roadmapId: _parseInt(json['roadmap_id']) ?? 0,
      roadmapTitle: json['roadmap_title']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      progress: _parseDouble(json['progress']) ?? 0.0,
      earnedXp: _parseInt(json['earned_xp']) ?? 0,
      targetXp: _parseInt(json['target_xp']) ?? 0,
      tasksCompleted: _parseInt(json['tasks_completed']) ?? 0,
      totalTasks: _parseInt(json['total_tasks']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roadmap_id': roadmapId,
      'roadmap_title': roadmapTitle,
      'status': status,
      'progress': progress,
      'earned_xp': earnedXp,
      'target_xp': targetXp,
      'tasks_completed': tasksCompleted,
      'total_tasks': totalTasks,
    };
  }

  static int? _parseInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }
}
