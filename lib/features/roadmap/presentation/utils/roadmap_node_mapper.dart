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
    bool foundActive = false;

    for (final milestone in sorted) {
      if (milestone.tasks.isEmpty) {
        final RoadmapTaskStatus status;
        if (foundActive) {
          status = RoadmapTaskStatus.locked;
        } else {
          status = RoadmapTaskStatus.active;
          foundActive = true;
        }

        result.add(
          RoadmapNode(
            id: milestone.id.toString(),
            title: milestone.title,
            status: status,
            tasks: const [],
          ),
        );
      } else {
        for (final task in milestone.tasks) {
          final skillTask = SkillTask(
            id: task.id.toString(),
            title: task.title,
            description: task.description,
            duration: task.estimatedHours == null
                ? ''
                : durationLabel(task.estimatedHours!),
            isCompleted: task.isCompleted,
          );

          final RoadmapTaskStatus status;
          if (task.isCompleted) {
            status = RoadmapTaskStatus.completed;
          } else if (!foundActive) {
            status = RoadmapTaskStatus.active;
            foundActive = true;
          } else {
            status = RoadmapTaskStatus.locked;
          }

          result.add(
            RoadmapNode(
              id: task.id.toString(),
              title: task.title,
              subtitle: milestone.title,
              status: status,
              duration: task.estimatedHours == null
                  ? null
                  : durationLabel(task.estimatedHours!),
              xp: 100,
              tasks: [skillTask],
            ),
          );
        }
      }
    }
    return result;
  }
}
