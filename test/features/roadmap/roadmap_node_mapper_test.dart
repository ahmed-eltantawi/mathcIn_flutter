import 'package:MatchIn/features/roadmap/data/models/roadmap_node.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_milestone.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_task.dart';
import 'package:MatchIn/features/roadmap/presentation/utils/roadmap_node_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

String labelOf(int hours) => '${hours}h';

RoadmapMilestone milestone(
  int id,
  int order, {
  List<RoadmapTask> tasks = const [],
}) => RoadmapMilestone(id: id, title: 'M$id', order: order, tasks: tasks);

RoadmapTask task(int id, {bool completed = false, int? hours}) => RoadmapTask(
  id: id,
  title: 'T$id',
  isCompleted: completed,
  estimatedHours: hours,
);

void main() {
  group('RoadmapNodeMapper', () {
    test('sorts milestones by order field', () {
      final nodes = RoadmapNodeMapper.mapMilestones([
        milestone(2, 2),
        milestone(1, 1),
      ], durationLabel: labelOf);

      expect(nodes.map((node) => node.id), ['1', '2']);
      expect(nodes.map((node) => node.title), ['M1', 'M2']);
    });

    test('derives completed/active/locked sequentially', () {
      final nodes = RoadmapNodeMapper.mapMilestones([
        milestone(1, 1, tasks: [task(1, completed: true)]),
        milestone(2, 2, tasks: [task(2)]),
        milestone(3, 3, tasks: [task(3)]),
      ], durationLabel: labelOf);

      expect(nodes[0].status, RoadmapTaskStatus.completed);
      expect(nodes[1].status, RoadmapTaskStatus.active);
      expect(nodes[2].status, RoadmapTaskStatus.locked);
    });

    test('keeps empty-task milestones safe without completing them', () {
      final nodes = RoadmapNodeMapper.mapMilestones([
        milestone(1, 1),
      ], durationLabel: labelOf);

      expect(nodes.first.status, RoadmapTaskStatus.active);
      expect(nodes.first.tasks, isEmpty);
    });

    test('maps backend ids and completion flags to tasks', () {
      final nodes = RoadmapNodeMapper.mapMilestones([
        milestone(9, 1, tasks: [task(42, completed: true, hours: 6)]),
      ], durationLabel: labelOf);

      final mapped = nodes.first.tasks.first;
      expect(mapped.id, '42');
      expect(mapped.isCompleted, isTrue);
      expect(mapped.duration, '6h');
    });

    test('maps missing hours to empty duration without crashing', () {
      final nodes = RoadmapNodeMapper.mapMilestones([
        milestone(9, 1, tasks: [task(42)]),
      ], durationLabel: labelOf);

      expect(nodes.first.tasks.first.duration, '');
    });

    test('passes unknown titles through for display', () {
      final nodes = RoadmapNodeMapper.mapMilestones([
        milestone(9, 1),
      ], durationLabel: labelOf);

      expect(nodes.first.title, 'M9');
    });
  });
}
