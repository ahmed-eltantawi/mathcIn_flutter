import 'package:equatable/equatable.dart';

class RoadmapXpMetricsEntity extends Equatable {
  const RoadmapXpMetricsEntity({
    required this.roadmapId,
    this.roadmapTitle = '',
    this.status = '',
    this.progress = 0.0,
    this.earnedXp = 0,
    this.targetXp = 0,
    this.tasksCompleted = 0,
    this.totalTasks = 0,
  });

  final int roadmapId;
  final String roadmapTitle;
  final String status;
  final double progress;
  final int earnedXp;
  final int targetXp;
  final int tasksCompleted;
  final int totalTasks;

  RoadmapXpMetricsEntity copyWith({
    int? roadmapId,
    String? roadmapTitle,
    String? status,
    double? progress,
    int? earnedXp,
    int? targetXp,
    int? tasksCompleted,
    int? totalTasks,
  }) {
    return RoadmapXpMetricsEntity(
      roadmapId: roadmapId ?? this.roadmapId,
      roadmapTitle: roadmapTitle ?? this.roadmapTitle,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      earnedXp: earnedXp ?? this.earnedXp,
      targetXp: targetXp ?? this.targetXp,
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      totalTasks: totalTasks ?? this.totalTasks,
    );
  }

  @override
  List<Object?> get props => [
    roadmapId,
    roadmapTitle,
    status,
    progress,
    earnedXp,
    targetXp,
    tasksCompleted,
    totalTasks,
  ];
}
