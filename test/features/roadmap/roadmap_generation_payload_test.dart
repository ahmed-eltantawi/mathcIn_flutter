import 'package:MatchIn/features/roadmap/data/models/roadmap_model.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_xp_metrics_model.dart';
import 'package:MatchIn/features/roadmap/presentation/utils/roadmap_node_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression tests for the generation payload shape observed in
/// production logs: `POST /api/roadmaps` returns `data` with a nested
/// `target` object, a `progress` field (not `completion_percentage`),
/// and `phases[] -> milestones[] -> tasks[]` instead of flat
/// `milestones[]`. The pre-fix model parsed none of it, so a successful
/// generation rendered zero nodes.
Map<String, dynamic> generationPayload() => {
  'status': 'success',
  'message': 'Career roadmap generated successfully.',
  'data': {
    'id': 14,
    'title': 'Career Roadmap: Flutter',
    'description':
        'Personalized learning progression targeting Flutter (4 weeks)',
    'rationale': 'Systematically designed progression to bridge skill gaps',
    'status': 'in_progress',
    'progress': 0,
    'target': {'type': 'role', 'role': 'Flutter'},
    'generation_version': 1,
    'previous_roadmap_id': null,
    'metadata': {
      'notes': 'I need to study kotiln too',
      'generated_at': '2026-10-16T01:25:55.035Z',
    },
    'phases': [
      {
        'id': 27,
        'title': 'Phase 1: Core Fundamentals Skill Acquisition',
        'description': 'Sequential priority phase.',
        'order': 1,
        'status': 'pending',
        'milestones': [
          {
            'id': 27,
            'title': 'Master Fundamentals of Core Fundamentals',
            'description': 'Master Fundamentals of Core Fundamentals',
            'order': 1,
            'status': 'pending',
            'tasks': [
              {
                'id': 53,
                'title': 'Study core documentation and patterns for Core Fundamentals',
                'description': 'Gain deep understanding.',
              },
              {
                'id': 54,
                'title': 'Second task without completion flags',
                'description': 'Another task.',
                'is_completed': false,
              },
            ],
          },
          {
            'id': 28,
            'title': 'Second milestone',
            'description': 'More work.',
            'order': 2,
            'status': 'pending',
            'tasks': [
              {
                'id': 55,
                'title': 'Phase task three',
                'description': 'Deep dive.',
                'estimated_hours': 3,
                'is_completed': 0,
              },
            ],
          },
        ],
      },
      {
        'id': 28,
        'title': 'Phase 2: Framework Mastery',
        'description': 'Second phase.',
        'order': 2,
        'status': 'pending',
        'milestones': [
          {
            'id': 30,
            'title': 'Framework milestone',
            'description': 'Build apps.',
            'order': 1,
            'status': 'pending',
            'tasks': [
              {
                'id': 60,
                'title': 'Build a sample app',
                'description': 'Hands on.',
              },
            ],
          },
        ],
      },
    ],
  },
};

void main() {
  group('Generation response parsing (phases/target/progress)', () {
    test('maps the logged generation payload without losing tasks', () {
      final data = generationPayload()['data'] as Map<String, dynamic>;
      final roadmap = RoadmapModel.fromJson(data);

      expect(roadmap.id, 14);
      expect(roadmap.title, 'Career Roadmap: Flutter');
      expect(roadmap.targetRole, 'Flutter');
      expect(roadmap.status, 'in_progress');
      expect(roadmap.completionPercentage, 0);
      expect(roadmap.phases.length, 2);
      // All four tasks survive across phases, in phase/milestone order.
      final taskIds = roadmap.milestones
          .expand((milestone) => milestone.tasks)
          .map((task) => task.id)
          .toList();
      expect(taskIds, [53, 54, 55, 60]);
    });

    test('every generated task becomes a renderable node', () {
      final data = generationPayload()['data'] as Map<String, dynamic>;
      final roadmap = RoadmapModel.fromJson(data);
      final nodes = RoadmapNodeMapper.mapMilestones(
        roadmap.milestones,
        durationLabel: (hours) => '${hours}h',
      );

      expect(nodes.map((node) => node.id), ['53', '54', '55', '60']);
      expect(nodes[1].title, 'Second task without completion flags');
    });

    test('tasks without flags default to incomplete with empty duration', () {
      final data = generationPayload()['data'] as Map<String, dynamic>;
      final roadmap = RoadmapModel.fromJson(data);
      final tasks = roadmap.milestones.first.tasks;

      expect(tasks.first.isCompleted, isFalse);
      expect(tasks.first.estimatedHours, isNull);
    });

    test('legacy flat milestones still parse', () {
      final roadmap = RoadmapModel.fromJson({
        'id': 1,
        'title': 'Legacy',
        'target_role': 'Cloud Architect',
        'completion_percentage': 35,
        'milestones': [
          {
            'id': 1,
            'title': 'M1',
            'order': 1,
            'tasks': [
              {'id': 1, 'title': 'T1', 'is_completed': true},
            ],
          },
        ],
      });

      expect(roadmap.targetRole, 'Cloud Architect');
      expect(roadmap.completionPercentage, 35);
      expect(roadmap.milestones.length, 1);
      expect(roadmap.phases, isEmpty);
    });

    test('string progress and string target fall back safely', () {
      final roadmap = RoadmapModel.fromJson({
        'id': 2,
        'title': 'Mixed',
        'progress': '45.5',
        'target': 'Backend Engineer',
        'milestones': [],
      });

      expect(roadmap.completionPercentage, 45.5);
      expect(roadmap.targetRole, 'Backend Engineer');
    });

    test('malformed phase entries are skipped, valid phases kept', () {
      final payload = generationPayload();
      final data = payload['data'] as Map<String, dynamic>;
      data['phases'] = <dynamic>[
        ...(data['phases'] as List),
        'not-a-map',
        {'id': 'bogus', 'title': 'Broken', 'milestones': 'nope'},
      ];

      final roadmap = RoadmapModel.fromJson(data);
      final taskIds = roadmap.milestones
          .expand((milestone) => milestone.tasks)
          .map((task) => task.id)
          .toList();

      expect(taskIds, [53, 54, 55, 60]);
    });

    test('XP metrics parse independently from the roadmap hierarchy', () {
      final metrics = RoadmapXpMetricsModel.fromJson({
        'roadmap_id': 14,
        'roadmap_title': 'Career Roadmap: Flutter',
        'status': 'in_progress',
        'progress': 0,
        'earned_xp': 0,
        'target_xp': 500,
        'tasks_completed': 0,
        'total_tasks': 4,
        'history': [],
        'user_level': {
          'level': 1,
          'title': 'Beginner Explorer',
          'total_xp': 0,
          'current_level_xp': 0,
          'next_level_xp': 100,
          'xp_to_next_level': 100,
          'progress_percentage': 0,
        },
      });

      expect(metrics.roadmapId, 14);
      expect(metrics.targetXp, 500);
      expect(metrics.totalTasks, 4);
      expect(metrics.tasksCompleted, 0);
    });
  });
}
