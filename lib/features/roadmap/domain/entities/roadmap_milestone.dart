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

  @override
  List<Object?> get props => [id, roadmapId, title, order, tasks];
}
