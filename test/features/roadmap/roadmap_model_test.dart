import 'package:MatchIn/features/roadmap/data/models/roadmap_milestone_model.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_model.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_pagination_model.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_task_model.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> listPayload() => {
  'data': [
    {
      'id': 1,
      'candidate_id': 1,
      'target_role': 'Cloud Architect',
      'title': 'Roadmap to Cloud Architect Mastery',
      'description': 'Strategic learning plan.',
      'status': 'in_progress',
      'completion_percentage': 35,
      'milestones': [
        {
          'id': 1,
          'roadmap_id': 1,
          'title': 'Containerization Fundamentals',
          'order': 1,
          'tasks': [
            {
              'id': 1,
              'title': 'Complete Docker lab',
              'description': 'Containerize an application.',
              'estimated_hours': 6,
              'is_completed': true,
              'completed_at': '2026-10-14T22:33:10.503Z',
            },
            {'id': 'bogus', 'title': 'Ghost task'},
          ],
        },
        {'id': 2, 'title': 'Empty milestone', 'order': 2, 'tasks': []},
      ],
      'created_at': '2026-10-14T22:33:10.503Z',
    },
  ],
  'links': {
    'first': '/api/roadmaps?page=1',
    'last': '/api/roadmaps?page=10',
    'prev': null,
    'next': '/api/roadmaps?page=2',
  },
  'meta': {'current_page': 1, 'last_page': 10, 'per_page': 15, 'total': 150},
};

void main() {
  group('RoadmapModel list parsing', () {
    test('parses roadmaps with nested milestones and tasks', () {
      final items = (listPayload()['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(RoadmapModel.fromJson)
          .toList();

      expect(items.length, 1);
      final roadmap = items.first;
      expect(roadmap.id, 1);
      expect(roadmap.title, 'Roadmap to Cloud Architect Mastery');
      expect(roadmap.status, 'in_progress');
      expect(roadmap.completionPercentage, 35);
      expect(roadmap.milestones.length, 2);
      final milestone = roadmap.milestones.first;
      expect(milestone.title, 'Containerization Fundamentals');
      expect(milestone.order, 1);
      expect(milestone.tasks.length, 1);
      final task = milestone.tasks.first;
      expect(task.title, 'Complete Docker lab');
      expect(task.estimatedHours, 6);
      expect(task.isCompleted, isTrue);
      expect(task.completedAt, '2026-10-14T22:33:10.503Z');
    });

    test('skips tasks with invalid ids while keeping valid ones', () {
      final items = (listPayload()['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(RoadmapModel.fromJson)
          .toList();

      expect(items.first.milestones.first.tasks.map((task) => task.id), [1]);
    });

    test('accepts string ids and nullable fields', () {
      final model = RoadmapModel.fromJson(const {
        'id': '7',
        'title': 'Minimal',
        'completion_percentage': 12.5,
      });

      expect(model.id, 7);
      expect(model.targetRole, isNull);
      expect(model.completionPercentage, 12.5);
      expect(model.milestones, isEmpty);
    });

    test('parses pagination metadata without from/to', () {
      final meta = listPayload()['meta'] as Map<String, dynamic>;
      final pagination = RoadmapPaginationModel.fromJson(meta);

      expect(pagination.currentPage, 1);
      expect(pagination.lastPage, 10);
      expect(pagination.perPage, 15);
      expect(pagination.total, 150);
      expect(pagination.toEntity().hasNextPage, isTrue);
    });

    test('pagination reports last page correctly', () {
      const pagination = RoadmapPaginationModel(
        currentPage: 10,
        lastPage: 10,
        perPage: 15,
        total: 150,
      );

      expect(pagination.toEntity().hasNextPage, isFalse);
    });
  });

  group('RoadmapTaskModel', () {
    test('accepts 0/1 flag variants', () {
      expect(
        RoadmapTaskModel.fromJson(const {
          'id': 1,
          'title': 'A',
          'is_completed': 1,
        }).isCompleted,
        isTrue,
      );
      expect(
        RoadmapTaskModel.fromJson(const {
          'id': 1,
          'title': 'A',
          'is_completed': 0,
        }).isCompleted,
        isFalse,
      );
    });
  });

  group('RoadmapMilestoneModel', () {
    test('defaults missing tasks to empty', () {
      final milestone = RoadmapMilestoneModel.fromJson(const {
        'id': 2,
        'title': 'Empty',
      });

      expect(milestone.order, 0);
      expect(milestone.tasks, isEmpty);
    });
  });
}
