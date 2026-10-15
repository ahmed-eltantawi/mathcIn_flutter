import 'package:MatchIn/features/roadmap/data/models/skill_task.dart';

enum RoadmapTaskStatus { completed, active, locked }

typedef RoadmapNodeStatus = RoadmapTaskStatus;

class RoadmapNode {
  const RoadmapNode({
    required this.title,
    this.subtitle,
    required this.status,
    this.duration,
    this.xp,
    this.icon,
    this.tasks = const [],
    this.id,
  });

  final String title;
  final String? subtitle;
  final RoadmapTaskStatus status;
  final String? duration;
  final int? xp;
  final dynamic icon;
  final List<SkillTask> tasks;

  /// Backend milestone id as a string, when this node was mapped from
  /// backend data. Null for locally constructed (mock) nodes.
  final String? id;

  int get completedTasksCount => tasks.where((t) => t.isCompleted).length;

  int get totalTasksCount => tasks.length;

  double get progressRatio {
    if (totalTasksCount > 0) {
      return completedTasksCount / totalTasksCount;
    }
    return status == RoadmapTaskStatus.completed ? 1.0 : 0.0;
  }

  RoadmapNode copyWith({
    String? title,
    String? subtitle,
    RoadmapTaskStatus? status,
    String? duration,
    int? xp,
    dynamic icon,
    List<SkillTask>? tasks,
    String? id,
  }) {
    return RoadmapNode(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      status: status ?? this.status,
      duration: duration ?? this.duration,
      xp: xp ?? this.xp,
      icon: icon ?? this.icon,
      tasks: tasks ?? this.tasks,
      id: id ?? this.id,
    );
  }
}
