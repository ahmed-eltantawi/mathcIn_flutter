import 'package:MatchIn/features/roadmap/data/models/roadmap_model.dart';
import 'package:MatchIn/features/roadmap/presentation/utils/roadmap_node_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression tests for the missing roadmap nodes bug.
///
/// Root causes covered:
/// 1. `roadmap_model.dart` did not compile (missing `RoadmapTaskModel`
///    import) so no roadmap UI could build at all.
/// 2. A single malformed milestone/task entry (e.g. non-numeric `order`,
///    malformed task map) threw during `.map(...)`, discarding the whole
///    roadmap and leaving the screen without nodes.
/// 3. Backend shape variants (`milestones` as a keyed map, flat `tasks`
///    on the roadmap object) previously produced zero nodes.
Map<String, dynamic> detailsPayload() => {
  'id': 1,
  'candidate_id': 1,
  'target_role': 'Cloud Architect',
  'title': 'Roadmap to Cloud Architect Mastery',
  'description': 'Strategic milestone plan.',
  'status': 'in_progress',
  'completion_percentage': 35,
  'milestones': [
    {
      'id': 1,
      'roadmap_id': 1,
      'title': 'Containerization & Cloud Fundamentals',
      'order': 1,
      'tasks': [
        {
          'id': 1,
          'title': 'Complete Docker Compose lab',
          'description': 'Containerize a server and database.',
          'estimated_hours': 6,
          'is_completed': true,
          'completed_at': '2026-10-15T08:04:37.099Z',
        },
        {
          'id': 2,
          'title': 'Kubernetes basics',
          'description': 'Pods and deployments.',
          'estimated_hours': '4',
          'is_completed': 0,
        },
      ],
    },
    {
      'id': 2,
      'roadmap_id': 1,
      'title': 'AWS architecture',
      'order': 2,
      'tasks': [
        {
          'id': 3,
          'title': 'VPC deep dive',
          'description': 'Subnets and routing.',
          'estimated_hours': 3,
          'is_completed': false,
        },
      ],
    },
  ],
  'created_at': '2026-10-15T08:04:37.099Z',
};

void main() {
  group('Missing roadmap nodes reproduction', () {
    test('every valid task becomes a node in milestone order', () {
      final roadmap = RoadmapModel.fromJson(detailsPayload());
      final nodes = RoadmapNodeMapper.mapMilestones(
        roadmap.milestones,
        durationLabel: (hours) => '$hours h',
      );

      expect(nodes.length, 3);
      expect(nodes.map((n) => n.id), ['1', '2', '3']);
      // Progress states: first task completed, second active, third locked.
      expect(nodes[0].tasks.first.isCompleted, isTrue);
      expect(nodes[1].title, 'Kubernetes basics');
      expect(nodes[2].title, 'VPC deep dive');
    });

    test('malformed milestone entries are skipped, valid nodes kept', () {
      final payload = detailsPayload();
      payload['milestones'] = <dynamic>[...(payload['milestones'] as List)];
      final List<dynamic> milestones = payload['milestones'] as List<dynamic>;
      milestones.addAll([
        'not-a-map',
        {
          'id': 99,
          'roadmap_id': 1,
          'title': 'Broken milestone',
          // Non-numeric order that previously crashed the whole parse.
          'order': 'not-a-number',
          'tasks': 'not-a-list',
        },
        {
          'id': 100,
          'roadmap_id': 1,
          'title': 'Broken tasks milestone',
          'order': 3,
          'tasks': [
            'not-a-map',
            {'id': 'bogus', 'title': 'Ghost task'},
            {'id': 4, 'title': 'Surviving task', 'is_completed': false},
          ],
        },
      ]);

      final roadmap = RoadmapModel.fromJson(payload);
      final nodes = RoadmapNodeMapper.mapMilestones(
        roadmap.milestones,
        durationLabel: (hours) => '$hours h',
      );

      // Non-map entries and invalid tasks are dropped without crashing.
      // The order-less milestone falls back to order 0 (sorted first) as an
      // empty placeholder node; every valid task node is preserved.
      expect(nodes.map((n) => n.id), ['99', '1', '2', '3', '4']);
      expect(nodes.where((n) => n.id == '4').single.title, 'Surviving task');
    });

    test('keyed milestones map still produces nodes', () {
      final payload = detailsPayload();
      final milestones = payload['milestones'] as List;
      payload['milestones'] = {'a': milestones[0], 'b': milestones[1]};

      final roadmap = RoadmapModel.fromJson(payload);
      expect(roadmap.milestones.length, 2);
    });

    test('flat tasks on the roadmap object are wrapped into nodes', () {
      final roadmap = RoadmapModel.fromJson(const {
        'id': 5,
        'title': 'Flat tasks roadmap',
        'tasks': [
          {'id': 11, 'title': 'Flat task one', 'is_completed': true},
          {'id': 'bogus', 'title': 'Ghost task'},
          {'id': 12, 'title': 'Flat task two', 'is_completed': false},
        ],
      });

      final nodes = RoadmapNodeMapper.mapMilestones(
        roadmap.milestones,
        durationLabel: (hours) => '$hours h',
      );

      expect(nodes.map((n) => n.id), ['11', '12']);
    });
  });
}
