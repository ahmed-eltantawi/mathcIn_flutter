import 'package:MatchIn/features/roadmap/domain/entities/refresh_roadmap_params.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RefreshRoadmapParams', () {
    test('holds the roadmap id with optional reason', () {
      const params = RefreshRoadmapParams(
        roadmapId: 1,
        reason: 'Focus more on backend skills',
      );

      expect(params.roadmapId, 1);
      expect(params.reason, 'Focus more on backend skills');
    });

    test('reason defaults to null', () {
      const params = RefreshRoadmapParams(roadmapId: 1);

      expect(params.reason, isNull);
    });

    test('supports value equality', () {
      expect(
        const RefreshRoadmapParams(roadmapId: 1, reason: 'x'),
        const RefreshRoadmapParams(roadmapId: 1, reason: 'x'),
      );
      expect(
        const RefreshRoadmapParams(roadmapId: 1),
        isNot(const RefreshRoadmapParams(roadmapId: 2)),
      );
    });
  });
}
