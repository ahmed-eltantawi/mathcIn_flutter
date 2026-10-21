import 'package:equatable/equatable.dart';

/// Parameters for completing a roadmap task.
///
/// [taskId] is the backend [RoadmapTask.id]. [completionNote] is optional
/// and omitted from the request when absent (no note input in this phase).
/// [roadmapId] is local-only: it targets the cached roadmap for
/// offline-first updates and is never serialized into the API request.
/// JSON serialization lives in the Data Layer; this class carries values
/// only.
class CompleteRoadmapTaskParams extends Equatable {
  const CompleteRoadmapTaskParams({
    required this.taskId,
    this.completionNote,
    this.roadmapId,
  });

  final int taskId;
  final String? completionNote;
  final int? roadmapId;

  @override
  List<Object?> get props => [taskId, completionNote, roadmapId];
}
