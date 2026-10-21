import 'package:MatchIn/features/roadmap/domain/entities/roadmap_task.dart';
import 'package:equatable/equatable.dart';

class RoadmapMilestone extends Equatable {
  const RoadmapMilestone({
    required this.id,
    this.roadmapId,
    required this.title,
    required this.order,
    this.tasks = const [],
  });

  final int id;
  final int? roadmapId;
  final String title;
  final int order;
  final List<RoadmapTask> tasks;

  RoadmapMilestone copyWith({
    int? id,
    int? roadmapId,
    String? title,
    int? order,
    List<RoadmapTask>? tasks,
  }) {
    return RoadmapMilestone(
      id: id ?? this.id,
      roadmapId: roadmapId ?? this.roadmapId,
      title: title ?? this.title,
      order: order ?? this.order,
      tasks: tasks ?? this.tasks,
    );
  }

  @override
  List<Object?> get props => [id, roadmapId, title, order, tasks];
}
