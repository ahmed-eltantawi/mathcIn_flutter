import 'package:MatchIn/features/roadmap/domain/entities/complete_roadmap_task_params.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CompleteRoadmapTaskParams', () {
    test('holds the backend task id', () {
      const params = CompleteRoadmapTaskParams(taskId: 7);

      expect(params.taskId, 7);
      expect(params.completionNote, isNull);
    });

    test('supports value equality', () {
      expect(
        const CompleteRoadmapTaskParams(taskId: 7),
        const CompleteRoadmapTaskParams(taskId: 7),
      );
      expect(
        const CompleteRoadmapTaskParams(taskId: 7),
        isNot(const CompleteRoadmapTaskParams(taskId: 8)),
      );
    });
  });
}
