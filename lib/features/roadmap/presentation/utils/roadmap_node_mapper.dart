import 'package:MatchIn/features/roadmap/data/models/roadmap_node.dart';
import 'package:MatchIn/features/roadmap/data/models/skill_task.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_milestone.dart';

/// Maps backend milestones to visual [RoadmapNode] view-models.
///
/// Pure function with no widget dependencies: [durationLabel] formats
/// task hours (callers pass the localized label), so this mapper stays
/// testable without localization context. Unknown backend values pass
/// through for display; nothing is invented.
class RoadmapNodeMapper {
  const RoadmapNodeMapper._();

  static List<RoadmapNode> mapMilestones(
    List<RoadmapMilestone> milestones, {
    required String Function(int hours) durationLabel,
  }) {
    final sorted = List<RoadmapMilestone>.of(milestones)
      ..sort((a, b) => a.order.compareTo(b.order));

    final List<RoadmapNode> result = [];
    for (var i = 0; i < sorted.length; i++) {
      final milestone = sorted[i];
      final tasks = milestone.tasks
          .map(
            (task) => SkillTask(
              id: task.id.toString(),
              title: task.title,
              description: task.description,
              duration: task.estimatedHours == null
                  ? ''
                  : durationLabel(task.estimatedHours!),
              isCompleted: task.isCompleted,
            ),
          )
          .toList();

      final allTasksCompleted =
          tasks.isNotEmpty && tasks.every((task) => task.isCompleted);

      final RoadmapTaskStatus status;
      if (allTasksCompleted) {
        status = RoadmapTaskStatus.completed;
      } else if (i == 0 ||
          (result.isNotEmpty &&
              result[i - 1].status == RoadmapTaskStatus.completed)) {
        status = RoadmapTaskStatus.active;
      } else {
        status = RoadmapTaskStatus.locked;
      }

      result.add(
        RoadmapNode(
          id: milestone.id.toString(),
          title: milestone.title,
          status: status,
          tasks: tasks,
        ),
      );
    }
    return result;
  }
}
